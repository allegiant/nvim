" Give more space for displaying messages.
set cmdheight=1

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

autocmd FileType vue let b:coc_pairs_disabled = ['<']

call g:Keymap_coc()
