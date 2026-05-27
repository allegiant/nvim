local toggle_terminal

local function set_snacks_terminal_keymaps(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.b[bufnr].snacks_terminal then
    return
  end

  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("t", [[<C-\>]], function()
    toggle_terminal()
  end, opts)
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
end

local terminal_opts = {
  win = {
    position = "bottom",
    height = 10,
    on_buf = function(term)
      set_snacks_terminal_keymaps(term.buf)
    end,
  },
}

local next_terminal_count = 1

local function terminal_options(extra)
  return vim.tbl_deep_extend("force", {}, terminal_opts, extra or {})
end

toggle_terminal = function()
  Snacks.terminal.toggle(nil, terminal_options())
end

local function new_terminal()
  next_terminal_count = next_terminal_count + 1
  Snacks.terminal.open(nil, terminal_options({ count = next_terminal_count }))
end

local function terminal_label(term)
  local buf = term.buf
  local title = vim.b[buf].term_title or vim.api.nvim_buf_get_name(buf)
  if title == "" then
    title = "Terminal"
  end

  return ("buf %d: %s"):format(buf, title)
end

local function select_terminal()
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

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    -- buffer
    { "<leader>bd", function() Snacks.bufdelete() end,                    desc = "Close" },
    -- terminal
    { "<leader>t",  group = "Terminal" },
    { [[<C-\>]],    toggle_terminal,                                      desc = "Toggle Terminal" },
    { "<leader>tn", new_terminal,                                         desc = "Create new Terminal" },
    { "<leader>ts", select_terminal,                                      desc = "select Terminal" },
    -- file
    { "<leader>f",  group = "File" },
    { "<leader>ff", "<cmd>lua Snacks.picker.files()<cr>",                 desc = "Find Files" },
    { "<leader>fb", "<cmd>lua Snacks.picker.buffers()<cr>",               desc = "Find Buffers" },
    { "<leader>fh", "<cmd>lua Snacks.picker.help()<cr>",                  desc = "Find help_tags" },
    { "<leader>fw", "<cmd>lua Snacks.picker.grep()<cr>",                  desc = "Find grep_tring" },
    { "<leader>fr", "<cmd>lua Snacks.picker.resume()<cr>",                desc = "Find search history" },
    { "gf",         "<cmd>lua Snacks.picker.lsp_references()<CR>",        nowait = true,               desc = "References" },
    { "gi",         "<cmd>lua Snacks.picker.lsp_implementations()<CR>",   desc = "goto Implementation" },
    { "gd",         "<cmd>lua Snacks.picker.lsp_definitions()<CR>",       desc = "definition" },
    { "gD",         "<cmd>lua Snacks.picker.lsp_declarations()<CR>",      desc = "Declaration" },
    { "gt",         "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>",  desc = "Type Definitions" },
    -- { "go",         "<cmd>lua Snacks.picker.diagnostics()<cr>",           desc = "diagnostic" },
    { "gO",         "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>",    desc = "Buffer diagnostic" },
    { "gs",         "<cmd>lua Snacks.picker.lsp_symbols()<CR>",           desc = "Symbols" },
    { "gS",         "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>", desc = "Workspace Symbols" },
    -- git
    { "<leader>so", function() Snacks.lazygit.open() end,                 desc = "Lazygit open" },
    { "<leader>sb", function() Snacks.picker.git_branches() end,          desc = "Git Branches" },
    { "<leader>sl", function() Snacks.picker.git_log() end,               desc = "Git Log" },
    { "<leader>sL", function() Snacks.picker.git_log_line() end,          desc = "Git Log Line" },
    { "<leader>ss", function() Snacks.picker.git_status() end,            desc = "Git Status" },
    { "<leader>sS", function() Snacks.picker.git_stash() end,             desc = "Git Stash" },
    { "<leader>sd", function() Snacks.picker.git_diff() end,              desc = "Git Diff (Hunks)" },
    { "<leader>sf", function() Snacks.picker.git_log_file() end,          desc = "Git Log File" },
  },
  opts = {
    bigfile = { enabled = false },
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = {
      enabled = true,
      top_down = false, -- place notifications from top to bottom
    },
    terminal = terminal_options(),
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  },
  init = function()
    local progress = vim.defaulttable()
    vim.api.nvim_create_autocmd("LspProgress", {
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params.value
        if not client or type(value) ~= "table" then
          return
        end
        local p = progress[client.id]

        for i = 1, #p + 1 do
          if i == #p + 1 or p[i].token == ev.data.params.token then
            p[i] = {
              token = ev.data.params.token,
              msg = ("[%3d%%] %s%s"):format(
                value.kind == "end" and 100 or value.percentage or 100,
                value.title or "",
                value.message and (" **%s**"):format(value.message) or ""
              ),
              done = value.kind == "end",
            }
            break
          end
        end

        local msg = {} ---@type string[]
        progress[client.id] = vim.tbl_filter(function(v)
          return table.insert(msg, v.msg) or not v.done
        end, p)

        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(table.concat(msg, "\n"), "info", {
          id = "lsp_progress",
          title = client.name,
          opts = function(notif)
            notif.icon = #progress[client.id] == 0 and " "
                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end,
        })
      end,
    })
  end
}
