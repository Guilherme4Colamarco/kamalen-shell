#!/usr/bin/env python3
"""Tests for generated Kamalen GTK color and aesthetic styles."""

from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = REPO_ROOT / ".config" / "quickshell" / "gtk_theme.py"


def load_helper():
    spec = importlib.util.spec_from_file_location("kamalen_gtk_theme", MODULE_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot import {MODULE_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class GtkThemeTests(unittest.TestCase):
    def setUp(self) -> None:
        self.helper = load_helper()
        self.palette = {
            "accent": "#cba6f7", "bg": "#1e1e2e", "fg": "#cdd6f4",
            "surface": "#313244", "dim": "#6c7086", "red": "#f38ba8",
            "green": "#a6e3a1", "yellow": "#f9e2af",
        }

    def test_commonality_material_is_complete_and_has_no_window_chrome(self) -> None:
        css = self.helper.material_css("commonality", 4, self.palette)
        self.assertIn("linear-gradient", css)
        self.assertIn("border-radius: 0px", css)
        self.assertIn("box-shadow:", css)
        self.assertIn("progressbar", css)
        self.assertIn("scale slider", css)
        self.assertIn("switch slider", css)
        self.assertNotIn("headerbar", css)
        self.assertNotIn("titlebar", css)
        self.assertNotIn("dock", css)

    def test_write_theme_preserves_user_css_and_imports_once(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            for version in (3, 4):
                folder = base / f"gtk-{version}.0"
                folder.mkdir()
                (folder / "gtk.css").write_text("/* user rule */\nbutton.custom { color: red; }\n")

            self.helper.write_theme(base, self.palette, "commonality")
            self.helper.write_theme(base, self.palette, "commonality")

            for version in (3, 4):
                folder = base / f"gtk-{version}.0"
                root = (folder / "gtk.css").read_text()
                self.assertIn("button.custom", root)
                self.assertEqual(1, root.count('kamalen-colors.css'))
                self.assertEqual(1, root.count('kamalen-material.css'))
                self.assertNotIn('kamalen-aesthetic.css', root)
                self.assertTrue((folder / "kamalen-colors.css").exists())
                self.assertIn("border-radius: 0px", (folder / "kamalen-material.css").read_text())


if __name__ == "__main__":
    unittest.main()
