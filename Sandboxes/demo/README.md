# Sandbox fundamentals: animal session

An interactive teaching sample that keeps four ACA Sandbox concepts visible:

1. A host-side Python client controls a sandbox through the SDK.
2. A long-running service retains an animal selection across a memory-mode
   auto-suspend and explicit resume.
3. An AzureBlob volume preserves an animal checkpoint after the original
   sandbox is deleted and replaced.
4. A snapshot captures the sandbox disk and copies the sandbox labels for
   later discovery, appending the selected animal to the `scenario` value.

The service listens only on sandbox localhost. No public ingress port is
created; the client reaches it by running a small request helper with
`sandbox.exec()`.

## Components

| Path | Runs in | Purpose |
|---|---|---|
| `client/client.py` | Your workstation | Creates resources and presents the interactive menu |
| `app/server.py` | Sandbox | Holds animal state in process memory and reads/writes the mount |
| `app/request.py` | Sandbox | Bridges an SDK `exec()` call to the localhost service |
| `app/Dockerfile` | Custom image | Packages the service used by the sandbox |

Build `app/Dockerfile`, push it to a registry, and convert that OCI image into
a private sandbox disk image. The client requires the resulting disk ID through
`ACA_DISK_IMAGE_ID`. The image starts the animal service automatically.

## Prerequisites

- Azure CLI authenticated with `az login`
- Python 3.10 or later
- The `azure-containerapps-sandbox` and `azure-identity` Python packages
- Permission to create sandboxes, volumes, and snapshots in the configured
   sandbox group
