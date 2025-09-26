local default = {
  options = {
    mode = "buffers", -- set to "tabs" to only show tabpages instead
    numbers = function(opts)
      return string.format("%s.", opts.ordinal)
    end,
    close_command = "bdelete! %d",       -- can be a string | function, see "Mouse actions"
    right_mouse_command = "bdelete! %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d",    -- can be a string | function, see "Mouse actions"
    middle_mouse_command = nil,          -- can be a string | function, see "Mouse actions"
    --- name_formatter can be used to change the buffer's label in the bufferline.
    --- Please note some names can/will break the
    --- bufferline so use this at your discretion knowing that it has
    --- some limitations that will *NOT* be fixed.
    name_formatter = function(buf) -- buf contains a "name", "path" and "bufnr"
      -- remove extension from markdown files for example
      if buf.name:match('%.md') then
        return vim.fn.fnamemodify(buf.name, ':t:r')
      end
    end,
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 18,
    diagnostics = false,
    diagnostics_update_in_insert = false,
    offsets = { { filetype = "NvimTree" } },
    color_icons = true,       -- whether or not to add the filetype icon highlights
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "thick",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
  },
}

return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    'famiu/bufdelete.nvim'
  },
  event = 'VimEnter',
  keys = {
    { "<leader>b",  group = "Buffer" },
    { "<TAB>",      "<cmd>BufferLineCycleNext<CR>",    desc = "buf next" },
    { "<S-Tab>",    "<cmd>BufferLineCyclePrev<CR>",    desc = "buf prev" },
    { "<leader>bd", "<cmd>bdelete<CR>",                desc = "Close" },
    { "<leader>bc", "<cmd>BufferLinePickClose<CR>",    desc = "Pick Close" },
    { "<leader>bs", "<cmd>BufferLinePick<CR>",         desc = "Pick" },
    { "<leader>bl", "<cmd>BufferLineMoveNext<CR>",     desc = "Move right" },
    { "<leader>bh", "<cmd>BufferLineMovePrev<CR>",     desc = "Move left" },
    { "<leader>bq", "<cmd>BufferLineCloseLeft<CR>",    desc = "Close left" },
    { "<leader>bp", "<cmd>BufferLineCloseRight<CR>",   desc = "Close right " },
    { "<leader>b1", "<cmd>BufferLineGoToBuffer 1<CR>", desc = "goto 1" },
    { "<leader>b2", "<cmd>BufferLineGoToBuffer 2<CR>", desc = "goto 2" },
    { "<leader>b3", "<cmd>BufferLineGoToBuffer 3<CR>", desc = "goto 3" },
    { "<leader>b4", "<cmd>BufferLineGoToBuffer 4<CR>", desc = "goto 4" },
    { "<leader>b5", "<cmd>BufferLineGoToBuffer 5<CR>", desc = "goto 5" },
    { "<leader>b6", "<cmd>BufferLineGoToBuffer 6<CR>", desc = "goto 6" },
    { "<leader>7",  "<cmd>BufferLineGoToBuffer 7<CR>", desc = "goto 7" },
    { "<leader>8",  "<cmd>BufferLineGoToBuffer 8<CR>", desc = "goto 8" },
    { "<leader>9",  "<cmd>BufferLineGoToBuffer 9<CR>", desc = "goto 9" },
  },
  config = function()
    require("bufferline").setup(default)
  end,
}
