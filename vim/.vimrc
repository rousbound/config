" ------  PLUGINS -------

"let g:coc_node_path = '/usr/local/node-v12.18.3-linux-x64/bin/node'
call plug#begin('~/.vim/plugged') "PlugInstall pluginName
Plug 'SirVer/ultisnips'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'cormacrelf/vim-colors-github'
Plug 'habamax/vim-godot'
Plug 'vim-airline/vim-airline'
"Plug 'gerw/vim-latex-suite'
Plug 'lervag/vimtex'
Plug 'junegunn/goyo.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'mileszs/ack.vim'
"Plug 'airblade/vim-gitgutter'
"Plug 'powerline/powerline'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
"Plug 'bagrat/vim-buffet'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsSnippetDirectories=["mySnippets"]
call plug#end()
":source /home/geraldo/.vim/matchit.vim

"-------- FUNCTIONS ------
command Hardcopy call Hardcopy()
function! Hardcopy()
  let colors_save = g:colors_name
  colorscheme default
  hardcopy
  execute 'colorscheme' colors_save
endfun

function! GetActiveBuffers()
    let l:blist = getbufinfo()
    let l:result = []
    for l:item in l:blist
        "skip unnamed buffers; also skip hidden buffers?
        if empty(l:item.name) 
            continue
        endif
        let filename = matchstr(l:item.name,  '/\w\+\..*$')
        "call add(l:result, shellescape(l:item.name))
        call add(l:result, shellescape(filename))
    endfor
    return l:result
endfunction

function! RefreshBuffersNames()
  let &titlestring = join(GetActiveBuffers()) "@%
endfunction

"-------- AUTOCMDS ------

" Matching tags in html
filetype plugin on
runtime macros/matchit.vim
autocmd filetype css setlocal equalprg=csstidy\ -\ --silent=true
autocmd BufWritePost *.tex silent! execute "!smartLatex % " | redraw!
autocmd BufWritePost *.lua silent! execute "!scpDeployAlfa % " | redraw!
autocmd BufWritePost *.js silent! execute "!scpDeployAlfa % " | redraw!
autocmd BufWritePost *.lp silent! execute "!scpDeployAlfa % " | redraw!
autocmd BufWritePost *.sql silent! execute "!scpDeployAlfa % " | redraw!
autocmd BufWritePost *.sh silent! execute "!scpDeployAlfa % " | redraw!
autocmd BufEnter *.tex silent! execute ":set tw=80" | redraw!
autocmd BufWritePost *.md silent! execute "!quickMd % >/dev/null 2>&1" | redraw!
autocmd BufWritePost *.ly silent! execute "!lilypond % >/dev/null 2>&1" | redraw!
autocmd BufWritePost *.li silent! execute "!compileSmartLilypond.py % >/dev/null 2>&1" | redraw!
autocmd filetype html UltiSnipsAddFiletypes html
"autocmd filetype lp UltiSnipsAddFiletypes html
autocmd BufNewFile,BufRead *.lp UltiSnipsAddFiletypes html
autocmd BufNewFile,BufRead *.cls   set syntax=tex
"au FocusGained,BufEnter * :silent! checktime
"au FocusLost,WinLeave * :silent! w
"au WinEnter * :silent! :e <cr>
:au CursorHold * checktime
au BufReadPost *.lp set syntax=html
":au CursorHold * call RefreshBuffersNames()


    


"-------- SETS ----------
:set encoding=utf-8
:scriptencoding utf-8
:set listchars=tab:\|\ 
:set list

set clipboard=unnamedplus
let g:tex_flavor = "latex"
"setlocal foldlevel=999
syntax on
let g:vimtex_fold_manual = 1

let g:goyo_height = 95
let g:airline#extensions#tabline#enabled = 0
:set titlestring=%t
"let &titlestring = @%
"set title
"let &titlestring = join(GetActiveBuffers()) "@%
":call RefreshBuffersNames()
set noswapfile
set autoread
set laststatus=2
set hidden
":set viminfo='1000,f1
":set tw=100
":set fo+=t
set showcmd
set tabstop=4 softtabstop=0 shiftwidth=4 smarttab
set number relativenumber

:colorscheme ron
:filetype indent on
:set smartindent

"RefreshBuffersNames()
"--------- MAPS ---------

