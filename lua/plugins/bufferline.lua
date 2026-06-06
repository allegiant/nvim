local special_filetypes = {
  snacks_dashboard = true,
  snacks_input = true,
  snacks_layout_box = true,
  snacks_notif = true,
  snacks_notif_history = true,
  snacks_picker_input = true,
  snacks_picker_list = true,
  snacks_picker_preview = true,
  snacks_terminal = true,
  snacks_win_backdrop = true,
  snacks_win_help = true,
}

local theme = {
  fill = { fg = "#7c6f64", bg = "#f2e5bc" },
  head = { fg = "#3c3836", bg = "#d5c4a1", style = "bold" },
  offset = { fg = "#a89984", bg = "#f2e5bc" },
  current_buffer = { fg = "#3c3836", bg = "#e0cfa9", style = "bold" },
  buffer = { fg = "#6f6259", bg = "#eadfbd" },
}

local function get_buffer_option(bufnr, option, fallback)
  local ok, value = pcall(vim.api.nvim_get_option_value, option, { buf = bufnr })
  if ok then
    return value
  end

  ok, value = pcall(function()
    return vim.bo[bufnr][option]
  end)
  return ok and value or fallback
end

local function buffer_name(bufnr)
  local ok, name = pcall(vim.api.nvim_buf_get_name, bufnr)
  return ok and name or ""
end

local function is_special_filetype(filetype)
  return special_filetypes[filetype] or filetype:match("^snacks_") ~= nil
end

local function is_displayed_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if get_buffer_option(bufnr, "buflisted", false) ~= true then
    return false
  end

  if get_buffer_option(bufnr, "buftype", "") ~= "" then
    return false
  end

  if buffer_name(bufnr) == "" then
    return false
  end

  return not is_special_filetype(get_buffer_option(bufnr, "filetype", ""))
end

