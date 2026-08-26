"""Interactive educational client for ACA Sandbox fundamentals."""

from __future__ import annotations

import argparse
import json
import os
import shlex
import sys
import time
import uuid
from pathlib import Path

from azure.containerapps.sandbox import (
    AutoSuspendPolicy,
    LifecyclePolicy,
    SandboxGroupClient,
    SandboxVolume,
    Snapshot,
    endpoint_for_region,
)
from azure.containerapps.sandbox._model_types._ports import (
    PortAuthConfig,
    PortAuthEntraId,
)
from azure.identity import DefaultAzureCredential

MOUNTPOINT = "/mnt/shared"
SCENARIO = "sandbox-fundamentals"


def _deserialize_port_auth(data: dict | None) -> PortAuthConfig | None:
    if not data:
        return None
    anonymous = data.get("anonymous")
    return PortAuthConfig(
        anonymous=anonymous,
        entra_id=(
            None
            if anonymous
            else PortAuthEntraId._from_dict(data.get("entraId"))
        ),
    )


# The preview service can return a stale entraId block with anonymous=true.
# Normalize that response shape while preserving validation for new requests.
PortAuthConfig._from_dict = classmethod(lambda cls, data: _deserialize_port_auth(data))


def _parse_label(value: str) -> tuple[str, str]:
    key, separator, label_value = value.partition("=")
    if not separator or not key or not label_value:
        raise argparse.ArgumentTypeError("label must use KEY=VALUE format")
    return key, label_value


def _load_env() -> None:
    for parent in Path(__file__).resolve().parents:
        env_file = parent / ".env"
        if env_file.is_file():
            for line in env_file.read_text(encoding="utf-8").splitlines():
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ.setdefault(key.strip(), value.strip())
            break

    required = (
        "AZURE_SUBSCRIPTION_ID",
        "ACA_RESOURCE_GROUP",
        "ACA_SANDBOX_GROUP",
        "ACA_SANDBOXGROUP_REGION",
        "ACA_DISK_IMAGE_ID",
    )
    missing = [name for name in required if not os.environ.get(name)]
    if missing:
        sys.exit(
            f"error: missing {', '.join(missing)}. Run "
            "`uv run python/samples/setup/setup.py` first."
        )


