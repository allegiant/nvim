# Research: Cross-platform Neovim DAP configuration

- **Query**: Research cross-platform Neovim DAP configuration for `lua/plugins/dap.lua`, preserving `{ '<leader>d', group = 'debug' }`; focus on nvim-dap-python/debugpy, CodeLLDB paths on Windows/Linux with Mason and `vim.fn.exepath`, simple C/C++/Rust configurations, and fixed ports vs `${port}`.
- **Scope**: mixed
- **Date**: 2026-05-27

## Findings

### Files Found

| File Path | Description |
|---|---|
| `lua/plugins/dap.lua` | Main DAP lazy.nvim plugin spec; configures `nvim-dap`, `nvim-dap-ui`, virtual text, `nvim-dap-python`, and CodeLLDB adapter. |
| `lua/plugins/mason.lua` | Mason setup only; no DAP adapter installation or `ensure_installed` list. |
| `lua/plugins/toggleterm.lua` | Existing platform guard pattern with `vim.fn.has("win32")` and `vim.fn.executable(...)`. |
| `lua/core/utils.lua` | Existing OS helper functions (`is_win`, `is_wsl`). |
| `.trellis/spec/backend/error-handling.md` | Project guidance for optional integrations and guarded Mason access. |
| `.trellis/spec/backend/quality-guidelines.md` | Project guidance for platform-safe changes and no machine-specific absolute paths. |
| `.trellis/spec/frontend/type-safety.md` | Project guidance for `pcall(require, "mason-registry")`, `is_installed`, and executable/platform checks. |

### Code Patterns

#### Current DAP plugin shape

- `lua/plugins/dap.lua:1-8` returns a lazy.nvim plugin spec for `mfussenegger/nvim-dap`; dependencies include `rcarriga/nvim-dap-ui`, `nvim-neotest/nvim-nio`, `theHamsta/nvim-dap-virtual-text`, and `mfussenegger/nvim-dap-python`.
- `lua/plugins/dap.lua:10-27` defines DAP keymaps. The requested group entry is currently exactly at `lua/plugins/dap.lua:11`:

```lua
{ '<leader>d',  group = 'debug' },
```

- `lua/plugins/dap.lua:29-54` loads `dap`, `dapui`, `nvim-dap-virtual-text`, and `dap-python`, defines signs, sets fallback terminal behavior, and wires DAP UI open/close listeners.

#### Current Python DAP setup

At `lua/plugins/dap.lua:56`:

```lua
dap_python.setup('python')
```

Meaning from `nvim-dap-python` docs:

- The first argument must be an executable in `$PATH` or an absolute Python path.
- If it is a Python interpreter (`python`, `python3`, `/path/to/venv/bin/python`), that interpreter must have `debugpy` installed; the docs explicitly say the equivalent of `python -m debugpy --version` must work.
- Newer `debugpy` versions also provide a `debugpy-adapter` executable, and `nvim-dap-python` accepts `setup('debugpy-adapter')`.
- `setup('uv')` is also documented and runs debugpy through uv.
- Calling `setup(...)` creates default Python configurations unless `include_configs` is disabled, so Python usually does not need hand-written baseline `dap.configurations.python` entries.

Cross-platform implications:

- `python` is commonly present on Windows, but on Linux the reliable command is often `python3`; some Linux installs intentionally lack a `python` shim.
- Choosing `python` or `python3` only selects the adapter-launch interpreter; it still must include `debugpy`.
- A Mason-installed `debugpy` can be exposed as a `debugpy-adapter` executable through Mason's `bin` directory when Mason has added that directory to Neovim's `PATH`.

#### Current CodeLLDB adapter setup

At `lua/plugins/dap.lua:58-68`:

```lua
dap.adapters.codelldb = {
  type = 'server',
  host = '127.0.0.1',
  port = 13000,
  executable = {
    command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
    args = { "--port", "13000" },
    -- on windows you may have to uncomment this:
    -- detached = false,
  },
}
```

Observed properties:

- It assumes Mason's default package directory under `stdpath("data")`.
- It uses a Linux/macOS-style adapter filename (`codelldb`) and does not append `.exe` for Windows.
- It does not check whether Mason, the Mason registry, or the `codelldb` package is installed.
- It uses fixed port `13000` in both `port` and `args`.
- It registers only the adapter; there are no `dap.configurations.cpp`, `dap.configurations.c`, or `dap.configurations.rust` entries in this repo.

#### Current Mason setup

`lua/plugins/mason.lua:1-5` only calls:

```lua
require("mason").setup()
```

No internal search found:

- `mason-nvim-dap.nvim`
- `mason-tool-installer`
- DAP adapter `ensure_installed`
- any repo-local `debugpy` or `codelldb` install declaration

#### Existing platform/helper patterns in repo

- `lua/plugins/toggleterm.lua:1-5` uses `vim.fn.has("win32")` and `vim.fn.executable "pwsh"` to guard Windows-specific shell behavior.
- `lua/core/utils.lua:96-101` exposes `utils.is_win()` via `vim.loop.os_uname().sysname == "Windows_NT"` and `utils.is_wsl()` via `vim.fn.has('wsl') == 1`.
- Specs point to lightweight runtime checks (`pcall`, `is_installed`, `vim.fn.has`, `vim.fn.executable`) rather than unguarded optional setup.

