# Architecture

Kamalen Shell is a local Wayland desktop configuration. It has no application server: Quickshell QML processes, MangoWM, and a small set of Python/shell helpers communicate through local commands, files, and IPC.

## Runtime layers

| Layer | Location | Responsibility |
| --- | --- | --- |
| Window manager | `.config/mango/` | MangoWM options, bindings, rules, monitors, and autostart. |
| Desktop shell | `.config/quickshell/` | Bar, transient Dashboard, standalone Settings window, launcher, wallpapers, notifications, lock screen, and global QML state. |
| Shared visual state | `Colors.qml`, `UIState.qml`, `Animations.qml`, `Metrics.qml`, `Skins.qml` | Effective palette, persisted presentation settings, animation profiles, scaling, and material recipes. |
| Mango configuration bridge | `MangoConfig.qml`, `mango_config.py` | Queued, confirmed configuration writes, directive edits, and safe monitor previews. |
| Integration helpers | Python and shell helpers | Palette extraction/resolution, GTK generation, notification stream, local IPC, process supervision, and wallpaper providers. |
| Verification | `tests/` | Regression tests for installer behavior, configuration layout, QML invariants, and security-sensitive flows. |

## Data flows

```text
Wallpaper selection
  -> iris.py extracts the source palette
  -> theme_engine.py resolves the effective automatic/adaptive/fixed palette
  -> Colors/UIState update Quickshell and MangoWM borders
  -> gtk_theme.py, Neovim, Kitty, Starship, and optional SDDM receive generated colors

Settings control
  -> UIState or MangoConfig
  -> queued mango_config.py write/apply operation
  -> validation, compositor apply/reload, backend confirmation or visible error

Transient layer action
  -> UIState.closeTransientSurfaces()
  -> one active overlay with Escape/outside-dismiss handling
```

## Configuration boundaries

- `.config/mango/config.conf` is source-only. Category files live in `.config/mango/conf.d/`.
- `.config/quickshell/qmldir` registers QML singletons and reusable components.
- Files under `state/` are generated runtime data and are intentionally ignored by Git.
- Generated GTK files live under `~/.config/gtk-{3,4}.0/`; their source is `gtk_theme.py`, not the generated CSS.
- The Dashboard is intentionally limited to Quick, Media, and System. Persistent configuration lives in `SettingsWindow.qml`.
- Skins own material and geometry, not the color source. See [ADR-001](decisions/ADR-001-adaptive-skins.md).
- `nix port tests/` is a separate experimental flake; it does not replace the Arch-oriented installer.

## Documentation

- `docs/archive/specs/` records historical requirements.
- `docs/archive/plans/` records completed or superseded plans.
- `docs/archive/reviews/` contains point-in-time review evidence.
- `docs/archive/quickshell/` preserves Dynamic Island research and design notes.
- `docs/decisions/` records accepted architecture decisions that remain current.
