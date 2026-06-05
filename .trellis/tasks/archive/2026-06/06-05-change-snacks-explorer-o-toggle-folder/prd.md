# change-snacks-explorer-o-toggle-folder

## Goal

Change the Snacks explorer internal `o` key behavior so pressing `o` on a directory opens/closes that folder instead of opening the item with the system application. Also disable the Snacks picker/explorer `q` quit behavior for the explorer scenario.

## What I already know

- The user requested: `snacks explorer 把快捷键o改成打开/关闭文件夹`.
- The user added a follow-up request to remove Snacks' `q` quit behavior.
- Current project routes Snacks explorer setup through `lua/plugins/snacks.lua` and helper options through `lua/plugins/snacks/explorer.lua`.
- Upstream Snacks explorer list keymaps currently bind `o` to `explorer_open`, which opens the item with the system application.
- Upstream Snacks explorer already binds `l` to `confirm`; `confirm` toggles directories via the explorer tree and opens files normally.
- Upstream Snacks picker defaults bind `q` to `cancel` on the input, list, and preview windows; this is a picker-wide default, not an explorer-only default.
- Snacks window key tables support disabling a key by setting the key entry to `false`, for example `keys = { q = false }`.
- Project frontend quality guidelines explicitly allow overriding Snacks explorer internal picker/list keymaps when a task explicitly asks for it.

## Requirements

- Override Snacks explorer list key `o` to use the existing `confirm` action.
- Disable Snacks explorer's inherited `q` quit/cancel behavior for the explorer source.
- Keep the change scoped to Snacks explorer configuration.
- Do not globally disable `q` for all Snacks pickers unless required by implementation; prefer the minimal explorer source override.
- Do not add custom duplicated tree-toggle logic when the existing Snacks `confirm` action already implements directory toggle behavior.
- Preserve existing `<leader>e` explorer entrypoint and other Snacks explorer options.

## Acceptance Criteria

- [ ] `lua/plugins/snacks/explorer.lua` configures explorer picker list key `o` as `confirm`.
- [ ] `lua/plugins/snacks/explorer.lua` configures explorer picker `q` keys as disabled for the explorer source.
- [ ] Pressing `o` on a directory in Snacks explorer opens/closes that directory.
- [ ] Pressing `q` in the Snacks explorer picker does not quit/cancel the explorer.
- [ ] Neovim headless startup succeeds.
- [ ] The Snacks explorer helper module still exposes `open` and enabled `options()`.

## Definition of Done

- Headless startup check passes where Neovim is available.
- No unrelated keymaps/options are changed.
- Trellis task context is curated and task is activated before implementation.

## Technical Approach

Use `opts.picker.sources.explorer.win.list.keys` in the existing Snacks config helper to override only the upstream `o` mapping, and use source-scoped picker window key overrides to disable the inherited `q` cancel key for the explorer source:

```lua
picker = {
  sources = {
    explorer = {
      win = {
        input = {
          keys = {
            ["q"] = false,
          },
        },
        list = {
          keys = {
            ["o"] = "confirm",
            ["q"] = false,
          },
        },
        preview = {
          keys = {
            ["q"] = false,
          },
        },
      },
    },
  },
}
```

This reuses Snacks' existing `confirm` action instead of writing local tree-state logic. The `q` override is source-scoped under `sources.explorer` because upstream defines `q = "cancel"` as a picker-wide default for input/list/preview windows; disabling it globally would also affect file search, grep, help, and other Snacks pickers.

## Decision (ADR-lite)

**Context**: Snacks explorer's upstream `o` mapping is `explorer_open`, while directory toggle is implemented by the existing `confirm` action. Snacks picker defaults also map `q` to `cancel` for input, list, and preview windows.

**Decision**: Override `o` to `confirm` inside the explorer picker source config. Disable `q` with `false` inside the same explorer source window key tables rather than changing picker-wide defaults.

**Consequences**: Pressing `o` on directories toggles open/closed. The previous system-open behavior on `o` is intentionally replaced for explorer list items. Pressing `q` no longer closes the explorer, while non-explorer Snacks pickers keep their default `q` cancel behavior.

## Out of Scope

- Changing global `<leader>e` behavior.
- Adding a new system-open replacement key.
- Changing other Snacks picker/explorer defaults beyond the requested explorer-scoped `o` and `q` key overrides.
- Modifying bufferline or ClaudeCode integrations.

## Technical Notes

- Inspected `lua/plugins/snacks/explorer.lua`.
- Inspected `lua/plugins/snacks.lua`.
- Inspected local Snacks source `lua/snacks/picker/config/sources.lua`, where upstream explorer list key `o` is `explorer_open` and `l` is `confirm`.
- Inspected local Snacks source `lua/snacks/explorer/actions.lua`, where `confirm` toggles directory items.
- Inspected local Snacks source `lua/snacks/picker/config/defaults.lua`, where picker window defaults map `q` to `cancel` in input, list, and preview windows.
- Inspected local Snacks source `lua/snacks/win.lua` and docs showing window key entries can be disabled with `false`.
- Inspected local Snacks source `lua/snacks/picker/config/init.lua`, confirming source configs merge after global picker defaults, so `sources.explorer.win.*.keys.q = false` only disables the explorer source.
- Relevant specs read: `.trellis/spec/frontend/index.md`, `quality-guidelines.md`, `component-guidelines.md`, `directory-structure.md`, `.trellis/spec/guides/index.md`, and `code-reuse-thinking-guide.md`.