- A Container Apps [Sandbox Group](https://learn.microsoft.com/azure/container-apps/sandboxes-quickstart-portal#create-a-sandbox-group).

This sample creates one sandbox and one group-scoped AzureBlob volume. It
deletes both on normal exit unless `--keep-resources` is supplied. Snapshots
created from the menu are retained.

## Configure the local environment

The client searches its parent directories for the first `.env` file. Create
`.env` in the repository root with these values:

```dotenv
AZURE_SUBSCRIPTION_ID=<subscription-id>
ACA_RESOURCE_GROUP=<resource-group-name>
ACA_SANDBOX_GROUP=<sandbox-group-name>
ACA_SANDBOXGROUP_REGION=<sandbox-group-region>
ACA_DISK_IMAGE_ID=<private-disk-image-id>
```

| Variable | Purpose |
|---|---|
| `AZURE_SUBSCRIPTION_ID` | Subscription containing the sandbox group |
| `ACA_RESOURCE_GROUP` | Resource group containing the sandbox group |
| `ACA_SANDBOX_GROUP` | Sandbox group used for sandboxes, volumes, and snapshots |
| `ACA_SANDBOXGROUP_REGION` | Azure region used to select the sandbox service endpoint, such as `eastus2` |
| `ACA_DISK_IMAGE_ID` | ID of the private sandbox disk image built from `app/Dockerfile` |

Alternatively, set the values in the current PowerShell session:

```powershell
$env:AZURE_SUBSCRIPTION_ID = "<subscription-id>"
$env:ACA_RESOURCE_GROUP = "<resource-group-name>"
$env:ACA_SANDBOX_GROUP = "<sandbox-group-name>"
$env:ACA_SANDBOXGROUP_REGION = "<sandbox-group-region>"
$env:ACA_DISK_IMAGE_ID = "<private-disk-image-id>"
```

Authentication is supplied by `DefaultAzureCredential`. An existing `az login`
session is sufficient for local use. If service-principal authentication is
used instead, also set the standard `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, and
`AZURE_CLIENT_SECRET` variables.

Use any Python environment and package manager that suits your development
workflow. For example, after activating a virtual environment, install the
client dependencies with pip:

```text
python -m pip install azure-containerapps-sandbox azure-identity
```

The commands below use `python` for portability. Depending on your environment,
the interpreter command may instead be `python3`, `py`, or a managed command
such as `uv run python`.

`ANIMAL_PORT` and `ANIMAL_MOUNTPOINT` are optional service settings inside the
sandbox. They default to `8080` and `/mnt/shared`; the supplied image and client
already use those defaults, so they do not need to be set locally.

## Configure the custom disk

1. Optional: build `app/Dockerfile` and push the OCI image to a container registry.
2. In the [sandboxes portal](https://sandboxes.azure.com/), in your sandbox group, create a Disk Image using one of the following image paths:
- The image path you created in the previous step
- docker.io/gfakedocker/fakesandboxdemo1:2
3. Record the Sandbox disk image ID.

Set the resulting ID as `ACA_DISK_IMAGE_ID` in the local environment described
above.

## Run

From the repository root, run the client with your chosen Python interpreter:

```text
python client/client.py --auto-suspend-seconds 30
```

For example, the equivalent uv command is
`uv run python client/client.py --auto-suspend-seconds 30`.

To reuse the newest existing sandbox labeled
`scenario=sandbox-fundamentals`, or create one with that label when none
exists, run the client normally and accept the default sandbox-reuse and label
prompts. Answer `n` at the reuse prompt to always create a new sandbox.

For non-interactive label selection, use:

```text
python client/client.py --reuse-sandbox
```

Specify another exact label with `KEY=VALUE`:

```text
python client/client.py --reuse-sandbox scenario=my-scenario
```

A reused sandbox and its volume are not deleted when this client exits. The
replace-and-restore menu action is unavailable for reused sandboxes because
the sandbox metadata does not expose the mounted volume name. Reused sandboxes
are automatically resumed when needed and health-checked before the menu is
shown. If no matching sandbox is in a reusable state, a new one is created.

At startup, press Enter to create the sandbox directly from the configured
private disk image. To restore a snapshot instead, answer `y` and choose from
the newest-first list whose `scenario` label starts with
`sandbox-fundamentals`. Snapshot restore replays the captured sandbox and
volume configuration; the client does not create or delete that existing
volume.

Use the menu for this presentation flow:

1. Select `bird`, then get its sound, skin, and full in-memory state.
2. Stop making application calls and watch the sandbox in the portal until it
   shows `Suspended`.
3. Choose **Show sandbox lifecycle state**. This reads resource state and does
   not execute inside the sandbox.
4. Try **Get skin**. The client refuses to send `exec()` while the sandbox is
   not `Running`, avoiding an accidental implicit resume.
5. Choose **Explicitly resume sandbox**, then **Get skin**. The response should
   still be `feathers` and retain the process diagnostics.
6. Save the animal to the Blob volume, then read it back.
7. Replace the sandbox and restore from the same volume. The new service gets a
   new process identity but loads the saved animal.
8. Create a snapshot. Its labels match the active sandbox's labels, with the
   selected animal appended to `scenario`, such as
   `sandbox-fundamentals-bird`.
9. Exit to delete the sandbox and volume. The snapshot remains available.

## Test snapshot persistence

Use two client runs to prove that a snapshot can provision a new sandbox and
restore its captured configuration. Keep the first run's resources because a
snapshot records the attached volume configuration but does not copy the Blob
volume's contents into the snapshot.

1. Start the first run with resource cleanup disabled:

   ```text
   python client/client.py --keep-resources
   ```

2. Press Enter at **Start from a snapshot?**, then answer `n` when asked whether
   to reuse a sandbox so this run creates a fresh sandbox and volume.
3. Select an animal, save it to the Blob volume, and choose **Create snapshot**.
   Record the snapshot ID printed as `Snapshot ready`. Its `scenario` label
   should end with the selected animal, for example
   `sandbox-fundamentals-bird`.
4. Exit. The client prints that it is keeping the sandbox and volume.
5. Start the client again without `--keep-resources`:

   ```text
   python client/client.py
   ```

6. Answer `y` at **Start from a snapshot?** and select the recorded snapshot.
   The client should create a different sandbox ID and report `Sandbox ready`.
7. Choose **Read animal from Blob volume**. The saved animal should match the
   first run, confirming that the snapshot restored the captured volume
   attachment and that the attached Blob volume retained its data.
8. Choose **Get full in-memory state**. A newly started service is expected to
   report `"animal": null`; the selected animal is process memory and is not a
   disk-snapshot checkpoint. Use **Replace sandbox and restore from volume** to
   load the saved animal into the new process.
9. Exit to delete the sandbox created from the snapshot. Delete the retained
   first-run sandbox, Blob volume, and snapshot in the sandbox portal when the
   test is complete.

## What proves what

| Observation | Demonstrates |
|---|---|
| Same animal and process diagnostics after memory resume | In-memory session preservation |
| New sandbox reads the old checkpoint | Volume durability beyond sandbox lifetime |
| Snapshot has the sandbox's `scenario` and `run` labels | Labeled disk-state capture |

The Blob checkpoint is deliberately not loaded during resume. That keeps the
memory-resume proof independent from the durable-volume proof.

## Testing Egress policies

Curl is installed in the container disk image that the sandbox will use. If you create egress poicies on your sandbox, you can use curl from the sandbox's console to verify the effect of the egress policies (e.g. whether the request succeeds or gets denied (403)).