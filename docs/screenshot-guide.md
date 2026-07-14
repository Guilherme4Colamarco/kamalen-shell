# Screenshot guide

The goal is to show the shell's behavior and design system, not merely a
wallpaper. Capture at native resolution, hide personal notifications and private
files, and use a clean demo workspace when possible.

## Recommended set

| File | Scene | What it proves |
| --- | --- | --- |
| `01-bar-pill.png` | Clean desktop with the pill bar visible. | Tags, system indicators, dynamic adaptive border, and the default bar shape. |
| `02-dashboard-quick.png` | Dashboard on **Quick** with a few useful tiles and no modal over it. | The transient dashboard, density, and daily controls. |
| `03-settings-appearance.png` | Settings → Appearance with the four skin previews and color mode visible. | The skin system, optional palette suggestions, scale, motion, and blur controls. |
| `04-settings-monitors.png` | Settings → Monitors after detection; include the arrangement diagram and preview affordance. | GNOME-like monitor workflow and safe preview design. |
| `05-aqua-gtk.png` | Aqua 2009 active beside a GTK application such as Thunar. | Shell/GTK material continuity with the wallpaper-adaptive palette. |
| `06-skeuos-gtk.png` | Skeuos Workshop active beside the same GTK application. | Wood/paper/metal roles and a materially distinct skin. |
| `07-keyboard-flow.gif` | Short recording: `Super + ,`, `Ctrl+Tab`, optional `j/k`, then `Esc`. | Keyboard-first Settings navigation. |
| `08-layer-dismiss.gif` | Short recording: open Dashboard, click outside it, then open another overlay. | Outside dismissal and mutually exclusive transient layers. |

Do not fabricate a dual-monitor layout for `04-settings-monitors.png`. If only
one output is connected, capture the real single-output diagram now and record
the multi-monitor scene only on hardware that can validate it.

## Capture commands

The default bindings already support the needed captures:

| Input | Result |
| --- | --- |
| `Print` | Full-screen PNG in `~/screenshots/`. |
| `Shift + Print` | Selected-area PNG. |
| `Ctrl + Print` | Full screen copied to the clipboard. |
| `Ctrl + Shift + Print` | Selected area copied to the clipboard. |
| `Super + R` | Start a screen recording. |
| `Super + Shift + R` | Stop and save the recording. |

## Framing checklist

1. Use a wallpaper with enough contrast to show adaptive color without obscuring
   the shell.
2. Keep the cursor away from controls unless hover state is the feature being
   demonstrated.
3. Prefer one focused feature per image; use GIF/video for transitions.
4. Crop only to remove irrelevant desktop area, never to hide an important
   interaction or imply a different monitor topology.
5. Before publishing, remove paths, notifications, account names, and temporary
   debug windows that reveal personal data.

When the images are ready, store optimized assets under `docs/assets/screenshots/`
and link them from both READMEs. Do not commit raw recordings or oversized
wallpapers.
