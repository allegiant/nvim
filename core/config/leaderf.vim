let g:Lf_WindowPosition = 'popup'

" 打开文件模糊匹配
let g:Lf_ShortcutF = '<leader>ff'

" 打开 buffer 模糊匹配
let g:Lf_ShortcutB = '<leader>fb'

noremap <silent><leader>fw :Leaderf rg --current-buffer<CR>
noremap <silent><leader>fs :Leaderf rg <CR>
noremap <silent><leader>fr :<C-U>Leaderf! rg --recall<CR>

" 打开最近使用的文件 MRU，进行模糊匹配
noremap <silent><leader>fn :LeaderfMru<cr>

" 打开函数列表，按 i 进入模糊匹配，ESC 退出
noremap <silent><leader>fo :LeaderfFunction!<cr>

" 打开 tag 列表，i 进入模糊匹配，ESC退出
noremap <silent><leader>ft :LeaderfBufTag!<cr>

" 全局 tags 模糊匹配
noremap <m-m> :LeaderfTag<cr>

" 最大历史文件保存 2048 个
let g:Lf_MruMaxFiles = 2048

" ui 定制
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

" 显示绝对路径
let g:Lf_ShowRelativePath = 0

" 隐藏帮助
let g:Lf_HideHelp = 1

" 模糊匹配忽略扩展名
let g:Lf_WildIgnore = {
			\ 'dir': ['.svn','.git','.hg'],
			\ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
			\ }

" MRU 文件忽略扩展名
let g:Lf_MruFileExclude = ['*.so', '*.exe', '*.py[co]', '*.sw?', '~$*', '*.bak', '*.tmp', '*.dll']
let g:Lf_StlColorscheme = 'powerline'

" 禁用 function/buftag 的预览功能，可以手动用 p 预览
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

" 使用 ESC 键可以直接退出 leaderf 的 normal 模式
let g:Lf_NormalMap = {
		\ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
		\ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<cr>']],
		\ "Mru": [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<cr>']],
		\ "Tag": [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<cr>']],
		\ "BufTag": [["<ESC>", ':exec g:Lf_py "bufTagExplManager.quit()"<cr>']],
		\ "Function": [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<cr>']],
		\ }
