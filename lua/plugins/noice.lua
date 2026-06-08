local function get_hl(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or type(hl) ~= "table" then
    return {}
  end
  return hl
end

local function get_hl_attr(attr, ...)
  for i = 1, select("#", ...) do
    local value = get_hl(select(i, ...))[attr]
    if value ~= nil then
      return value
    end
  end
end

local function noice_hl(attrs)
  local hl = {}
  for key, value in pairs(attrs) do
    if value ~= nil then
      hl[key] = value
    end
  end
  return hl
end

local function single_border(padding)
  return {
    style = "single",
    padding = padding or false,
  }
end

local function noice_float_winhighlight(normal, border, extra)
  return vim.tbl_extend("force", {
    Normal = normal,
    NormalFloat = normal,
    FloatBorder = border,
    FloatTitle = border,
  }, extra or {})
end

local function set_noice_highlights()
  local normal_fg = get_hl_attr("fg", "Normal")
  local cmdline_bg = get_hl_attr("bg", "NormalFloat", "Pmenu", "Normal")
  local border_fg = get_hl_attr("fg", "FloatBorder", "Comment", "Normal")
  local search_fg = get_hl_attr("fg", "CurSearch", "IncSearch", "Search", "FloatBorder", "Comment", "Normal")
  local menu_fg = get_hl_attr("fg", "Pmenu", "Normal")
  local menu_bg = get_hl_attr("bg", "Pmenu", "NormalFloat", "Normal")
  local selected_fg = get_hl_attr("fg", "PmenuSel", "Pmenu", "Normal")
  local selected_bg = get_hl_attr("bg", "PmenuSel", "Pmenu", "NormalFloat", "Normal")
  local muted_fg = get_hl_attr("fg", "Comment", "NonText", "Normal")

  vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", noice_hl({ fg = normal_fg, bg = cmdline_bg }))
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", noice_hl({ fg = border_fg }))
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", noice_hl({ fg = border_fg, bold = true }))
  vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorderSearch", noice_hl({ fg = search_fg }))

  vim.api.nvim_set_hl(0, "NoicePopupmenu", noice_hl({ fg = menu_fg, bg = menu_bg }))
  vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", noice_hl({ fg = border_fg }))
  vim.api.nvim_set_hl(0, "NoicePopupmenuSelected", noice_hl({ fg = selected_fg, bg = selected_bg, bold = true }))
  vim.api.nvim_set_hl(0, "NoicePopupmenuMatch", noice_hl({ fg = search_fg, bg = menu_bg, bold = true }))
  vim.api.nvim_set_hl(0, "NoiceCompletionItemKindDefault", noice_hl({ fg = muted_fg, bg = menu_bg }))
end

local opts = {
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    opts = {
      border = {
        text = false,
      },
    },
  },
  popupmenu = {
    enabled = true,
    backend = "nui",
  },
  messages = {
    enabled = false,
  },
  notify = {
    enabled = false,
  },
  lsp = {
    progress = { enabled = false },
    hover = { enabled = false },
    signature = { enabled = false },
    message = { enabled = false },
  },
  presets = {
    bottom_search = false,
    command_palette = false,
    long_message_to_split = false,
    inc_rename = false,
    lsp_doc_border = false,
  },
  views = {
    cmdline_popup = {
      position = {
        row = "40%",
        col = "50%",
      },
      size = {
        min_width = 60,
        width = "auto",
        height = "auto",
      },
      border = single_border(),
      win_options = {
        winblend = 0,
        winhighlight = noice_float_winhighlight("NoiceCmdlinePopup", "NoiceCmdlinePopupBorder", {
          FloatTitle = "NoiceCmdlinePopupTitle",
          IncSearch = "IncSearch",
          CurSearch = "CurSearch",
          Search = "Search",
        }),
      },
    },
    popupmenu = {
      position = {
        row = "43%",
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = single_border(),
      win_options = {
        winblend = 0,
        winhighlight = noice_float_winhighlight("NoicePopupmenu", "NoicePopupmenuBorder", {
          CursorLine = "NoicePopupmenuSelected",
          PmenuMatch = "NoicePopupmenuMatch",
        }),
      },
    },
    cmdline_popupmenu = {
      border = single_border(),
      win_options = {
        winblend = 0,
        winhighlight = noice_float_winhighlight("NoicePopupmenu", "NoicePopupmenuBorder", {
          CursorLine = "NoicePopupmenuSelected",
          PmenuMatch = "NoicePopupmenuMatch",
        }),
      },
    },
  },
}

local function set_noice_cmdheight()
  local ok, config = pcall(require, "noice.config")
  if ok and config.is_running() then
    vim.opt.cmdheight = 0
  end
end

return {
  "folke/noice.nvim",
  lazy = false,
  priority = 900,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = opts,
  config = function(_, noice_opts)
    set_noice_highlights()
    require("noice").setup(noice_opts)

    local highlight_group = vim.api.nvim_create_augroup("noice_custom_highlights", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = highlight_group,
      callback = set_noice_highlights,
      desc = "Restore noice floating highlights",
    })

    if vim.v.vim_did_enter == 0 then
      local cmdheight_group = vim.api.nvim_create_augroup("noice_cmdheight", { clear = true })
      vim.api.nvim_create_autocmd("VimEnter", {
        group = cmdheight_group,
        once = true,
        callback = function()
          vim.schedule(set_noice_cmdheight)
        end,
        desc = "Use noice floating cmdline after startup",
      })
    else
      vim.schedule(set_noice_cmdheight)
    end
  end,
}
