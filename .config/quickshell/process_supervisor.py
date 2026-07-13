#!/usr/bin/env python3
"""Run one long-lived shell helper and clean up its whole process group."""

from __future__ import annotations

import ctypes
import os
import signal
import subprocess
import sys
import time
from collections.abc import Sequence


PR_SET_PDEATHSIG = 1
TERMINATION_GRACE_SECONDS = 1.5


def set_parent_death_signal(sig: int = signal.SIGTERM) -> None:
    """Ask Linux to signal this process if its current parent disappears."""
    parent = os.getppid()
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.prctl(PR_SET_PDEATHSIG, sig, 0, 0, 0) != 0:
        error = ctypes.get_errno()
        raise OSError(error, os.strerror(error))
    if os.getppid() != parent:
        os.kill(os.getpid(), sig)


def terminate_process_group(proc: subprocess.Popen[bytes], grace: float = TERMINATION_GRACE_SECONDS) -> None:
    """Terminate the supervised command and every descendant in its group."""
    try:
        os.killpg(proc.pid, signal.SIGTERM)
    except ProcessLookupError:
        return

    deadline = time.monotonic() + grace
    while proc.poll() is None and time.monotonic() < deadline:
        time.sleep(0.03)
    if proc.poll() is None:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass


def run(command: Sequence[str]) -> int:
    if not command:
        raise ValueError("missing command after --")

    set_parent_death_signal()
    proc = subprocess.Popen(command, start_new_session=True)
    stopping = False

    def stop(_signum: int, _frame: object) -> None:
        nonlocal stopping
        if stopping:
            return
        stopping = True
        terminate_process_group(proc)

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGHUP, stop)

    try:
        return proc.wait()
    finally:
        terminate_process_group(proc, grace=0.15)


def main(argv: Sequence[str]) -> int:
    args = list(argv)
    if args and args[0] == "--":
        args.pop(0)
    try:
        return run(args)
    except (OSError, ValueError) as error:
        print(f"process-supervisor: {error}", file=sys.stderr, flush=True)
        return 127


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
