return {
  enbaled = false,
  "CRAG666/code_runner.nvim",
  -- config = true,
  opts = {
  },
  config = function()
    require("code_runner").setup({
      mode = "float",
      float = {
        border = "single"
      }
    })
    require("core.mappings").code_runner()
  end
}
