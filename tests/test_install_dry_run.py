#!/usr/bin/env python3
"""Regression tests for install.sh dry-run behavior."""

from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
INSTALL_SCRIPT = REPO_ROOT / "install.sh"


class InstallDryRunTests(unittest.TestCase):
    def run_installer(self, *args: str) -> subprocess.CompletedProcess[str]:
        script = INSTALL_SCRIPT.read_text(encoding="utf-8")
        main_call = 'main "$@"'
        self.assertTrue(script.rstrip().endswith(main_call))
        script = script.rstrip()[: -len(main_call)]

        quoted_args = " ".join(f"'{arg}'" for arg in args)
        harness = f"""{script}
preflight() {{ AUR_HELPER=yay; }}
main {quoted_args}
"""

        with tempfile.TemporaryDirectory() as home:
            wallpapers = Path(home) / "wallpapers"
            wallpapers.mkdir()
            for index in range(1_000):
                (wallpapers / f"wallpaper-{index:04d}-{'x' * 80}.jpg").touch()
            harness_path = Path(home) / "install-harness.sh"
            harness_path.write_text(harness, encoding="utf-8")
            return subprocess.run(
                ["bash", str(harness_path)],
                text=True,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                env={"HOME": home, "PATH": "/usr/bin:/bin"},
                check=False,
            )

    def test_dry_run_without_stdin_succeeds(self) -> None:
        result = self.run_installer("--dry-run")

        self.assertEqual(0, result.returncode, result.stdout)

    def test_dry_run_mango_does_not_enter_uncloned_directory(self) -> None:
        result = self.run_installer("--dry-run", "mango")

        self.assertEqual(0, result.returncode, result.stdout)
        self.assertNotIn("No such file or directory", result.stdout)


if __name__ == "__main__":
    unittest.main()
