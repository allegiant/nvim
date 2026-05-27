return { -- dap debugging {{{
  'mfussenegger/nvim-dap',
  event = "VeryLazy",
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    { '<leader>d',  group = 'debug' },
    { '<leader>dc', '<Cmd>lua require"dap".continue()<CR>',                                                      desc = 'continue' },
    { '<leader>dd', '<Cmd>lua require"dap".run_last()<CR>',                                                      desc = 'run last' },
    { '<leader>dq', '<Cmd>lua require"dap".terminate()<CR>',                                                     desc = 'terminate' },
    { '<leader>dh', '<Cmd>lua require"dap".close()<CR>',                                                         desc = 'stop' },
    { '<leader>dn', '<Cmd>lua require"dap".step_over()<CR>',                                                     desc = 'step over' },
    { '<leader>ds', '<Cmd>lua require"dap".step_into()<CR>',                                                     desc = 'step into' },
    { '<leader>dS', '<Cmd>lua require"dap".step_out()<CR>',                                                      desc = 'step out' },
    { '<leader>db', '<Cmd>lua require"dap".toggle_breakpoint()<CR>',                                             desc = 'toggle br' },
    { '<leader>dB', '<Cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',          desc = 'set br condition' },
    { '<leader>dp', '<Cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>',   desc = 'set log br' },
    { '<leader>dr', '<Cmd>lua require"dap".repl.open()<CR>',                                                     desc = 'REPL open' },
    { '<leader>dk', '<Cmd>lua require"dap".up()<CR>',                                                            desc = 'up callstack' },
    { '<leader>dj', '<Cmd>lua require"dap".down()<CR>',                                                          desc = 'down callstack' },
    { '<leader>di', '<Cmd>lua require"dap.ui.widgets".hover()<CR>',                                              desc = 'info' },
    { '<leader>d?', '<Cmd>lua local widgets=require"dap.ui.widgets";widgets.centered_float(widgets.scopes)<CR>', desc = 'scopes' },
    { "<leader>du", function() require("dapui").toggle() end,                                                    desc = "Toggle debug ui" },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local dap_virtual_text = require("nvim-dap-virtual-text")
    local dap_python = require("dap-python")
    local is_win = vim.fn.has("win32") == 1

    local function get_mason_package_install_path(package_name)
      local present, mason_registry = pcall(require, "mason-registry")
      if not present or not mason_registry.is_installed(package_name) then
        return nil
      end

      local ok, mason_package = pcall(mason_registry.get_package, package_name)
      if not ok then
        return nil
      end

      return mason_package:get_install_path()
    end

    local function join_path(...)
      return table.concat({ ... }, "/")
    end

    local function python_has_debugpy(python)
      vim.fn.system({ python, "-c", "import debugpy" })
      return vim.v.shell_error == 0
    end

    local function resolve_mason_debugpy_adapter()
      local install_path = get_mason_package_install_path("debugpy")
      if not install_path then
        return nil
      end

      if vim.fn.executable("debugpy-adapter") == 1 then
        return "debugpy-adapter"
      end

      if not is_win then
        local adapter_path = join_path(install_path, "venv", "bin", "debugpy-adapter")
        if vim.fn.executable(adapter_path) == 1 then
          return adapter_path
        end
      end
    end

    local function resolve_python_debugger()
      local debugpy_adapter = resolve_mason_debugpy_adapter()
      if debugpy_adapter then
        return debugpy_adapter
      end

      for _, python in ipairs({ "python3", "python" }) do
        if vim.fn.executable(python) == 1 and python_has_debugpy(python) then
          return python
        end
      end
    end

    local function resolve_codelldb()
      local install_path = get_mason_package_install_path("codelldb")
      if install_path then
        local adapter_name = is_win and "codelldb.exe" or "codelldb"
        local adapter_path = join_path(install_path, "extension", "adapter", adapter_name)
        if vim.fn.executable(adapter_path) == 1 then
          return adapter_path
        end
      end

      local codelldb = vim.fn.exepath("codelldb")
      if codelldb ~= "" then
        return codelldb
      end
    end

    local function setup_python_debugger()
      local python_debugger = resolve_python_debugger()
      if python_debugger then
        dap_python.setup(python_debugger)
      end
    end

    local function setup_codelldb()
      local codelldb = resolve_codelldb()
      if not codelldb then
        return
      end

      local executable = {
        command = codelldb,
        args = { "--port", "${port}" },
      }
      if is_win then
        executable.detached = false
      end

      dap.adapters.codelldb = {
        type = 'server',
        host = '127.0.0.1',
        port = "${port}",
        executable = executable,
      }

      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp
    end

    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = '', linehl = '', numhl = '' })
    dap.defaults.fallback.terminal_win_cmd = 'tabnew'
    dap.defaults.fallback.focus_terminal = true

    dapui.setup()
    dap_virtual_text.setup()

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    setup_python_debugger()
    setup_codelldb()
  end,
}
