#!/usr/bin/env python3
"""Behavioral tests for the MangoWM configuration backend."""

from __future__ import annotations

import importlib.util
import json
import os
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from unittest import mock


REPO_ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = REPO_ROOT / ".config" / "mango" / "mango_config.py"


def load_backend():
    spec = importlib.util.spec_from_file_location("kamalen_mango_config", MODULE_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot import {MODULE_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class AtomicWriteTests(unittest.TestCase):
    def setUp(self) -> None:
        self.backend = load_backend()

    def test_atomic_write_preserves_original_if_replace_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "settings.conf"
            target.write_text("original\n", encoding="utf-8")

            with mock.patch.object(os, "replace", side_effect=OSError("replace failed")):
                with self.assertRaises(OSError):
                    self.backend.atomic_write_text(target, "replacement\n")

            self.assertEqual("original\n", target.read_text(encoding="utf-8"))
            self.assertEqual([target], list(Path(tmp).iterdir()))


class BatchWriteTests(unittest.TestCase):
    def setUp(self) -> None:
        self.backend = load_backend()
        self.tempdir = tempfile.TemporaryDirectory()
        self.config_dir = Path(self.tempdir.name)
        self.conf_dir = self.config_dir / "conf.d"
        self.conf_dir.mkdir()
        (self.config_dir / "config.conf").write_text(
            "source=./conf.d/gaps.conf\n", encoding="utf-8"
        )
        (self.conf_dir / "gaps.conf").write_text(
            "gappih=6\ngappiv=6\n", encoding="utf-8"
        )
        self.backend.CONFIG_DIR = self.config_dir
        self.backend.CONFIG_FILE = self.config_dir / "config.conf"
        self.backend.CONF_D_DIR = self.conf_dir

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def test_set_many_persists_all_values_in_one_batch_write(self) -> None:
        original_write_modules = self.backend.write_modules
        with mock.patch.object(
            self.backend, "write_modules", wraps=original_write_modules
        ) as write_modules:
            output = StringIO()
            with redirect_stdout(output):
                self.backend.cmd_set_many(
                    json.dumps({"gappih": 12, "gappiv": 14}),
                    reload_after=False,
                    apply_after=False,
                )

        self.assertEqual(1, write_modules.call_count)
        self.assertIn("gappih=12", (self.conf_dir / "gaps.conf").read_text())
        self.assertIn("gappiv=14", (self.conf_dir / "gaps.conf").read_text())
        self.assertTrue(json.loads(output.getvalue())["ok"])

    def test_write_modules_emits_mango_relative_source_syntax(self) -> None:
        self.backend.write_modules(
            {"gaps": ["gappih=6"], "borders": ["borderpx=2"]},
            ["source=./conf.d/gaps.conf"],
        )

        main = (self.config_dir / "config.conf").read_text(encoding="utf-8")
        self.assertIn("source=./conf.d/borders.conf", main)


class PersistentApplyTests(BatchWriteTests):
    def test_set_apply_persists_validates_and_reloads(self) -> None:
        output = StringIO()
        with (
            mock.patch.object(self.backend, "validate_config") as validate,
            mock.patch.object(self.backend, "mmsg_dispatch") as dispatch,
            redirect_stdout(output),
        ):
            self.backend.cmd_set_apply("gappih", "12")

        self.assertIn("gappih=12", (self.conf_dir / "gaps.conf").read_text())
        validate.assert_called_once_with()
        dispatch.assert_called_once_with(["reload_config"])
        result = json.loads(output.getvalue())
        self.assertTrue(result["ok"])
        self.assertTrue(result["persisted"])
        self.assertTrue(result["reloaded"])

    def test_set_apply_restores_persisted_value_when_reload_fails(self) -> None:
        original = (self.conf_dir / "gaps.conf").read_text(encoding="utf-8")
        output = StringIO()
        with (
            mock.patch.object(self.backend, "validate_config"),
            mock.patch.object(
                self.backend,
                "mmsg_dispatch",
                side_effect=RuntimeError("reload failed"),
            ) as dispatch,
            redirect_stdout(output),
            self.assertRaises(SystemExit),
        ):
            self.backend.cmd_set_apply("gappih", "12")

        self.assertEqual(original, (self.conf_dir / "gaps.conf").read_text())
        self.assertEqual(2, dispatch.call_count)
        self.assertIn("reload failed", json.loads(output.getvalue())["error"])


if __name__ == "__main__":
    unittest.main()
