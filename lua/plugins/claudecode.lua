local function set_claude_terminal_esc_keymap(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "terminal" then
    return
  end

  local ok, terminal = pcall(require, "claudecode.terminal")
  if not ok or not terminal.get_active_terminal_bufnr then
    return
  end

  if terminal.get_active_terminal_bufnr() ~= bufnr then
    return
  end

  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
    buffer = bufnr,
    desc = "Exit Claude terminal mode without sending Esc",
  })
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {},
  config = function(_, opts)
    require("claudecode").setup(opts)

    vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("claudecode_terminal_keymaps", { clear = true }),
      callback = function(args)
        vim.schedule(function()
          set_claude_terminal_esc_keymap(args.buf)
        end)
      end,
      desc = "Map Esc only in the active Claude terminal buffer",
    })
  end,
  keys = {
    { "<leader>a",  nil,                              desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    -- Diff management
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
  },
}
