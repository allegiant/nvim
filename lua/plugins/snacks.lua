return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
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
    { "go",         "<cmd>lua Snacks.picker.diagnostics()<cr>",           desc = "diagnostic" },
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
