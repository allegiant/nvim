local vim_g = vim.g
--disable_distribution_plugins
vim_g.loaded_gzip = 1
vim_g.loaded_tar = 1
vim_g.loaded_tarPlugin = 1
vim_g.loaded_zip = 1
vim_g.loaded_zipPlugin = 1
vim_g.loaded_getscript = 1
vim_g.loaded_getscriptPlugin = 1
vim_g.loaded_vimball = 1
vim_g.loaded_vimballPlugin = 1
vim_g.loaded_matchit = 1
vim_g.loaded_matchparen = 1
vim_g.loaded_2html_plugin = 1
vim_g.loaded_logiPat = 1
vim_g.loaded_rrhelper = 1
vim_g.loaded_netrw = 1
vim_g.loaded_netrwPlugin = 1
vim_g.loaded_netrwSettings = 1
vim_g.loaded_netrwFileHandlers = 1

require("core.options")
require("core.autcmds")
require("plugins")
require("core.mappings")
