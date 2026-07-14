# ADR-001: Keep skins separate from the automatic color source

## Status

Accepted — 2026-07-14

## Context

Kamalen originally exposed geometric presets such as rounding and animation
profiles. The shell now needs richer visual languages — including Aqua 2009 and
Skeuos Workshop — while preserving its defining behavior: a wallpaper change
updates the shell, MangoWM borders, GTK, terminal tooling, and SDDM assets.

A skin that hardcodes colors would conflict with that behavior. A single global
texture would also flatten distinct surfaces and made the first Skeuos prototype
look like Commonality with decorative studs.

## Decision

Skins define **geometry and material recipes**, while the theme engine remains
the source of effective colors. Each recipe owns radii, bevels, texture sources,
gloss, line work, control density, and Mango border radius. Colors are derived
from `Colors` at render time.

Skeuos resolves semantic `wood`, `paper`, and `metal` roles. Aqua uses
brushed/glass materials. Suggestions such as Nord or Gruvbox are opt-in
appearance recommendations, not automatic color-mode changes.

GTK receives generated color and material layers from the same effective palette.
The root GTK CSS remains an import shim so legacy managed definitions cannot
override the current palette. Titlebars and docks are excluded from this decision.

## Alternatives considered

### Fixed color themes per skin

Rejected because they break wallpaper adaptation and make Shell, MangoWM, GTK,
and terminal output diverge.

### One texture applied to every surface

Rejected because it weakens hierarchy and does not communicate different material
roles.

### Implement window chrome alongside skins

Rejected because titlebars and docks have independent behavior, scope, and
accessibility requirements.

## Consequences

- Adding a skin requires a distinct recipe, palette-adaptive GTK treatment,
  targeted tests, and visual review.
- Preview components must render the requested skin instead of inheriting the
  currently active one.
- GTK generation must preserve user CSS while replacing only Kamalen-managed
  semantic colors.
- The automatic color path remains the default and remains testable independently
  of a chosen skin.
