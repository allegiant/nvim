# blink.cmp v1 → v2 migration notes

## Sources

* https://main.cmp.saghen.dev/installation.html
* https://github.com/saghen/blink.cmp/blob/main/UPGRADE.md
* Local: `lua/plugins/blink.lua` (v1.10.2, `version = "1.*"`)

## Required changes

1. Drop `version = "1.*"`
2. Add dependency `saghen/blink.lib`
3. Add `build = function() require('blink.cmp').build():pwait(60000) end`
4. `fuzzy.implementation = "rust"` (was `prefer_rust_with_warning`)
5. Do not use `fuzzy.prebuilt_binaries` (removed in v2)

## Keep as-is (compatible for first pass)

* keymap preset `enter` + Tab/S-Tab custom
* cmdline completion opts
* appearance / menu / documentation borders
* sources.default + cmdline provider min_keyword_length
* signature.enabled = true
* `get_lsp_capabilities()` in fluttertools

## Environment

* Neovim 0.12.4 (meets 0.12+)
* rustc must be recent enough for frizbee 0.9 (edition 2024 + let-chains)
* Build failure on 1.87.0 fixed by `rustup update stable` → 1.97.1
* After cargo build, library must live at `lib/libblink_cmp_fuzzy.dll.<commit7>` (managed by `require('blink.cmp').build()`)