class Demo:
    def __init__(
        self,
        auto_suspend_seconds: int,
        reuse_label: tuple[str, str] | None = None,
    ) -> None:
        self.auto_suspend_seconds = auto_suspend_seconds
        self.disk_id = os.environ["ACA_DISK_IMAGE_ID"]
        self.label_key, self.label_value = reuse_label or ("scenario", SCENARIO)
        self.reuse_existing = reuse_label is not None

        self.credential = DefaultAzureCredential()
        self.client = SandboxGroupClient(
            endpoint_for_region(os.environ["ACA_SANDBOXGROUP_REGION"]),
            self.credential,
            subscription_id=os.environ["AZURE_SUBSCRIPTION_ID"],
            resource_group=os.environ["ACA_RESOURCE_GROUP"],
            sandbox_group=os.environ["ACA_SANDBOX_GROUP"],
        )
        self.run_id = uuid.uuid4().hex[:8]
        self.volume_name = f"animal-demo-{self.run_id}"
        self.volume_created = False
        self.snapshot_id = None
        self.sandbox = None
        self.sandbox_created = False

    def choose_snapshot(self) -> None:
        if input("Start from a snapshot? [y/N]: ").strip().lower() not in {"y", "yes"}:
            return

        snapshots = sorted(
            (
                snapshot
                for snapshot in self.client.list_snapshots()
                if snapshot.labels.get("scenario", "").startswith(SCENARIO)
            ),
            key=lambda snapshot: snapshot.created_at_utc or "",
            reverse=True,
        )
        if not snapshots:
            print("No matching snapshots found; using the private disk image.")
            return

        print("Available snapshots:")
        for index, snapshot in enumerate(snapshots, start=1):
            scenario = snapshot.labels.get("scenario", "")
            print(f"  {index}. {snapshot.id}  {scenario}  {snapshot.created_at_utc or 'unknown'}")
        print("  0. Use the private disk image")

        while True:
            choice = input("Choose snapshot [0]: ").strip() or "0"
            if choice == "0":
                return
            if choice.isdigit() and 1 <= int(choice) <= len(snapshots):
                snapshot = snapshots[int(choice) - 1]
                self.snapshot_id = snapshot.id
                self.run_id = snapshot.labels.get("run", self.run_id)
                self.volume_name = f"animal-demo-{self.run_id}"
                print(f"Selected snapshot {snapshot.id}.")
                return
            print("Unknown selection.")

    def choose_sandbox_reuse(self) -> None:
        choice = input(
            "Reuse a sandbox with a label if one exists "
            "(otherwise create one)? [Y/n]: "
        ).strip().lower()
        if choice in {"n", "no"}:
            print("A new sandbox will be created.")
            return

        default_label = f"scenario={SCENARIO}"
        while True:
            value = input(f"Sandbox label [{default_label}]: ").strip() or default_label
            try:
                self.label_key, self.label_value = _parse_label(value)
                self.reuse_existing = True
                return
            except argparse.ArgumentTypeError as error:
                print(f"Invalid label: {error}")

    def provision(self) -> None:
        if self.snapshot_id is not None:
            self.sandbox = self._create_sandbox()
            return

        if self.reuse_existing:
            matches = sorted(
                (
                    sandbox
                    for sandbox in self.client.list_sandboxes(
                        labels={self.label_key: self.label_value}
                    )
                    if sandbox.state in {"Running", "Stopped", "Suspended", "Idle"}
                ),
                key=lambda sandbox: sandbox.created_at or "",
                reverse=True,
            )
            if matches:
                existing = matches[0]
                self.sandbox = self.client.get_sandbox_client(existing.id)
                self.run_id = existing.labels.get("run", self.run_id)
                print(
                    f"Reusing sandbox {existing.id} with "
                    f"{self.label_key}={self.label_value}."
                )
                print(f"Ensuring sandbox is Running (current state: {existing.state})...")
                self.sandbox.ensure_running(timeout=180)
                self._wait_for_service(self.sandbox)
                print(f"Sandbox ready: {existing.id}")
                return

        volumes = [
            volume
            for volume in self.client.list_volumes()
            if volume.name.startswith("animal-demo")
        ]
        if volumes:
            self.volume_name = volumes[-1].name
            print(f"Reusing existing AzureBlob volume {self.volume_name!r}...")
            self.sandbox = self._create_sandbox()
            return

        print(f"Creating AzureBlob volume {self.volume_name!r}...")
        self.client.create_volume(self.volume_name, type="AzureBlob")
        self.volume_created = True
        self.sandbox = self._create_sandbox()

    def _create_sandbox(self):
        if self.snapshot_id is not None:
            print(f"Creating sandbox from snapshot {self.snapshot_id!r}...")
            sandbox = self.client.begin_create_sandbox(
                snapshot_id=self.snapshot_id,
            ).result()
        else:
            print(f"Creating sandbox on private disk {self.disk_id!r} with {self.volume_name!r} mounted...")
            sandbox = self.client.begin_create_sandbox(
                disk_id=self.disk_id,
                labels={self.label_key: self.label_value, "run": self.run_id},
                volumes=[SandboxVolume(volume_name=self.volume_name, mountpoint=MOUNTPOINT)],
            ).result()
        self.sandbox_created = True
        self.sandbox = sandbox
        self._wait_for_service(sandbox)

        sandbox.set_lifecycle_policy(
            LifecyclePolicy(
                auto_suspend=AutoSuspendPolicy(
                    enabled=True,
                    interval=self.auto_suspend_seconds,
                    mode="Memory",
                )
            )
        )
        print(f"Sandbox ready: {sandbox.sandbox_id}")
        print(f"Auto-suspend: {self.auto_suspend_seconds}s, mode=Memory")
        return sandbox

    @staticmethod
    def _wait_for_service(sandbox, timeout_seconds: int = 60) -> None:
        deadline = time.monotonic() + timeout_seconds
        while time.monotonic() < deadline:
            result = sandbox.exec("python3 /app/request.py GET /healthz")
            if result.exit_code == 0:
                return
            time.sleep(1)
        logs = sandbox.exec("cat /tmp/animal.log 2>/dev/null || true")
        raise RuntimeError(f"animal service did not become ready:\n{logs.stdout}")

    def state(self) -> str:
        if self.sandbox is None:
            return "NotCreated"
        return self.client.get_sandbox(self.sandbox.sandbox_id).state

    def call(self, method: str, path: str) -> dict | None:
        state = self.state()
        if state != "Running":
            print(f"Request not sent: sandbox state is {state!r}. Choose Resume first.")
            return None
        result = self.sandbox.exec(
            f"python3 /app/request.py {shlex.quote(method)} {shlex.quote(path)}"
        )
        if result.exit_code != 0:
            print(f"Request failed: {result.stderr or result.stdout}")
            return None
        response = json.loads(result.stdout)
        print(json.dumps(response, indent=2, sort_keys=True))
        return response

    def resume(self) -> None:
        state = self.state()
        if state == "Running":
            print("Sandbox is already Running.")
            return
        print(f"Resuming sandbox from {state!r}...")
        started = time.monotonic()
        self.sandbox.resume()
        self.sandbox.wait_for_running(timeout=180, poll_interval=2)
        print(f"Sandbox is Running after {time.monotonic() - started:.1f}s.")

    def create_snapshot(self) -> None:
        sandbox = self.client.get_sandbox(self.sandbox.sandbox_id)
        if sandbox.state != "Running":
            print(f"Snapshot requires a Running sandbox; current state is {sandbox.state!r}.")
            return
        state = self.call("GET", "/animal")
        animal = state.get("body", {}).get("animal") if state else None
        if not animal:
            print("Select an animal before creating a snapshot.")
            return
        labels = dict(sandbox.labels)
        labels["scenario"] = f"{labels.get('scenario', SCENARIO)}-{animal}"
        print(f"Creating snapshot with labels {labels}...")
        data = self.sandbox._dp_post(
            f"{self.sandbox._sbx_path}/snapshot",
            {"labels": labels},
        )
        snapshot = Snapshot._from_dict(data)
        print(f"Snapshot ready: {snapshot.id}")

    def replace_and_restore(self) -> None:
        if not self.sandbox_created:
            print("Replacement is unavailable for a reused sandbox.")
            return
        if self.state() != "Running":
            print(f"Replacement requires a Running sandbox; current state is {self.state()!r}.")
            return
        saved = self.call("GET", "/volume")
        if not saved or saved.get("httpStatus") != 200:
            print("Save an animal to the volume before replacing the sandbox.")
            return
        old_id = self.sandbox.sandbox_id
        print(f"Deleting sandbox {old_id}; keeping volume {self.volume_name}...")
        self.sandbox.delete()
        self.sandbox = None
        self.sandbox = self._create_sandbox()
        print(f"Replacement sandbox: {self.sandbox.sandbox_id}")
        print("Loading the animal checkpoint from the same Blob volume...")
        self.call("POST", "/volume/load")

    def close(self, keep_resources: bool) -> None:
        try:
            if keep_resources:
                print(f"Keeping sandbox and volume. Run id: {self.run_id}")
                return
            if self.sandbox is not None and self.sandbox_created:
                print(f"Deleting sandbox {self.sandbox.sandbox_id}...")
                self.sandbox.delete()
            if self.volume_created:
                print(f"Deleting volume {self.volume_name}...")
                self.client.delete_volume(self.volume_name)
        finally:
            self.client.close()
            self.credential.close()


