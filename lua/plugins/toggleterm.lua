-- Check if Windows
local is_win32 = vim.fn.has("win32")
if (is_win32 == 1) then
  local powershell_options = {
    shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell",
    shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
    shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
    shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellquote = "",
    shellxquote = "",
  }

  for option, value in pairs(powershell_options) do
    vim.opt[option] = value
  end
end

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

return {
  "akinsho/toggleterm.nvim",
  keys = {
    { '<leader>t',  group = 'Terminal' },
    { '<leader>tn', '<Cmd>TermNew<CR>',    desc = 'Create new Terminal' },
    { '<leader>ts', '<Cmd>TermSelect<CR>', desc = 'select Terminal' },
  },
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 10
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]],
      direction = 'horizontal', -- vertical' | 'horizontal' | 'tab' | 'float',
      autochdir = false,
      highlights = {
        -- highlights which map to a highlight group name and a table of it's values
        -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
        -- #f2e5bc
        Normal = { link = "ToogleTermNormal" },
        NormalFloat = { link = "ToogleTermNormalFloat" },
        FloatBorder = { link = "ToggleTermFloatBorder" },
      },
      float_opts = {
        border = 'single',
        winblend = 3,
      },
      on_create = function()
        vim.cmd([[ setlocal signcolumn=no ]])
      end,
      winbar = {
        enabled = false,
        name_formatter = function(term) --  term: Terminal
          return term.name
        end
      },
    })

    vim.cmd([[ hi ToogleTermNormal guibg=#f2e5bc ]])
    vim.cmd([[ hi ToggleTermFloatBorder guibg=#f2e5bc guifg=#f2e5bc ]])
    vim.cmd([[ hi ToogleTermNormalFloat guibg=#f2e5bc ]])

    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end,
}
