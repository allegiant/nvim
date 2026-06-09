local M = {}

local function toggle_current_terminal(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local meta = vim.b[bufnr].snacks_terminal
  if type(meta) ~= "table" or not meta.id then
    return
  end

  for _, term in ipairs(Snacks.terminal.list()) do
    if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
      local term_meta = vim.b[term.buf].snacks_terminal
      if type(term_meta) == "table" and term_meta.id == meta.id then
        term:toggle()
        return
      end
    end
  end
end

local terminal_opts = {
  win = {
    position = "bottom",
    height = 10,
    keys = {
      term_toggle = {
        [[<C-\>]],
        function(term)
          toggle_current_terminal(term.buf)
        end,
        mode = "t",
        desc = "Toggle current terminal",
      },
    },
  },
}

M.options = function(opts)
  return vim.tbl_deep_extend("force", {}, terminal_opts, opts or {})
end

M.toggle = function()
  Snacks.terminal.toggle(nil, M.options())
end

local function terminal_id_number(meta)
  if type(meta) ~= "table" then
    return nil
  end

  local id = meta.id
  if type(id) == "number" then
    return id
  end

  if type(id) ~= "string" then
    return nil
  end

  return tonumber(id) or tonumber(id:match("count%s*=%s*(%d+)"))
end

local function max_terminal_id()
  local max_id = 0

  for _, term in ipairs(Snacks.terminal.list()) do
    local buf = term.buf
    if buf and vim.api.nvim_buf_is_valid(buf) then
      local id = terminal_id_number(vim.b[buf].snacks_terminal)
      if id and id > max_id then
        max_id = id
      end
    end
  end

  return max_id
end

M.toggle_next = function()
  Snacks.terminal.toggle(nil, M.options({ count = max_terminal_id() + 1 }))
end

local function terminal_label(term)
  local buf = term.buf
  local title = vim.b[buf].term_title or vim.api.nvim_buf_get_name(buf)
  if title == "" then
    title = "Terminal"
  end

  return ("buf %d: %s"):format(buf, title)
end

M.select = function()
  local terminals = Snacks.terminal.list()
  if vim.tbl_isempty(terminals) then
    vim.notify("No Snacks terminals", vim.log.levels.INFO, { title = "Terminal" })
    return
  end

  vim.ui.select(terminals, {
    prompt = "Select terminal",
    format_item = terminal_label,
  }, function(term)
    if term then
      term:show()
      term:focus()
    end
  end)
end

return M
