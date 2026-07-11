#!/usr/bin/env python3
"""Repository-level regression tests for Kamalen Shell configuration."""

from __future__ import annotations

import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MANGO_DIR = REPO_ROOT / ".config" / "mango"
MAIN_CONFIG = MANGO_DIR / "config.conf"


def active_lines(path: Path) -> list[str]:
    """Return non-empty, non-comment configuration lines."""
    return [
        line.strip()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]


class MangoConfigLayoutTests(unittest.TestCase):
    def test_main_config_is_source_only(self) -> None:
        """The root config must not duplicate options owned by conf.d."""
        lines = active_lines(MAIN_CONFIG)

        self.assertTrue(lines, "config.conf must source at least one module")
        self.assertTrue(
            all(line.startswith("source=") for line in lines),
            "config.conf must contain only source= directives",
        )

    def test_every_source_target_exists(self) -> None:
        """Every source declared by config.conf must resolve inside mango/."""
        sources = [
            line.split("=", 1)[1].strip()
            for line in active_lines(MAIN_CONFIG)
            if line.startswith("source=")
        ]

        missing = [source for source in sources if not (MANGO_DIR / source).is_file()]
        self.assertEqual([], missing, f"missing sourced modules: {missing}")

    def test_relative_sources_use_mango_supported_prefix(self) -> None:
        """Mango only resolves relative includes when they start with ./ ."""
        sources = [
            line.split("=", 1)[1].strip()
            for line in active_lines(MAIN_CONFIG)
            if line.startswith("source=")
        ]

        invalid = [source for source in sources if not source.startswith("./")]
        self.assertEqual([], invalid, f"non-portable relative sources: {invalid}")

    def test_sources_are_unique(self) -> None:
        """A module must not be loaded more than once."""
        sources = [
            line.split("=", 1)[1].strip()
            for line in active_lines(MAIN_CONFIG)
            if line.startswith("source=")
        ]

        self.assertEqual(len(sources), len(set(sources)), "duplicate source= entries")


class RepositoryHygieneTests(unittest.TestCase):
    def test_temporary_patch_and_backup_artifacts_are_not_kept(self) -> None:
        forbidden = [
            REPO_ROOT / "patch.diff",
            REPO_ROOT / ".config" / "quickshell" / "DynamicIsland.qml.bak",
        ]
        present = [str(path.relative_to(REPO_ROOT)) for path in forbidden if path.exists()]
        self.assertEqual([], present, f"temporary artifacts still present: {present}")


if __name__ == "__main__":
    unittest.main()
