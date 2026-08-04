local M = {}

M.setup = function()
  ---@type table<integer, { token: any, msg: string, done: boolean }?>
  local progress = {}

  vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("snacks_lsp_progress", { clear = true }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      local value = ev.data.params.value
      if not client or type(value) ~= "table" then
        return
      end

      -- Keep only the latest progress event for this client (avoid multi-token spam)
      local latest = {
        token = ev.data.params.token,
        msg = ("[%3d%%] %s%s"):format(
          value.kind == "end" and 100 or value.percentage or 100,
          value.title or "",
          value.message and (" **%s**"):format(value.message) or ""
        ),
        done = value.kind == "end",
      }
      progress[client.id] = latest.done and nil or latest

      local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      vim.notify(latest.msg, vim.log.levels.INFO, {
        id = "lsp_progress",
        title = client.name,
        opts = function(notif)
          notif.icon = progress[client.id] == nil and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
        end,
      })
    end,
  })
end

return M
