# Changelog

## Unreleased

- Renamed the extension and repository to **Unity Importer Plugin for Unity**.
- Added a status-bar notice for `.ase` and `.aseprite` assets managed by Unity's 2D Aseprite Importer.
- Detects resolved lock-file, direct manifest, and embedded `com.unity.2d.aseprite` package installations.

## 1.3.2 - 2026-07-31

- Added automated source validation and deterministic extension packaging.
- Added tag-driven GitHub Releases with immutable asset verification.
- Added repository badges for CI, releases, downloads, and licensing.

## 1.3.1 - 2026-02-09

- Added layer popup action **Dont Import to Unity** for non-managed layers.
- Marked excluded layers with metadata value `DontImportToUnity`.
- Added visual dimming for excluded layers to make Unity exclusion obvious in timeline/layer UI.
- Intercepted Layer Properties on excluded layers to prompt re-enabling Unity import, which clears metadata and restores full opacity.

## 1.3.0 - 2026-02-07

- Renamed and standardized plugin branding to **Unity Animation Event**.
- Added event editor popup for cel double-click on the managed `Events` layer.
- Added dedicated **Edit Unity Animation Event** command.
- Added **Import @Tags to Unity Animation Events** whole-file command with default shortcut `Ctrl+Alt+I`.
- Added **Make Duplicate Tags Unique** whole-file command with default shortcut `Ctrl+Alt+U`.
- Added **Migrate event:MyMethod to Current Format** command with default shortcut `Ctrl+Alt+M`.
- Added duplicate-tag analyzer popup with confirmation and guaranteed unique rename pass.
- Added toggleable setting to delete source `@tags` after import.
- Added settings toggles:
  - Warn before overwrite
  - Enable/disable double-click editor
  - UI language selection with auto mode
- Added multilingual UI text support (`en`, `es`, `sv`, `fr`, `de`, `pt`).
- Added `my_keys.aseprite-keys` default shortcut mappings.
- Improved package metadata for publishable distribution.
- Added README and changelog documentation.

## 1.2.0

- Added managed event editing workflow and stricter event layer enforcement.

## 1.1

- Initial public script packaging and event color workflow.