### External References

- [nvim-dap-python README](https://github.com/mfussenegger/nvim-dap-python/blob/master/README.md) — `require("dap-python").setup("/path/to/venv/bin/python")` requires that interpreter to run `-m debugpy --version`; global setup examples use `python3`; docs also mention `debugpy-adapter` and `uv`.
- [nvim-dap-python help](https://github.com/mfussenegger/nvim-dap-python/blob/64652d1a/doc/dap-python.txt) — `M.setup({python_path}, {opts?})` registers the Python debug adapter; `python_path` must be absolute or in `$PATH` and needs `debugpy`; default is `python3`; options include `include_configs`, `console`, and `pythonPath`.
- [nvim-dap CodeLLDB wiki](https://github.com/mfussenegger/nvim-dap/wiki/C-CPP-Rust-(via-codelldb)) — CodeLLDB uses TCP and should be a `server` adapter; for CodeLLDB 1.7.0+ specify `--port`; documented auto-spawn pattern uses `port = "${port}"` and `args = { "--port", "${port}" }`; Windows may need `detached = false`; wiki includes simple `dap.configurations.cpp` and aliases `c`/`rust` to `cpp`.
- [nvim-dap adapter help](https://github.com/mfussenegger/nvim-dap/blob/5860c7c5/doc/dap.txt) — server adapter `port` is `number | "${port}"`; if `"${port}"` is used, nvim-dap resolves a free port and replaces `${port}` in `executable.args`; `host` defaults to `127.0.0.1`; `executable.detached` defaults to true; `options.max_retries` defaults to 14.
- [mason.nvim README](https://github.com/mason-org/mason.nvim/blob/main/README.md) — Mason installs packages in Neovim's data directory and links executables to one `mason/bin` directory, which Mason adds to Neovim's `PATH` during setup.
- [mason-nvim-dap issue #51](https://github.com/jay-babu/mason-nvim-dap.nvim/issues/51) — Discussion notes `vim.fn.exepath('codelldb')` can resolve the Mason-linked executable on both Linux and Windows (Windows returns `.CMD`), while `mason-registry.get_package('codelldb'):get_install_path()` can target Mason's package directory explicitly.
- [mason.nvim issue #371](https://github.com/mason-org/mason.nvim/issues/371) — CodeLLDB path discussion notes the package extension path `.../packages/codelldb/extension/adapter/codelldb` is the intended direct adapter location for Mason-installed CodeLLDB.

### Related Specs

- `.trellis/spec/backend/error-handling.md:49-63` — optional integrations should return early; example guards `mason-registry` with `pcall` and `mason_registry.is_installed(...)`.
- `.trellis/spec/backend/error-handling.md:89-93` — common mistake: do not call `require("mason-registry")` directly where missing Mason can break startup.
- `.trellis/spec/backend/quality-guidelines.md:21-27` — avoid plugin setup in `init.lua`, avoid missing-Mason startup errors, avoid duplicated helpers, and avoid machine-specific absolute paths.
- `.trellis/spec/backend/quality-guidelines.md:52-59` — platform-specific code must be guarded and must not break Windows, WSL, Neovide, or vscode-neovim paths.
- `.trellis/spec/frontend/type-safety.md:29-35` — validation pattern includes `pcall(require, "mason-registry")`, `mason_registry.is_installed(...)`, and `vim.fn.has(...)` / `vim.fn.executable(...)` checks.

## Viable Approaches

### Approach 1: Mason-registry explicit package path for CodeLLDB, dynamic port

Shape:

- Keep existing lazy.nvim DAP spec and keep `{ '<leader>d', group = 'debug' }` unchanged.
- Use `pcall(require, "mason-registry")` and `mason_registry.is_installed("codelldb")` before configuring CodeLLDB.
- Build direct adapter path from `mason_registry.get_package("codelldb"):get_install_path()` plus `extension/adapter/codelldb`.
- Add `.exe` when `vim.fn.has("win32") == 1`.
- Use `port = "${port}"` and `args = { "--port", "${port}" }`.
- Consider `detached = false` for Windows, matching the upstream CodeLLDB/nvim-dap note.
- Add simple `dap.configurations.cpp` plus `dap.configurations.c = dap.configurations.cpp` and `dap.configurations.rust = dap.configurations.cpp` if C/C++/Rust launch support is desired.

Pros:

- Targets the known Mason package layout explicitly.
- Avoids machine-specific absolute paths.
- Can return early if Mason or the package is missing, matching existing specs.
- Handles Windows `.exe` path directly.
- Dynamic port avoids fixed-port collisions.

Cons:

- Requires Mason registry availability at DAP config time.
- Does not auto-install `codelldb`; user still needs Mason package installed.

### Approach 2: `vim.fn.exepath('codelldb')` path resolution, dynamic port

Shape:

- Resolve `local codelldb = vim.fn.exepath('codelldb')` after Mason setup has had a chance to put `mason/bin` on Neovim's `PATH`.
- If non-empty, use that command as `executable.command`.
- Use `port = "${port}"` and `args = { "--port", "${port}" }`.
- Optionally fall back to Mason-registry direct package path when `exepath` is empty.

Pros:

- Cross-platform in principle: can pick up Mason's linked executable, including `.CMD` on Windows.
- Does not hardcode `stdpath("data")` package internals.
- Can also support non-Mason/system installs if they are intentionally on `PATH`.

Cons / pitfalls:

- `exepath` finds any matching executable in `PATH`, not only Mason's package.
- It depends on Mason's PATH injection/load order if Mason is the desired source.
- On Windows, the resolved command may be a `.CMD` shim rather than the direct `.exe`; this is discussed as a possible fix in `mason-nvim-dap`, but direct spawning behavior should be tested in this repo's Neovim/nvim-dap environment.

### Approach 3: Add `mason-nvim-dap.nvim` and let it manage adapters

Shape:

- Add `jay-babu/mason-nvim-dap.nvim` and configure DAP adapters through it.
- Use its adapter-name mapping (`python` maps to Mason package `debugpy`, etc.) and optional `ensure_installed`/handlers.
- Keep custom CodeLLDB or Python handler overrides only where necessary.

Pros:

- Centralizes DAP adapter installation/setup concerns.
- Can auto-install or auto-setup adapters.
- Reduces manual path logic in `lua/plugins/dap.lua`.

Cons:

- Larger change than needed for the current single-file target.
- Adds a plugin dependency and another setup layer.
- May still need custom handling for CodeLLDB on Windows or for exact path/port behavior.

## Recommendation

Recommended approach for this repo/task: **Approach 1**.

Reasoning:

- The repo already uses Mason and specs require guarded optional integrations with `pcall(require, "mason-registry")` and `is_installed(...)`.
- It avoids machine-specific absolute paths while still targeting the known CodeLLDB adapter binary under Mason's package directory.
- It can add the required Windows `.exe` suffix explicitly.
- It preserves the existing `<leader>d` debug group unchanged.
- It keeps the change localized to `lua/plugins/dap.lua` instead of adding `mason-nvim-dap.nvim`.
- Pairing it with `port = "${port}"` avoids the current fixed-port collision class while matching upstream nvim-dap CodeLLDB docs.

Use `vim.fn.exepath('codelldb')` as a viable fallback or alternate approach if the desired behavior is to support either Mason-linked or system `codelldb` from `PATH`. For the most deterministic Mason-specific setup, prefer `mason-registry.get_package("codelldb"):get_install_path()`.

For Python, a cross-platform setup should not assume that `python` always exists or has `debugpy`. The documented choices are:

- `debugpy-adapter` if that executable is present, especially from Mason/debugpy;
- a known Python interpreter path whose `-m debugpy --version` works;
- `python3` for many Linux installs;
- `python` for many Windows installs;
- `uv` if uv is intentionally available and desired.

### Whether to add simple `dap.configurations.cpp/c/rust`

Yes, if the goal is to make CodeLLDB usable from nvim-dap for C/C++/Rust without relying on external `launch.json` files.

The nvim-dap CodeLLDB wiki's minimal configuration is appropriate for a simple baseline:

- `name = "Launch file"`
- `type = "codelldb"`
- `request = "launch"`
- `program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end`
- `cwd = '${workspaceFolder}'`
- `stopOnEntry = false`
- `dap.configurations.c = dap.configurations.cpp`
- `dap.configurations.rust = dap.configurations.cpp`

Do not add Python launch configs just to fix Python DAP setup; `nvim-dap-python` already adds default Python configurations when `include_configs` is not disabled.

### Fixed port vs `${port}`

Current fixed-port behavior:

```lua
port = 13000
args = { "--port", "13000" }
```

This can work only if:

- `13000` is free;
- every CodeLLDB session uses the same synchronized value in both places;
- there is no concurrent/stale adapter already bound to the port.

Pitfalls:

- Port collision if another process or previous CodeLLDB instance uses `13000`.
- Concurrent sessions cannot use the same fixed port.
- Editing one side (`port` vs `args`) without the other breaks connection.
- If using manual server startup without `executable`, a fixed known port is necessary and the external `codelldb --port <port>` command must match it.

`${port}` behavior:

```lua
port = "${port}"
executable = {
  args = { "--port", "${port}" },
}
```

nvim-dap resolves a free local port and replaces `${port}` in `executable.args` before spawning the adapter. This is the documented auto-spawn pattern for CodeLLDB and is the better fit for a normal Neovim config that launches the adapter automatically.

## Caveats / Not Found

- No DAP-specific Trellis spec was found; related specs are generic Neovim config, Mason guarding, platform safety, and quality rules.
- Local searches did not find installed `codelldb` or `debugpy` Mason package paths under `C:\Users\alleg\AppData\Local\nvim-data`, but this was not validated by running Neovim's `stdpath("data")` inside the configured runtime.
- External documentation snippets were gathered via web search excerpts, not by fetching full source files line-by-line.
- Windows CodeLLDB often needs `detached = false` according to upstream examples, but whether it is required in this exact environment must be verified by running a debug session.
