# Research: Neovide font config docs

- **Query**: Research Neovide documentation for font configuration, especially https://neovide.dev/features.html and current config-file docs. Determine why Neovide still reports default fonts (`Cascadia Code`, `Cascadia Mono`, `Consolas`, `Courier New`, `monospace`) and size `18.666668` after `config.toml` was written. Focus on config.toml vs Neovim `guifont`, feature-gated keys, Windows/Scoop config paths, and correct TOML schema for Neovide 0.16.2.
- **Scope**: mixed
- **Date**: 2026-05-25

## Findings

### Files Found

| File Path | Description |
|---|---|
| `C:/Users/alleg/AppData/Local/nvim/lua/config/neovide.lua` | Repository Neovide-only config. Sets `vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"` when loaded. |
| `C:/Users/alleg/AppData/Local/nvim/init.lua` | Loads `config.neovide` only under `if vim.g.neovide then`. |
| `C:/Users/alleg/.config/neovide/config.toml` | Existing Neovide TOML with `[font] normal = ["JetBrainsMono NFM"]`, `size = 12.0`, `hinting = "full"`, `edging = "antialias"`. Valid TOML, but not the Windows default path per Neovide docs/source. |
| `C:/Users/alleg/AppData/Roaming/neovide/config.toml` | Existing Neovide TOML with the same valid `[font]` block. This matches the documented Windows default path because current shell has `APPDATA=C:\Users\alleg\AppData\Roaming` and `NEOVIDE_CONFIG` is unset. |
| `C:/Users/alleg/AppData/Local/nvim/.trellis/tasks/05-25-neovide/prd.md` | Active task states the previous `.config` path did not take effect and the intended target is `%APPDATA%\neovide\config.toml`. |

### Code Patterns

#### Local Neovim configuration

- `C:/Users/alleg/AppData/Local/nvim/init.lua:4-6`:
  ```lua
  if vim.g.neovide then
    require("config.neovide")
  end
  ```
- `C:/Users/alleg/AppData/Local/nvim/lua/config/neovide.lua:1`:
  ```lua
  vim.o.guifont = "JetBrainsMono Nerd Font Mono:h12"
  ```

If this Neovim config is loaded by Neovide, `guifont` is explicitly set and should override Neovide's config-file font in Neovide 0.16.2 behavior. If Neovide still reports the Neovim default list instead, this local `config.neovide` path is likely not being applied in that launch, or another later startup path is overriding it.

#### Local TOML status

Both local TOML files parse successfully with Python `tomllib` as:

```python
{'font': {'normal': ['JetBrainsMono NFM'], 'size': 12.0, 'hinting': 'full', 'edging': 'antialias'}}
```

This schema is valid for Neovide 0.16.2. If this file is actually read and the font entry is applied, the reported `FontOptions` should include `JetBrainsMono NFM` and the size should be `points_to_pixels(12.0) = 16.0` on Windows/Linux, not `18.666668`.

### External References

#### 1. `features.html` is not the font schema source

- Official docs: https://neovide.dev/features.html
- 0.16.2 source page: `website/docs/features.md`
  - `features.md:6-8` says ligatures are supported.
  - `features.md:38-40` says font fallback supports emoji rendering.
  - The page does not define the font configuration schema; it points readers to configuration docs for configurable behavior at `features.md:143-144`.

#### 2. Windows config path is Roaming AppData, not `%USERPROFILE%\.config`

- Official docs: https://neovide.dev/config-file
- 0.16.2 docs: `website/docs/config-file.md:15-24`
  ```markdown
  | Windows | `{FOLDERID_RoamingAppData}/neovide/config.toml` | `C:\Users\Alice\AppData\Roaming/neovide/config.toml` |
  ```
  The docs also state that `$NEOVIDE_CONFIG` may override the location if it is a full path to a TOML file.

- 0.16.2 source: `src/settings/config.rs:29-44`
  ```rust
  #[cfg(windows)]
  fn neovide_config_dir() -> PathBuf {
      let mut path = dirs::config_dir().unwrap();
      path.push("neovide");
      path
  }

  pub fn config_path() -> PathBuf {
      env::var("NEOVIDE_CONFIG")
          .ok()
          .map(PathBuf::from)
          .filter(|path| path.exists() && path.is_file())
          .unwrap_or_else(|| {
              let mut path = neovide_config_dir();
              path.push(CONFIG_FILE);
              path
          })
  }
  ```

Important details from source:

