#!/usr/bin/env python3
"""Multiplex Kamalen Shell's file-based IPC triggers through one inotify fd."""

from __future__ import annotations

import ctypes
import os
import signal
import struct
import sys
import time
from collections import defaultdict
from collections.abc import Sequence
from pathlib import Path


IN_ATTRIB = 0x00000004
IN_CLOSE_WRITE = 0x00000008
IN_MOVED_TO = 0x00000080
IN_CREATE = 0x00000100
WATCH_MASK = IN_ATTRIB | IN_CLOSE_WRITE | IN_MOVED_TO | IN_CREATE
EVENT_HEADER = struct.Struct("iIII")
DEBOUNCE_SECONDS = 0.12
PR_SET_PDEATHSIG = 1


def set_parent_death_signal(sig: int = signal.SIGTERM) -> None:
    parent = os.getppid()
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.prctl(PR_SET_PDEATHSIG, sig, 0, 0, 0) != 0:
        error = ctypes.get_errno()
        raise OSError(error, os.strerror(error))
    if os.getppid() != parent:
        os.kill(os.getpid(), sig)


def parse_specs(arguments: Sequence[str]) -> dict[str, Path]:
    specs: dict[str, Path] = {}
    for argument in arguments:
        key, separator, raw_path = argument.partition("=")
        if not separator or not key or not raw_path:
            raise ValueError(f"invalid event specification: {argument!r}")
        specs[key] = Path(raw_path).expanduser().resolve(strict=False)
    if not specs:
        raise ValueError("at least one name=path event specification is required")
    return specs


def run(specs: dict[str, Path]) -> None:
    set_parent_death_signal()
    libc = ctypes.CDLL(None, use_errno=True)
    fd = libc.inotify_init1(os.O_CLOEXEC)
    if fd < 0:
        error = ctypes.get_errno()
        raise OSError(error, os.strerror(error))

    watched: dict[int, dict[str, list[str]]] = {}
    grouped: dict[Path, dict[str, list[str]]] = defaultdict(lambda: defaultdict(list))
    for key, path in specs.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.touch(exist_ok=True)
        grouped[path.parent][path.name].append(key)

    try:
        for directory, names in grouped.items():
            encoded = os.fsencode(directory)
            wd = libc.inotify_add_watch(fd, ctypes.c_char_p(encoded), WATCH_MASK)
            if wd < 0:
                error = ctypes.get_errno()
                raise OSError(error, f"{directory}: {os.strerror(error)}")
            watched[wd] = names

        print("READY", flush=True)
        last_emitted: dict[str, float] = {}
        while True:
            payload = os.read(fd, 65536)
            offset = 0
            while offset + EVENT_HEADER.size <= len(payload):
                wd, mask, _cookie, name_length = EVENT_HEADER.unpack_from(payload, offset)
                offset += EVENT_HEADER.size
                raw_name = payload[offset:offset + name_length]
                offset += name_length
                name = os.fsdecode(raw_name.split(b"\0", 1)[0])
                if not (mask & WATCH_MASK):
                    continue
                now = time.monotonic()
                for key in watched.get(wd, {}).get(name, []):
                    if now - last_emitted.get(key, 0.0) < DEBOUNCE_SECONDS:
                        continue
                    last_emitted[key] = now
                    print(key, flush=True)
    finally:
        os.close(fd)


def main(argv: Sequence[str]) -> int:
    try:
        run(parse_specs(argv))
    except (OSError, ValueError) as error:
        print(f"ipc-bridge: {error}", file=sys.stderr, flush=True)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
