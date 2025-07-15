return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      }
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim" },  -- for curl, log and async functions
    },
    keys = {
      { "<leader>co", "<cmd>CopilotChatToggle<cr>",  desc = "Copilot Open" },
      { "<leader>cm", "<cmd>CopilotChatModels<cr>",  desc = "Copilot (Models)" },
      { "<leader>ca", "<cmd>CopilotChatAgents<cr>",  desc = "Copilot (Panel)" },
      { "<leader>cc", "<cmd>CopilotChatClose<cr>",   desc = "Copilot Close" },
      { "<leader>cp", "<cmd>CopilotChatPrompts<cr>", desc = "Copilot Prompts" },
      { "<leader>cr", "<cmd>CopilotChatReset<cr>",   desc = "Copilot Reset" },
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