nnoremap <F1> :noautocmd w<cr>
map <F10> :Goyo <cr>
"map k gk
"map j gj
vmap ++ <plug>NERDCommenterToggle
nmap ++ <plug>NERDCommenterToggle
map <C-w> :bwipeout <cr> ":call RefreshBuffersNames() <cr>
map <leader>1 :b1 <cr>
map <leader>2 :b2 <cr>
map <leader>3 :b3 <cr>
map <F6> :setlocal spell! spelllang=pt_br<CR>
"map <F12> :setlocal spell! spelllang=en_us<CR>
map <F2> :!doppelganger <CR> <CR>
map <F7> :!refactor % 
map <F8> :.,$s///gc
map <F10> :%!sqlformat --reindent --keywords upper --identifiers lower - <CR>
map <F3> :set number! relativenumber! <CR> 
map <S-m> :!mirror % <CR> <CR>
map <C-b> :ls <CR>
map <leader>ue :UltiSnipsEdit
"map <C-m> :!mitosis 
map <C-s> :w <CR> y 
map <s-h> :bp <CR>
map <s-l> :bn <CR>
map <F4> :argdo execute 'normal gg=G' | update

hi clear Conceal "Very important for conceal color

"Coc Vim


"set shortmess+=c


""if has("patch-8.1.1564")
  """ Recently vim can merge signcolumn and number column into one
  ""set signcolumn=number
""else
  ""set signcolumn=yes
""endif

"" Use tab for trigger completion with characters ahead and navigate.
"" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
"" other plugin before putting this into your config.
"inoremap <silent><expr> <TAB>
      "\ pumvisible() ? "\<C-n>" :
      "\ <SID>check_back_space() ? "\<TAB>" :
      "\ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

"function! s:check_back_space() abort
  "let col = col('.') - 1
  "return !col || getline('.')[col - 1]  =~# '\s'
"endfunction

"" Use <c-space> to trigger completion.
"if has('nvim')
  "inoremap <silent><expr> <c-space> coc#refresh()
"else
  "inoremap <silent><expr> <c-@> coc#refresh()
"endif

"" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
"" position. Coc only does snippet and additional edit on confirm.
"" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
"if exists('*complete_info')
  "inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
"else
  "inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"endif

"" Use `[g` and `]g` to navigate diagnostics
"" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
"nmap <silent> [g <Plug>(coc-diagnostic-prev)
"nmap <silent> ]g <Plug>(coc-diagnostic-next)

"" GoTo code navigation.
"nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)

"" Use K to show documentation in preview window.
"nnoremap <silent> K :call <SID>show_documentation()<CR>

"function! s:show_documentation()
  "if (index(['vim','help'], &filetype) >= 0)
    "execute 'h '.expand('<cword>')
  "else
    "call CocAction('doHover')
  "endif
"endfunction

"" Highlight the symbol and its references when holding the cursor.
"autocmd CursorHold * silent call CocActionAsync('highlight')

"" Symbol renaming.
"nmap <leader>rn <Plug>(coc-rename)

"" Formatting selected code.
"xmap <leader>f  <Plug>(coc-format-selected)
"nmap <leader>f  <Plug>(coc-format-selected)

"augroup mygroup
  "autocmd!
  "" Setup formatexpr specified filetype(s).
  "autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  "" Update signature help on jump placeholder.
  "autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
"augroup end

"" Applying codeAction to the selected region.
"" Example: `<leader>aap` for current paragraph
"xmap <leader>a  <Plug>(coc-codeaction-selected)
"nmap <leader>a  <Plug>(coc-codeaction-selected)

"" Remap keys for applying codeAction to the current buffer.
"nmap <leader>ac  <Plug>(coc-codeaction)
"" Apply AutoFix to problem on the current line.
"nmap <leader>qf  <Plug>(coc-fix-current)

"" Map function and class text objects
"" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
"xmap if <Plug>(coc-funcobj-i)
"omap if <Plug>(coc-funcobj-i)
"xmap af <Plug>(coc-funcobj-a)
"omap af <Plug>(coc-funcobj-a)
"xmap ic <Plug>(coc-classobj-i)
"omap ic <Plug>(coc-classobj-i)
"xmap ac <Plug>(coc-classobj-a)
"omap ac <Plug>(coc-classobj-a)

"" Use CTRL-S for selections ranges.
"" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
"nmap <silent> <C-s> <Plug>(coc-range-select)
"xmap <silent> <C-s> <Plug>(coc-range-select)

"" Add `:Format` command to format current buffer.
"command! -nargs=0 Format :call CocAction('format')

"" Add `:Fold` command to fold current buffer.
"command! -nargs=? Fold :call     CocAction('fold', <f-args>)

"" Add `:OR` command for organize imports of the current buffer.
"command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

"" Add (Neo)Vim's native statusline support.
"" NOTE: Please see `:h coc-status` for integrations with external plugins that
"" provide custom statusline: lightline.vim, vim-airline.
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

"" Mappings for CoCList
"" Show all diagnostics.
"nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
"" Manage extensions.
"nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
"" Show commands.
"nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
"" Find symbol of current document.
"nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
"" Search workspace symbols.
"nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
"" Do default action for next item.
"nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
"" Do default action for previous item.
"nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
"" Resume latest coc list.
"nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
