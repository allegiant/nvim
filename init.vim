let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
command! -nargs=1 IncScript exec 'so '. fnameescape(s:home."/<args>")
exec 'set rtp+='.s:home
exec 'set rtp+=~/.vim'

IncScript core/init.vim
IncScript core/ignores.vim
IncScript core/keymaps.vim
IncScript core/plugins.vim
IncScript core/style.vim
