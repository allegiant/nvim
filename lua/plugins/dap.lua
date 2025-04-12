return { -- dap debugging {{{
  'mfussenegger/nvim-dap',
  lazy = true,
  dependencies = {
    'nvim-telescope/telescope-dap.nvim',
    'mfussenegger/nvim-dap-python',
    'theHamsta/nvim-dap-virtual-text',
    'rcarriga/nvim-dap-ui',
    "nvim-neotest/nvim-nio",
  },
  keys = {
    { '<leader>d',  group = 'debug' },
    { '<leader>dc', '<Cmd>lua require"dap".continue()<CR>',                                                      desc = 'continue' },
    { '<leader>dl', '<Cmd>lua require"dap".run_last()<CR>',                                                      desc = 'run last' },
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
    { '<leader>df', '<Cmd>Telescope dap frames<CR>',                                                             desc = 'search frames' },
    { '<leader>dC', '<Cmd>Telescope dap commands<CR>',                                                           desc = 'search commands' },
    { '<leader>dL', '<Cmd>Telescope dap list_breakpoints<CR>',                                                   desc = 'search breakpoints' },
    { "<leader>du", function() require("dapui").toggle() end,                                                    desc = "Toggle debug ui" },
  },
  config = function()
    require("dapui").setup()
    local dap = require('dap')
    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = '', linehl = '', numhl = '' })
    dap.defaults.fallback.terminal_win_cmd = 'tabnew'
    dap.defaults.fallback.focus_terminal = true

    local dap_python = require('dap-python')
    dap_python.setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python')
    dap_python.test_runner = 'pytest'
    dap_python.default_port = 38000

    dap.listeners.after.event_initialized["dapui_config"] = function()
      require('dapui').open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      require('dapui').close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      require('dapui').close()
    end
  end,
}
