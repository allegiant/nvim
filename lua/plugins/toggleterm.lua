local present, toggleterm = pcall(require, "toggleterm")

if not present then
  return
end

local M = {}

local default = {
   size = 20,
   open_mapping = [[<c-\>]],
   hide_numbers = true, -- hide the number column in toggleterm buffers
  shade_terminals = true,
  shading_factor = 3, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
  -- start_in_insert = true,
  -- insert_mappings = true, -- whether or not the open mapping applies in insert mode
  -- terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
  -- persist_size = true,
   direction = 'float',
  -- close_on_exit = true, -- close the terminal window when the process exits
  -- -- This field is only relevant if direction is set to 'float'
  float_opts = {
    -- The border key is *almost* the same as 'nvim_open_win'
    -- see :h nvim_open_win for details on borders however
    -- the 'curved' border is a custom border type
    -- not natively supported but implemented in this plugin.
    border = 'single',
    winblend = 3,
    highlights = {
      border = "Normal",
      background = "Normal",
    }
  }
}

M.setup = function()
  toggleterm.setup(default)
end

return M
