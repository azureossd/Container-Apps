"""Dependency-free animal service intended to run inside an ACA Sandbox."""

from __future__ import annotations

import json
import os
import time
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ANIMALS = {
    "cat": {"sound": "meow", "skin": "fur"},
    "bird": {"sound": "chirp", "skin": "feathers"},
    "snake": {"sound": "hiss", "skin": "scales"},
}
MOUNTPOINT = Path(os.environ.get("ANIMAL_MOUNTPOINT", "/mnt/shared"))
STATE_FILE = MOUNTPOINT / "animal.json"
STARTED_AT = time.time()
CURRENT_ANIMAL: str | None = None
MUTATION_COUNT = 0


def _state() -> dict[str, object]:
    animal = ANIMALS.get(CURRENT_ANIMAL or "")
    return {
        "animal": CURRENT_ANIMAL,
        "sound": animal["sound"] if animal else None,
        "skin": animal["skin"] if animal else None,
        "pid": os.getpid(),
        "startedAt": STARTED_AT,
        "mutationCount": MUTATION_COUNT,
    }


class AnimalHandler(BaseHTTPRequestHandler):
    server_version = "AnimalSandboxDemo/1.0"

    def _send(self, status: HTTPStatus, body: dict[str, object]) -> None:
        payload = json.dumps(body, sort_keys=True).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:
        if self.path == "/healthz":
            self._send(HTTPStatus.OK, {"status": "ok"})
            return
        if self.path == "/animal":
            self._send(HTTPStatus.OK, _state())
            return
        if self.path in {"/animal/sound", "/animal/skin"}:
            if CURRENT_ANIMAL is None:
                self._send(HTTPStatus.CONFLICT, {"error": "Select an animal first"})
                return
            property_name = self.path.rsplit("/", 1)[1]
            self._send(HTTPStatus.OK, {**_state(), "value": ANIMALS[CURRENT_ANIMAL][property_name]})
            return
        if self.path == "/volume":
            if not STATE_FILE.exists():
                self._send(HTTPStatus.NOT_FOUND, {"error": f"{STATE_FILE} does not exist"})
                return
            self._send(HTTPStatus.OK, {"path": str(STATE_FILE), "saved": json.loads(STATE_FILE.read_text())})
            return
        self._send(HTTPStatus.NOT_FOUND, {"error": "Not found"})

    def do_POST(self) -> None:
        global CURRENT_ANIMAL, MUTATION_COUNT

        if self.path.startswith("/animal/"):
            animal_name = self.path.rsplit("/", 1)[1]
            if animal_name not in ANIMALS:
                self._send(HTTPStatus.BAD_REQUEST, {"error": f"Unknown animal: {animal_name}"})
                return
            CURRENT_ANIMAL = animal_name
            MUTATION_COUNT += 1
            self._send(HTTPStatus.OK, _state())
            return
        if self.path == "/volume":
            if CURRENT_ANIMAL is None:
                self._send(HTTPStatus.CONFLICT, {"error": "Select an animal first"})
                return
            MOUNTPOINT.mkdir(parents=True, exist_ok=True)
            STATE_FILE.write_text(json.dumps(_state(), sort_keys=True), encoding="utf-8")
            self._send(HTTPStatus.OK, {"path": str(STATE_FILE), "saved": _state()})
            return
        if self.path == "/volume/load":
            if not STATE_FILE.exists():
                self._send(HTTPStatus.NOT_FOUND, {"error": f"{STATE_FILE} does not exist"})
                return
            saved = json.loads(STATE_FILE.read_text(encoding="utf-8"))
            animal_name = saved.get("animal")
            if animal_name not in ANIMALS:
                self._send(HTTPStatus.UNPROCESSABLE_ENTITY, {"error": "Saved animal is invalid"})
                return
            CURRENT_ANIMAL = animal_name
            MUTATION_COUNT += 1
            self._send(HTTPStatus.OK, _state())
            return
        self._send(HTTPStatus.NOT_FOUND, {"error": "Not found"})

    def log_message(self, format: str, *args: object) -> None:
        print(f"{self.log_date_time_string()} {format % args}", flush=True)


def main() -> None:
    port = int(os.environ.get("ANIMAL_PORT", "8080"))
    server = ThreadingHTTPServer(("127.0.0.1", port), AnimalHandler)
    print(f"Animal service listening on http://127.0.0.1:{port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()