def _choose_animal(demo: Demo) -> None:
    animal = input("Animal [cat/bird/snake]: ").strip().lower()
    if animal not in {"cat", "bird", "snake"}:
        print("Unknown animal.")
        return
    demo.call("POST", f"/animal/{animal}")


def _menu(demo: Demo) -> None:
    actions = {
        "1": ("Select animal", lambda: _choose_animal(demo)),
        "2": ("Get sound", lambda: demo.call("GET", "/animal/sound")),
        "3": ("Get skin", lambda: demo.call("GET", "/animal/skin")),
        "4": ("Get full in-memory state", lambda: demo.call("GET", "/animal")),
        "5": ("Show sandbox lifecycle state", lambda: print(f"Sandbox state: {demo.state()}")),
        "6": ("Explicitly resume sandbox", demo.resume),
        "7": ("Save animal to Blob volume", lambda: demo.call("POST", "/volume")),
        "8": ("Read animal from Blob volume", lambda: demo.call("GET", "/volume")),
        "9": ("Replace sandbox and restore from volume", demo.replace_and_restore),
        "10": ("Create snapshot", demo.create_snapshot),
    }
    while True:
        print("\nAnimal Sandbox Demo")
        for key, (label, _) in actions.items():
            print(f"  {key:>2}. {label}")
        print("   0. Exit and clean up")
        choice = input("Choose: ").strip()
        if choice == "0":
            return
        action = actions.get(choice)
        if action is None:
            print("Unknown option.")
            continue
        try:
            action[1]()
        except Exception as error:
            print(f"Operation failed: {error}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--auto-suspend-seconds", type=int, default=30)
    parser.add_argument("--keep-resources", action="store_true")
    parser.add_argument(
        "--reuse-sandbox",
        nargs="?",
        const=("scenario", SCENARIO),
        type=_parse_label,
        metavar="KEY=VALUE",
        help=(
            "reuse the newest sandbox with this label, creating one if absent; "
            f"defaults to scenario={SCENARIO}"
        ),
    )
    args = parser.parse_args()
    if args.auto_suspend_seconds < 10:
        parser.error("--auto-suspend-seconds must be at least 10")

    _load_env()
    demo = Demo(args.auto_suspend_seconds, args.reuse_sandbox)
    try:
        demo.choose_snapshot()
        if demo.snapshot_id is None and args.reuse_sandbox is None:
            demo.choose_sandbox_reuse()
        demo.provision()
        _menu(demo)
        return 0
    finally:
        demo.close(args.keep_resources)


if __name__ == "__main__":
    raise SystemExit(main())