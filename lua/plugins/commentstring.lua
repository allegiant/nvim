local present, configs = pcall(require, "nvim-treesitter.configs")

if not present then
   return
end

local M = {}

local default = {
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
  }
}

M.setup = function()
   configs.setup(default)
end

return M
