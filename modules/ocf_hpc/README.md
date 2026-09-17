# OCF HPC GPU diagnostics

The `ocf_hpc` module configures Slurm and its compute nodes. A successful
`nvidia-smi` query establishes management access, but does not prove that the
CUDA driver can initialize. Package versions, runtime driver availability,
and successful application execution answer different questions.

## Manual host diagnostic

Puppet installs `/usr/local/sbin/check-ocf-gpu-readiness` on compute nodes.
An administrator runs it directly on the host after maintenance or when
investigating a CUDA failure:

```console
sudo /usr/local/sbin/check-ocf-gpu-readiness --compact
sudo /usr/local/sbin/check-ocf-gpu-readiness --expected-gpus N
```

Replace `N` with the administrator-confirmed physical GPU inventory, not a
historical documentation count. Run with unrestricted host device visibility
and without `CUDA_VISIBLE_DEVICES` restrictions, outside containers and Slurm
device cgroups. Restricted views can legitimately disagree with host inventory
and will fail this diagnostic; this command does not validate allocation views.

The report checks NVIDIA inventory, loaded `nvidia`/`nvidia_uvm` modules,
control/UVM character devices, physical GPU device indices, and CUDA driver
initialization and device count. NVIDIA indices must match the physical device
indices, and CUDA must report the same positive count. With `--expected-gpus`,
that count must also equal the supplied inventory. UVM-tools device presence
is optional. Package inventory (including `libcuda1`) is diagnostic information
and cannot turn an otherwise passing check into a failure.

The existing JSON fields `schema_version`, `ready`, `checks`, and `diagnostics`
are retained. `scope` is `basic_cuda_driver`; `expected_gpu_count` is the
supplied integer or `null`. Exit status is 0 when all required checks pass,
1 when a required check fails or is inconclusive, and 2 for invalid arguments.
`--compact` writes one JSON line. Operational failures are reported as data.

Each external command and the isolated CUDA child has a ten-second timeout.
The parent kills and reaps a timed-out child and reports crashes or malformed
child output as failed checks. Commands run sequentially, so the total can
exceed ten seconds. CUDA library loading occurs only in that child; the
private `--cuda-worker` entry point is not an operator interface.

`ready: true` means only basic driver availability in this host view. Matching
counts do not prove per-GPU identity correspondence, free memory, successful
allocation/computation, framework compatibility, or Slurm configuration.
Without an expected count, this cannot detect hardware absent from every
discovery method. A separate Slurm workload canary is required before reopening
a node after maintenance. The probe performs no explicit package, module,
scheduler, reset, or reboot changes; driver initialization may affect transient
module/device state. Module and device snapshots are therefore taken afterward.

## Hardware-independent development tests

```console
python3 -m unittest discover -s modules/ocf_hpc/tests -p 'test_*.py' -v
```

The pre-commit hook runs this unit suite, **not the live host diagnostic**.
Hardware tests replace command responses, device metadata, and CUDA functions
with fakes, and forbid accidental real command execution or CUDA loading.
One process-lifecycle test launches a sleeping local Python child to check
timeout cleanup. No test requires an NVIDIA GPU, driver, Slurm, or OCF access.
The code uses Python 3.7-compatible standard-library APIs.

Unit tests verify logic; they do not demonstrate deployment or host health.
Follow the repository's personal Puppet environment procedure and review the
Jenkins/octocatalog diff before deployment. The expected catalog addition is
the diagnostic file on `ocf_hpc::compute` hosts. Scheduling policy, driver
packages, and existing UVM startup configuration are unchanged.

## Driver or kernel maintenance

An OCF administrator performs these steps:

1. Drain the affected node and wait for **all** jobs and cleanup steps to finish.
   Drain blocks new jobs but does not stop existing jobs. Confirm no allocation
   remains with `squeue -w corruption` and `scontrol show node corruption`.
2. Capture the running kernel, GPU inventory, loaded modules, device nodes,
   package versions/sources, kernel logs, and diagnostic report. A failing
   pre-maintenance report is useful evidence; it does not prevent repair.
3. Use a coherent kernel/NVIDIA package set through the approved package source.
   Confirm matching kernel headers and successful DKMS compilation before
   reboot. Avoid mixing distribution packages, NVIDIA repositories, and runfiles.
4. Reboot when needed, then confirm the node is still excluded from ordinary
   scheduling. Run the manual host diagnostic with the confirmed expected count.
