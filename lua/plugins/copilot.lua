return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim" },  -- for curl, log and async functions
    },
    keys = {
      { "<leader>co", "<cmd>CopilotChatToggle<cr>", desc = "Copilot Open" },
      { "<leader>cm", "<cmd>CopilotChatModels<cr>", desc = "Copilot (Models)" },
      { "<leader>ca", "<cmd>CopilotChatAgents<cr>", desc = "Copilot (Panel)" },
    },
    opts = {
      mappings = {
        submit_prompt = {
          normal = '<Leader>cc',
          insert = '<C-s>'
        }
      }
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
