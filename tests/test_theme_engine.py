#!/usr/bin/env python3
"""Behavioral tests for Kamalen's effective palette resolver."""

from __future__ import annotations

import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / ".config" / "quickshell" / "theme_engine.py"


def load_engine():
    spec = importlib.util.spec_from_file_location("kamalen_theme_engine", MODULE_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot import {MODULE_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ThemeEngineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.engine = load_engine()
        self.wallpaper = {
            "bg": "#101820", "surface": "#182430", "fg": "#f0f4f8", "dim": "#708090",
            "accent": "#00aaff", "red": "#ee3355", "green": "#33cc66", "yellow": "#ffcc33",
            "syntax_keyword": "#11aaff", "dark": True, "tone_l": 0.2,
        }

    def test_auto_keeps_the_complete_wallpaper_palette(self) -> None:
        result = self.engine.resolve_palette(self.wallpaper, "auto", "catppuccin", True)
        self.assertEqual(self.wallpaper, result)

    def test_adaptive_uses_preset_neutrals_and_wallpaper_accents(self) -> None:
        result = self.engine.resolve_palette(self.wallpaper, "adaptive-preset", "nord", True)
        nord = self.engine.PRESETS["nord"]["dark"]
        for role in ("bg", "surface", "fg", "dim"):
            self.assertEqual(nord[role], result[role])
        for role in ("accent", "red", "green", "yellow", "syntax_keyword"):
            self.assertEqual(self.wallpaper[role], result[role])
        self.assertTrue(result["dark"])

    def test_fixed_palette_ignores_wallpaper_and_has_light_variant(self) -> None:
        result = self.engine.resolve_palette(self.wallpaper, "fixed-preset", "solarized", False)
        self.assertEqual(self.engine.PRESETS["solarized"]["light"], result)
        self.assertFalse(result["dark"])
        self.assertNotEqual(self.wallpaper["accent"], result["accent"])

    def test_unknown_mode_and_preset_have_bounded_fallbacks(self) -> None:
        auto = self.engine.resolve_palette(self.wallpaper, "broken", "missing", True)
        fixed = self.engine.resolve_palette(self.wallpaper, "fixed-preset", "missing", True)
        self.assertEqual(self.wallpaper, auto)
        self.assertEqual(self.engine.PRESETS["catppuccin"]["dark"], fixed)

    def test_publish_is_atomic_and_leaves_no_temporary_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "current-palette.json"
            self.engine.publish_palette(target, self.wallpaper)
            self.engine.publish_palette(target, {**self.wallpaper, "accent": "#abcdef"})
            self.assertEqual("#abcdef", json.loads(target.read_text())["accent"])
            self.assertEqual([], list(target.parent.glob(".current-palette.*")))


if __name__ == "__main__":
    unittest.main()
