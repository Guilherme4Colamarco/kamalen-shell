#!/usr/bin/env python3
"""Small atomic state writer used by QML singletons."""

from __future__ import annotations

import json
import os
import sys
import tempfile
from collections.abc import Mapping, Sequence
from pathlib import Path
from typing import Any


def write_text_atomic(path: str | Path, content: str) -> None:
    target = Path(path).expanduser()
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{target.name}.", dir=target.parent, text=True
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary, 0o600)
        os.replace(temporary, target)
        directory_fd = os.open(target.parent, os.O_RDONLY | os.O_DIRECTORY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    finally:
        temporary.unlink(missing_ok=True)


def write_json_atomic(path: str | Path, value: Mapping[str, Any]) -> None:
    write_text_atomic(path, json.dumps(value, ensure_ascii=False, separators=(",", ":")))


def main(argv: Sequence[str]) -> int:
    if len(argv) != 3 or argv[0] != "write-json":
        print("usage: state_store.py write-json PATH JSON", file=sys.stderr)
        return 2
    try:
        value = json.loads(argv[2])
        if not isinstance(value, dict):
            raise ValueError("state root must be a JSON object")
        write_json_atomic(argv[1], value)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"state-store: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
