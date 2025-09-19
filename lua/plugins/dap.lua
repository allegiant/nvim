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

    dap_python.setup('python')

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
  end,
}