5. Complete **Controlled return to service** below. A drained node cannot start
   a new Slurm canary; the reservation is what protects the canary window after
   the drain is cleared.

If rollback is necessary, restore the tested kernel, modules, driver libraries,
and package-source policy together. A package-version assertion can enforce
that policy, but does not replace runtime initialization or workload checks.
See [NVIDIA's driver installation guide](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/latest/index.html).

## Unexplained GPU memory

Memory assigned to an absent PID is a stale-context candidate, not a proven
root cause. Correlate GPU UUIDs, Slurm ownership, and host process visibility
before intervention. An ordinary user's missing `/proc` entry is insufficient.

Capture `squeue -w corruption`, `scontrol show node corruption`, `nvidia-smi`,
NVIDIA compute-process accounting, and `nvidia-smi pmon -c 1`. Have an
administrator check the reported PID with `ps`, inspect `/dev/nvidia*` users
with `fuser`/`lsof`, and examine `nvidia-persistenced` and kernel NVIDIA/Xid logs.

Drain the node and wait for all existing jobs and cleanup to finish before
host-level recovery. Do not terminate unknown processes. Only after excluding
live owners and peer/display dependencies may an administrator attempt a reset
of the affected GPU by UUID. If isolated reset is unsupported or ineffective,
use a planned reboot of the drained, idle node. Restarting persistence service
alone does not demonstrate that a stale context was released.

After reset or reboot, verify the expected idle memory baseline and run the
host diagnostic, then use the same controlled return procedure below. Record
the evidence, action taken, and outcome; do not assume a particular root cause
from the initial symptom.

## Controlled return to service

This is an administrator procedure, not automation performed by the probe.
Use an explicitly named whole-node maintenance reservation restricted to the
administrator running the canary. Keep it active until the recovery decision;
automatic expiry must not expose an unvalidated node to ordinary jobs.

After the node is drained, idle, and passing direct host checks, create and
inspect the reservation. Replace `ADMIN` with the chosen administrator's Slurm
user; use a unique reservation name if the example name is already occupied:

```console
sudo scontrol create reservation ReservationName=hpc_gpu_validation \
  StartTime=now Duration=infinite Flags=MAINT Nodes=corruption Users=ADMIN
scontrol show reservation hpc_gpu_validation
scontrol show node corruption
```

Confirm the reservation is active, covers the entire node, and grants access
only to the intended administrator (privileged Slurm operators retain their
normal administrative authority). If creation or verification fails, leave the
node drained. Once the reservation is confirmed, clear the drain:

```console
sudo scontrol update NodeName=corruption State=RESUME
```

The node can now run canary jobs inside the reservation while ordinary jobs
remain excluded. As `ADMIN`, request all `N` expected GPUs and use an existing,
administrator-approved GPU environment. For example, a maintained PyTorch
environment can run this small allocation, computation, and synchronization:

```console
srun --reservation=hpc_gpu_validation --nodelist=corruption --nodes=1 \
  --gres=gpu:N --time=00:05:00 /path/to/approved/environment/bin/python -c '
import sys
import torch
assert torch.cuda.device_count() == int(sys.argv[1])
for index in range(torch.cuda.device_count()):
    x = torch.ones((128, 128), device="cuda:" + str(index))
    y = x @ x
    torch.cuda.synchronize(index)
    assert bool(torch.all(y == 128).item())
    del x, y
print("All allocated GPUs passed the computation canary")
' N
```

Substitute the approved environment path and confirmed `N` in both places.
Record job ID and exit status. After the job and its processes finish, require
memory to return to the expected idle baseline on every GPU and inspect kernel
logs for new NVIDIA Xid errors. A failed or inconclusive check means recovery
has not passed.

- **Success:** record the host report, canary result, memory-release checks,
  and logs, then delete the reservation to admit ordinary jobs.
- **Failure or interrupted validation:** re-drain the node first, finish or
  cancel only the administrator's canary, and verify the drain before deleting
  the reservation. Keep the reservation if the drain cannot be confirmed.

```console
# Failure path only; do this BEFORE releasing the reservation:
sudo scontrol update NodeName=corruption State=DRAIN Reason="GPU validation incomplete"
# After success, or confirmed drain and canary cleanup on failure:
sudo scontrol delete ReservationName=hpc_gpu_validation
```

The administrator owns explicit cleanup of this non-expiring reservation.
See [Slurm maintenance reservations](https://slurm.schedmd.com/reservations.html)
and [node state transitions](https://slurm.schedmd.com/scontrol.html).
