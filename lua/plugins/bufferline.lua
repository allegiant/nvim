local theme = {
  fill = { fg = "#7c6f64", bg = "#f2e5bc" },
  head = { fg = "#3c3836", bg = "#d5c4a1", style = "bold" },
  offset = { fg = "#a89984", bg = "#f2e5bc" },
  current_buffer = { fg = "#1d2021", bg = "#e0cfa9", style = "bold" },
  buffer = { fg = "#6f6259", bg = "#eadfbd" },
}

local function buf_opt(bufnr, option, fallback)
  local ok, value = pcall(vim.api.nvim_get_option_value, option, { buf = bufnr })
  return ok and value or fallback
end

local function is_displayed_buffer(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and buf_opt(bufnr, "buflisted", false)
    and buf_opt(bufnr, "buftype", "") == ""
    and vim.api.nvim_buf_get_name(bufnr) ~= ""
    and not buf_opt(bufnr, "filetype", ""):match("^snacks_")
end

local function displayed_buffers()
  local buffers = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if is_displayed_buffer(info.bufnr) then
      buffers[#buffers + 1] = info.bufnr
    end
  end
  return buffers
end

-- 当前窗口是终端等特殊 buffer 时,先跳到可显示的普通窗口再切换
local function focus_display_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" and is_displayed_buffer(vim.api.nvim_win_get_buf(win)) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

local function switch_to_buffer(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    if not is_displayed_buffer(vim.api.nvim_get_current_buf()) then
      focus_display_window()
    end
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
    local current_index
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

  local snacks = rawget(_G, "Snacks")
  if snacks and snacks.bufdelete then
    snacks.bufdelete({ buf = bufnr })
  else
    vim.cmd("bdelete " .. bufnr)
  end
end

-- explorer(snacks_layout_box)停靠最左侧时,标签栏留出等宽空白
local function render_explorer_offset()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == ""
      and vim.api.nvim_win_get_position(win)[2] == 0
      and buf_opt(vim.api.nvim_win_get_buf(win), "filetype", "") == "snacks_layout_box"
    then
      local width = vim.api.nvim_win_get_width(win)
      return { { string.rep(" ", width), hl = theme.offset }, hl = theme.offset }
    end
  end
end

local function shorten(text, max_width)
  if vim.fn.strdisplaywidth(text) <= max_width then
    return text
  end
  return vim.fn.strcharpart(text, 0, max_width - 1) .. "…"
end

local function render_buffer(line, bufnr, index)
  local is_current = bufnr == vim.api.nvim_get_current_buf()
  local hl = is_current and theme.current_buffer or theme.buffer
  local label = shorten(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t"), 24)

  return {
    line.sep("", hl, theme.fill),
    { string.format(" %d %s ", index, label), hl = hl },
    line.sep("", hl, theme.fill),
    click = { "to_buf", bufnr },
    hl = hl,
  }
end

local function render_tabline(line)
  local nodes = { hl = theme.fill }
  nodes[#nodes + 1] = render_explorer_offset() or { { "  ", hl = theme.head }, hl = theme.head }

  for index, bufnr in ipairs(displayed_buffers()) do
    nodes[#nodes + 1] = render_buffer(line, bufnr, index)
  end
  nodes[#nodes + 1] = line.spacer()

  return nodes
end

local keys = {
  { "<Tab>",      cycle_buffer(1),          desc = "Next buffer" },
  { "<S-Tab>",    cycle_buffer(-1),         desc = "Previous buffer" },
  { "<leader>bd", delete_current_buffer,    desc = "Delete buffer" },
  { "<leader>bs", "<cmd>lua Snacks.picker.buffers()<cr>", desc = "Select buffer" },
}

for index = 1, 9 do
  keys[#keys + 1] = { "<leader>b" .. index, go_to_buffer(index), desc = "Go to buffer " .. index }
end

return {
  "nanozuki/tabby.nvim",
  event = "VimEnter",
  keys = keys,
  opts = { line = render_tabline },
}