- `NEOVIDE_CONFIG` is considered only when it exists and is a file (`filter(|path| path.exists() && path.is_file())`).
- Otherwise Neovide uses `dirs::config_dir()/neovide/config.toml`; on Windows this corresponds to Roaming AppData in the docs.
- A Scoop install does not document a different config location; official installation docs mention Scoop as an install method, while config-file docs/source still define the same Roaming AppData path.

#### 3. Correct `[font]` TOML schema for Neovide 0.16.2

- Official docs: https://neovide.dev/config-file
- 0.16.2 docs: `website/docs/config-file.md:96-149`

The `[font]` table is documented as available since `0.12.1` and contains:

- required: `normal`, `size`
- optional: `bold`, `italic`, `bold_italic`, `features`, `width`, `hinting`, `edging`, `underline_offset`

`FontDescription` may be:

- a string family name,
- a table with `family` and optional `style`,
- an array of strings or tables.

Examples from 0.16.2 docs include:

```toml
[font]
normal = ["MonoLisa Nerd Font"]
size = 18

[font.features]
"MonoLisa Nerd Font" = [ "+ss01", "+ss07", "+ss11", "-calt", "+ss09", "+ss02", "+ss14" ]
```

and weighted/fallback form:

```toml
[font]
size = 19
hinting = "full"
edging = "antialias"

[[font.normal]]
family = "JetBrainsMono Nerd Font Propo"
style = "W400"

[[font.normal]]
family = "Noto Sans CJK SC"
style = "Normal"
```

0.16.2 source confirms the accepted field names in `src/settings/font.rs:38-51`:

```rust
pub struct FontSettings {
    pub normal: FontDescriptionSettings,
    pub bold: Option<SecondaryFontDescriptionSettings>,
    pub italic: Option<SecondaryFontDescriptionSettings>,
    pub bold_italic: Option<SecondaryFontDescriptionSettings>,
    pub size: f32,
    pub width: Option<f32>,
    pub features: Option<HashMap<String, Vec<String>>>,
    pub allow_float_size: Option<bool>,
    pub hinting: Option<String>,
    pub edging: Option<String>,
    pub underline_offset: Option<f32>,
}
```

Notes:

- The documented keys use snake_case inside `[font]` (`bold_italic`, `underline_offset`).
- The current local config:
  ```toml
  [font]
  normal = ["JetBrainsMono NFM"]
  size = 12.0
  hinting = "full"
  edging = "antialias"
  ```
  matches the documented 0.16.2 schema.

#### 4. `guifont` is still the Neovim-controlled font option

- Official docs: https://neovide.dev/configuration.html#font
- 0.16.2 docs: `website/docs/configuration.md:57-101`

Neovide documents both VimScript and Lua forms:

```vim
set guifont=Source\ Code\ Pro:h14
```

```lua
vim.o.guifont = "Source Code Pro:h14"
```

The same section states that `guifont` "Controls the font used by Neovide" and that it is the only font setting controlled through a Neovim option. Format details:

- font families are comma-separated,
- spaces can be escaped or represented with underscores,
- options are colon-separated,
- `hX` sets point size,
- `#e-X` sets edging (`antialias`, `subpixelantialias`, `alias`),
- `#h-X` sets hinting (`full`, `normal`, `slight`, `none`).

For Neovide 0.16.2 source behavior, `config.toml` initializes the renderer font, but an explicitly user-set Neovim `guifont` is allowed to override it. Source evidence:

- `src/renderer/mod.rs:190-193` records whether config had a font and applies the config font at renderer creation:
  ```rust
  let mut font_config_state = settings.get::<FontConfigState>();
  font_config_state.has_font = init_config.font.is_some();
  settings.set(&font_config_state);
  grid_renderer.update_font_options(init_config.font.map(|x| x.into()).unwrap_or_default());
  ```
- `src/bridge/handler.rs:321-343` skips Neovim's default `guifont` only if a config-file font exists and Neovim reports `guifont` was not explicitly set:
  ```rust
  if !settings.get::<FontConfigState>().has_font || !is_guifont_option_set(event) {
      return false;
  }

  guifont_was_set(nvim).await.map(|was_set| !was_set).unwrap_or_else(|error| {
      warn!("Failed to determine if guifont was set: {error}");
      false
  })
  ```

This matches PR/issue discussions for Neovide around Neovim 0.12: default Neovim `guifont` should not override config-file font, but an explicitly set user `guifont` should.

#### 5. The reported default list is Neovim 0.12's Windows default `guifont`

