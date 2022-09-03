"======================================================================
"
" keymaps.vim - keymaps start with using <space>
"
"
"======================================================================

let g:mapleader = "\<Space>"
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

"----------------------------------------------------------------------
" window control
"----------------------------------------------------------------------
noremap <silent><leader>= :resize +3<cr>
noremap <silent><leader>- :resize -3<cr>
noremap <silent><leader>, :vertical resize -3<cr>
noremap <silent><leader>. :vertical resize +3<cr>

noremap <silent><leader>nh :nohl<cr>


" replace
noremap <leader>p viw"0p
noremap <leader>y yiw

" fast save
noremap <C-S> :w<cr>
inoremap <C-S> <ESC>:w<cr>

function! g:Keymap_coc()
	inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
	inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

	" Make <CR> to accept selected completion item or notify coc.nvim to format
	" <C-g>u breaks current undo, please make your own choice.
	inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
	                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
	
	function! CheckBackspace() abort
	  let col = col('.') - 1
	  return !col || getline('.')[col - 1]  =~# '\s'
	endfunction
	
	" Use <c-space> to trigger completion.
	if has('nvim')
	  inoremap <silent><expr> <c-space> coc#refresh()
	else
	  inoremap <silent><expr> <c-@> coc#refresh()
	endif
	
	" Use `[g` and `]g` to navigate diagnostics
	" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
	nmap <silent>gk <Plug>(coc-diagnostic-prev)
	nmap <silent>gj <Plug>(coc-diagnostic-next)
	
	" GoTo code navigation.
	nmap <silent>gd <Plug>(coc-definition)
	nmap <silent>gy <Plug>(coc-type-definition)
	nmap <silent>gi <Plug>(coc-implementation)
	nmap <silent>gf <Plug>(coc-references)
	nnoremap <silent>ga  <Plug>(coc-codeaction-line)
	nmap <silent> gr <Plug>(coc-rename)
	nmap <silent><leader>fm :call CocActionAsync('format')<CR>
	" Formatting selected code.
	xmap <leader>fs  <Plug>(coc-format-selected)

	" Use K to show documentation in preview window.
	nnoremap <silent>gh :call ShowDocumentation()<CR>
	
	function! ShowDocumentation()
	  if CocAction('hasProvider', 'hover')
	    call CocActionAsync('doHover')
	  else
	    call feedkeys('K', 'in')
	  endif
	endfunction
	
	" Highlight the symbol and its references when holding the cursor.
	autocmd CursorHold * silent call CocActionAsync('highlight')
	
	augroup mygroup
		autocmd!
  	" Setup formatexpr specified filetype(s).
  	autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  	" Update signature help on jump placeholder.
  	autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
	augroup end
	
	" Add `:Format` command to format current buffer.
	command! -nargs=0 Format :call CocActionAsync('format')
	
	" Add `:Fold` command to fold current buffer.
	command! -nargs=? Fold :call     CocAction('fold', <f-args>)
	
	" Add `:OR` command for organize imports of the current buffer.
	command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')
	
	" Add (Neo)Vim's native statusline support.
	" NOTE: Please see `:h coc-status` for integrations with external plugins that
	" provide custom statusline: lightline.vim, vim-airline.
	set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

	" Mappings for CoCList
	" Show all diagnostics.
	nnoremap <silent><nowait><leader>ca  :<C-u>CocList diagnostics<cr>
	" Manage extensions.
	nnoremap <silent><nowait><leader>ce  :<C-u>CocList extensions<cr>
	" Show commands.
	nnoremap <silent><nowait><leader>cc  :<C-u>CocList commands<cr>
	" Find symbol of current document.
	nnoremap <silent><nowait><leader>co  :<C-u>CocList outline<cr>
	" Search workspace symbols.
	nnoremap <silent><nowait><leader>cs  :<C-u>CocList -I symbols<cr>
	" Do default action for next item.
	nnoremap <silent><nowait><leader>cj  :<C-u>CocNext<CR>
	" Do default action for previous item.
	nnoremap <silent><nowait><leader>ck  :<C-u>CocPrev<CR>
	" Resume latest coc list.
	nnoremap <silent><nowait><leader>cp  :<C-u>CocListResume<CR>
endfunction

function! g:Keymap_nerdtree()
	nmap <silent><leader>e :NERDTreeToggle<CR>
endfunction

function! g:Keymap_lightline()
	nmap <silent><Tab> :bnext<CR>
	nmap <silent><S-Tab> :bprev<CR>

	nmap <Leader>1 <Plug>lightline#bufferline#go(1)
	nmap <Leader>2 <Plug>lightline#bufferline#go(2)
	nmap <Leader>3 <Plug>lightline#bufferline#go(3)
	nmap <Leader>4 <Plug>lightline#bufferline#go(4)
	nmap <Leader>5 <Plug>lightline#bufferline#go(5)
	nmap <Leader>6 <Plug>lightline#bufferline#go(6)
	nmap <Leader>7 <Plug>lightline#bufferline#go(7)
	nmap <Leader>8 <Plug>lightline#bufferline#go(8)
	nmap <Leader>9 <Plug>lightline#bufferline#go(9)
	nmap <Leader>0 <Plug>lightline#bufferline#go(10)
	nmap <Leader>d1 <Plug>lightline#bufferline#delete(1)
	nmap <Leader>d2 <Plug>lightline#bufferline#delete(2)
	nmap <Leader>d3 <Plug>lightline#bufferline#delete(3)
	nmap <Leader>d4 <Plug>lightline#bufferline#delete(4)
	nmap <Leader>d5 <Plug>lightline#bufferline#delete(5)
	nmap <Leader>d6 <Plug>lightline#bufferline#delete(6)
	nmap <Leader>d7 <Plug>lightline#bufferline#delete(7)
	nmap <Leader>d8 <Plug>lightline#bufferline#delete(8)
	nmap <Leader>d9 <Plug>lightline#bufferline#delete(9)
	nmap <Leader>d0 <Plug>lightline#bufferline#delete(10)
endfunction

function! g:Keymap_floaterm()
	nnoremap   <silent>   <C-\>   :FloatermToggle<CR>
	tnoremap   <silent>   <C-\>   <C-\><C-n>:FloatermToggle<CR>
endfunction

function! g:Keymap_gitgutter()
	nnoremap <silent><leader>sj <Plug>(GitGutterNextHunk)<CR>
	nnoremap <silent><leader>sk  <Plug>(GitGutterPrevHunk)<CR>
endfunction