local function displayed_buffers()
  local buffers = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local bufnr = info.bufnr
    if is_displayed_buffer(bufnr) then
      buffers[#buffers + 1] = bufnr
    end
  end
  return buffers
end

local function current_window_is_displayable()
  local win = vim.api.nvim_get_current_win()
  return is_displayed_buffer(vim.api.nvim_win_get_buf(win))
end

local function focus_display_window()
  if current_window_is_displayable() then
    return
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ok, config = pcall(vim.api.nvim_win_get_config, win)
    if ok and config.relative == "" and is_displayed_buffer(vim.api.nvim_win_get_buf(win)) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

local function switch_to_buffer(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    focus_display_window()
    vim.cmd.buffer(bufnr)
  end
end

local function go_to_buffer(index)
  return function()
    switch_to_buffer(displayed_buffers()[index])
  end
end

local function cycle_buffer(step)
  return function()
    local buffers = displayed_buffers()
    if #buffers == 0 then
      return
    end

    local current = vim.api.nvim_get_current_buf()
    local current_index = nil
    for index, bufnr in ipairs(buffers) do
      if bufnr == current then
        current_index = index
        break
      end
    end

    local next_index = current_index and ((current_index - 1 + step) % #buffers) + 1 or (step > 0 and 1 or #buffers)
    switch_to_buffer(buffers[next_index])
  end
end

local function delete_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  if not is_displayed_buffer(bufnr) then
    focus_display_window()
    bufnr = vim.api.nvim_get_current_buf()
    if not is_displayed_buffer(bufnr) then
      return
    end
  end

  if _G.Snacks and Snacks.bufdelete then
    Snacks.bufdelete({ buf = bufnr })
  else
    vim.cmd("bdelete " .. bufnr)
  end
end

local function buffer_picker_item(bufnr)
  local info = vim.fn.getbufinfo(bufnr)[1]
  local current = vim.api.nvim_get_current_buf()
  local alternate = vim.fn.bufnr("#")
  local name = buffer_name(bufnr)
  local buftype = get_buffer_option(bufnr, "buftype", "")
  local filetype = get_buffer_option(bufnr, "filetype", "")
  local flags = {
    bufnr == current and "%" or (bufnr == alternate and "#" or ""),
    info.hidden == 1 and "h" or (#(info.windows or {}) > 0 and "a" or ""),
    get_buffer_option(bufnr, "readonly", false) and "=" or "",
    info.changed == 1 and "+" or "",
  }

  return {
    flags = table.concat(flags),
    buf = bufnr,
    name = name,
    buftype = buftype,
    filetype = filetype,
    file = name,
    info = info,
    pos = { info.lnum, 0 },
    text = table.concat({ bufnr, name, filetype, buftype }, " "),
  }
end

local function select_buffer()
  if not (_G.Snacks and Snacks.picker) then
    vim.cmd.buffers()
    return
  end

  local items = {}
  for _, bufnr in ipairs(displayed_buffers()) do
    items[#items + 1] = buffer_picker_item(bufnr)
  end

  Snacks.picker.pick({
    title = "Buffers",
    items = items,
    format = "buffer",
    preview = "preview",
    confirm = function(picker, item)
      picker:close()
      if item then
        switch_to_buffer(item.buf)
      end
    end,
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "bufdelete", mode = { "n", "i" } },
        },
      },
      list = { keys = { ["dd"] = "bufdelete" } },
    },
  })
end

local function explorer_offset_width()
  local width = 0
  local next_window_col = nil

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ok, config = pcall(vim.api.nvim_win_get_config, win)
    if ok and config.relative == "" then
      local bufnr = vim.api.nvim_win_get_buf(win)
      local filetype = get_buffer_option(bufnr, "filetype", "")
      local position = vim.api.nvim_win_get_position(win)
      local column = position[2]

      if filetype == "snacks_layout_box" and column == 0 then
        width = math.max(width, vim.api.nvim_win_get_width(win))
      elseif column > 0 then
        next_window_col = math.min(next_window_col or column, column)
      end
    end
  end

  if width > 0 and next_window_col and next_window_col > width then
    return next_window_col
  end

  return width
end

local function render_explorer_offset()
  local width = explorer_offset_width()
  if width == 0 then
    return nil
  end

  return {
    { string.rep(" ", width), hl = theme.offset },
    hl = theme.offset,
  }
end

local function render_head()
  return {
    { "  ", hl = theme.head },
    hl = theme.head,
  }
end

local function shorten(text, max_width)
  if vim.fn.strdisplaywidth(text) <= max_width then
    return text
  end

  return vim.fn.strcharpart(text, 0, max_width - 1) .. "…"
end

local function buffer_label(bufnr)
  local name = vim.fn.fnamemodify(buffer_name(bufnr), ":t")
  return shorten(name, 24)
end

local function render_buffer(line, bufnr, index)
  local is_current = bufnr == vim.api.nvim_get_current_buf()
  local hl = is_current and theme.current_buffer or theme.buffer

  return {
    line.sep("", hl, theme.fill),
    { string.format(" %d %s ", index, buffer_label(bufnr)), hl = hl },
    line.sep("", hl, theme.fill),
    click = { "to_buf", bufnr },
    hl = hl,
  }
end

local function render_tabline(line)
  local nodes = { hl = theme.fill }
  local offset = render_explorer_offset()
  if offset then
    nodes[#nodes + 1] = offset
  else
    nodes[#nodes + 1] = render_head()
  end

  for index, bufnr in ipairs(displayed_buffers()) do
    nodes[#nodes + 1] = render_buffer(line, bufnr, index)
  end
  nodes[#nodes + 1] = line.spacer()

  return nodes
end

local keys = {
  { "<leader>b",  group = "Buffer" },
  { "<Tab>",      cycle_buffer(1),      desc = "Next buffer" },
  { "<S-Tab>",    cycle_buffer(-1),     desc = "Previous buffer" },
  { "<leader>bd", delete_current_buffer, desc = "Delete buffer" },
  { "<leader>bs", select_buffer,         desc = "Select buffer" },
}

for index = 1, 9 do
  keys[#keys + 1] = { "<leader>b" .. index, go_to_buffer(index), desc = "Go to buffer " .. index }
end

return {
  "nanozuki/tabby.nvim",
  event = "VimEnter",
  keys = keys,
  opts = {
    line = render_tabline,
    option = {
      buf_name = {
        mode = "tail",
      },
    },
  },
  config = function(_, opts)
    require("tabby").setup(opts)
  end,
}
