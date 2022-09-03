function! IsWSL()
  if has("unix")
    let lines = readfile("/proc/version")
    if lines[0] =~ "WSL"
      return 1
    endif
  endif
  return 0
endfunction

if IsWSL()
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[3 q"
  let &t_EI = "\<Esc>[2 q"
endif

if has('termguicolors')
  set termguicolors
endif

if !has('gui_running')
  set t_Co=256
endi

" 总是显示状态栏
set laststatus=2
" 总是显示行号
set number
set relativenumber
" 总是显示侧边栏（用于显示 mark/gitdiff/诊断信息）
set signcolumn=yes
" 总是显示标签栏
set showtabline=2
" 右下角显示命令
set showcmd

" 插入模式不在状态栏下面显示 -- INSERT --
set noshowmode

" 水平切割窗口时，默认在右边显示新窗口
set splitright

set background=light

let g:gruvbox_material_background = 'soft'

let g:gruvbox_material_better_performance = 1

colorscheme gruvbox-material