- Neovim source found by external search: `src/nvim/option_vars.h`
  ```c
  #ifdef MSWIN
  # define DFLT_GFN "Cascadia Code,Cascadia Mono,Consolas,Courier New,monospace"
  #elif defined(__APPLE__)
  # define DFLT_GFN "SF Mono,Menlo,Monaco,Courier New,monospace"
  #elif defined(__linux__)
  # define DFLT_GFN "Source Code Pro,DejaVu Sans Mono,Courier New,monospace"
  #else
  # define DFLT_GFN "DejaVu Sans Mono,Courier New,monospace"
  #endif
  ```

- Neovide issue #3389 and #3462 discuss the same Windows list and `monospace` fallback with Neovim 0.12. Issue #3462 includes the same reported `FontOptions` shape and notes that Windows does not resolve `monospace` as a generic alias.

Therefore, seeing this exact family list indicates Neovide is processing Neovim's default Windows `guifont` list, not the local `JetBrainsMono NFM` config-file font and not the repository `JetBrainsMono Nerd Font Mono:h12` `guifont`.

#### 6. The reported size `18.666668` is Neovide's default 14pt converted to pixels

- 0.16.2 source: `src/renderer/fonts/font_options.rs:14`:
  ```rust
  pub const DEFAULT_FONT_SIZE: f32 = 14.0;
  ```
- Default font options use `points_to_pixels(DEFAULT_FONT_SIZE)`: `src/renderer/fonts/font_options.rs:243-258`.
- `points_to_pixels` on non-macOS multiplies by `96.0 / 72.0`: `src/renderer/fonts/font_options.rs:388-406`.

Calculation:

```text
14.0 * 96.0 / 72.0 = 18.666666...
```

So `size: 18.666668` is consistent with Neovide's default 14pt size after point-to-pixel conversion. If the local TOML `size = 12.0` or local Neovim `:set guifont=...:h12` were active, Neovide's internal pixel size should be about `16.0`, not `18.666668`.

#### 7. Version-gated / feature-gated details relevant to 0.16.2

- Config file support is documented as available since `0.11.0` (`website/docs/config-file.md:3`).
- `[font]` config-file table is documented as available since `0.12.1` (`website/docs/config-file.md:96`).
- `:NeovideConfig` is available since `0.16.0` and opens the actual Neovide configuration file (`website/docs/commands.md:49-54`). This is the most direct documented way to confirm which file Neovide itself is using.
- `underline_offset` appears in the 0.16.2 font docs and source; the release notes for 0.16.0 include adding underline offset config.
- Source accepts `allow_float_size` in `FontSettings`, but the 0.16.2 config-file docs do not list it in the `[font]` table. It is not needed for the current local schema.

### Related Specs

| Spec Path | Relevance |
|---|---|
| `C:/Users/alleg/AppData/Local/nvim/.trellis/spec/backend/directory-structure.md` | Records `init.lua` dispatches VS Code / Neovide / normal Neovim paths and that `lua/config/neovide.lua` is Neovide-only GUI settings. |
| `C:/Users/alleg/AppData/Local/nvim/.trellis/spec/backend/quality-guidelines.md` | Requires platform-specific behavior to remain guarded for Neovide. |
| `C:/Users/alleg/AppData/Local/nvim/.trellis/spec/frontend/directory-structure.md` | Treats Neovide GUI options as editor-facing configuration and says to keep them in `lua/config/neovide.lua`. |
| `C:/Users/alleg/AppData/Local/nvim/.trellis/spec/frontend/component-guidelines.md` | Notes current Neovide GUI styling is isolated in `lua/config/neovide.lua` and currently uses `JetBrainsMono Nerd Font Mono:h12`. |

## Caveats / Not Found

- The current shell reports `NEOVIDE_CONFIG=None`, but a Neovide process launched from a different shortcut, shell, or wrapper could have a different environment.
- `C:/Users/alleg/AppData/Roaming/neovide/config.toml` exists now and parses successfully. If a current Neovide 0.16.2 launch still reports the default list plus `18.666668`, the docs/source point away from a TOML schema problem and toward one of these runtime facts needing verification: actual Neovide version, actual config path used by `:NeovideConfig`, actual launch environment, whether Neovim was launched with `--clean` or a different config, or whether a later `guifont` event overrides the font.
- A missing or misspelled configured font would normally produce `FontOptions` containing the configured family (`JetBrainsMono NFM`) and converted size (`16.0` for `12.0pt`), not the default Neovim Windows family list and `18.666668`.
