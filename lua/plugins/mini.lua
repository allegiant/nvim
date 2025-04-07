return {
  {
    'echasnovski/mini.pairs',
    version = '*',
    config = function()
      require('mini.pairs').setup({
        mappings = {
          ['<'] = { action = 'open', pair = '<>', neigh_pattern = '[^\\].' },
          ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\<].", register = { cr = false } },
          ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\&].", register = { cr = false } },
        }
      })
    end
  },
  {
    'echasnovski/mini.comment',
    version = '*',
    config = function()
      require('mini.comment').setup()
    end
  },
  {
    'echasnovski/mini.sessions',
    version = '*',
    opts = {
      file = ""
    },
    config = function()
      require('mini.sessions').setup()
    end
  }
}
