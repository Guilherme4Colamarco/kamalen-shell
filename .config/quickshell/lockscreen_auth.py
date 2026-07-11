#!/usr/bin/env python3
"""Authenticate a lockscreen password through PAM without exposing it in argv."""

from __future__ import annotations

import sys


def authenticate(pam_client, username: str, password: str) -> bool:
    """Forward credentials to the configured PAM lockscreen service."""
    return bool(pam_client.authenticate(username, password, service="lockscreen"))


def main() -> int:
    if len(sys.argv) != 2 or not sys.argv[1]:
        return 2

    try:
        import pam
    except ImportError:
        return 2

    password = sys.stdin.readline()
    if password.endswith("\n"):
        password = password[:-1]
    if password.endswith("\r"):
        password = password[:-1]

    try:
        return 0 if authenticate(pam.pam(), sys.argv[1], password) else 1
    except Exception:
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
