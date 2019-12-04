""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-plug settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')
"
" Autocompletion
"~ Plug 'ncm2/ncm2'
"~ Plug 'roxma/nvim-yarp'
"~ Plug 'ncm2/ncm2-bufword'
"~ Plug 'ncm2/ncm2-path'
"~ Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"~ let g:deoplete#enable_at_startup = 1
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"~ Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }

" Python
"~ Plug 'davidhalter/jedi-vim'
"~ Plug 'ncm2/ncm2-jedi'
"~ Plug 'deoplete-plugins/deoplete-jedi'
Plug 'dense-analysis/ale'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'jeetsukumaran/vim-pythonsense'    " Python motions ([ai][cfd])
Plug 'Shougo/echodoc.vim'               " Show signature in command line
Plug 'Yggdroot/indentLine'              " Show indentation lines

" Debugging
Plug 'vim-vdebug/vdebug'

" LaTeX
Plug 'lervag/vimtex'
Plug 'hura/vim-asymptote'

" Statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Git
Plug 'tpope/vim-fugitive' 
Plug 'gregsexton/gitv'

" Markdown
Plug 'drmingdrmer/vim-syntax-markdown'

" taskwiki
Plug 'vimwiki/vimwiki'
Plug 'tbabej/taskwiki'
Plug 'blindFS/vim-taskwarrior'

" Notmuch
Plug 'adborden/vim-notmuch-address'     " Complete addresses with <C-x><C-u>

Plug 'terryma/vim-multiple-cursors'     " Activate with <C-n>
Plug 'junegunn/vim-easy-align'          " align with ga
Plug 'tpope/vim-surround'               " Changed parenthesis, etc. (command + s + motion)
Plug 'dhruvasagar/vim-table-mode'       " start with \tm 
Plug 'chrisbra/csv.vim'                 " autoloads
Plug 'majutsushi/tagbar'                " Show overview of current file
Plug 'tpope/vim-repeat'                 " Better repeat with .
Plug 'tommcdo/vim-exchange'             " Exchange units (motion)
Plug 'SirVer/ultisnips'                 " Activate with S-Tab
Plug 'moll/vim-bbye'                    " Delete buffers keeping window layout
Plug 'haya14busa/vim-signjk-motion'     " Line motion with tags
Plug 'machakann/vim-highlightedyank'    " Show the yank region
Plug 'vim-scripts/ReplaceWithRegister'  " Activate with gr{motion) (optionally with register)

Plug 'davvil/vim-commentary', { 'branch': 'tilde-comment' } " Changed comments to add ~

" Candidates for removal
Plug 'tpope/tpope-vim-abolish'          " Search for variants of words

Plug 'Shougo/denite.nvim'
Plug 'Shougo/unite.vim'
Plug 'Shougo/unite-outline'
"~ Plug 'godlygeek/csapprox'        " Approximate gvim colors on terminal
"~ Plug '/usr/local/opt/fzf'        " Do I use it? (06.02.2019)
"~ Plug 'justinmk/vim-sneak'        " Expands f to two symbols, remaps s :-(
"~ Plug 'raghur/vim-ghost', {'do': ':GhostInstall'} " Didn't seem to work
call plug#end()

source $VIMRUNTIME/macros/matchit.vim  " Extended matches with %

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ignorecase smartcase            " For searches
set nocompatible                    " Probably not needed with neovim, though
set incsearch
syntax on

" Command line completion
set wildmode=longest,list,full      " Complete the longest prefix, list matches, full match
set wildmenu                        " Show matches in a menu

set path+=**                        " Search in subdirectories
set tabstop=4                       " For actual tabs
set shiftwidth=4                    " For autoindent

set expandtab                       " Substitute tabs with...
set softtabstop=4                   " ...4 spaces

set encoding=utf-8                  " Do we need this in neovim?

set history=100                     " Command line history
set backspace=indent,eol,start      " Sane backspace behaviour
set virtualedit=block               " Allow visual mode over "shorter" lines
set mouse=nv                        " Mouse in normal and visual mode
set cursorline                      " Highlight current line

" Legacy status line, not used by airline
"~ set laststatus=2                 " Always a status line
"~ set statusline=%f(%n)\ %h%r%m\ --\ l:%l\ (%p%%)\ c:%c\ %{TagInStatusLine()}

set signcolumn=yes                  " Column for ale symbols. It is
                                    " distracting if it toggles all the time

set spellsuggest=best,20            " "Smart match", 20 suggestions
set spellfile=vim-spell.utf-8.add   " Local to current directory

"~ set completeopt=menu,longest,preview " Original completion options
set completeopt=noinsert,menuone,noselect " see :help Ncm2PopupOpen for "requirements"

set clipboard=unnamed               " Use the '*' register for yank, etc.

set autoindent                      " Auto-explanatory
set nohlsearch                      " Do not highlight search by default
set hidden                          " Allow to change buffers even if not saved
set number                          " Show line numbers...
set relativenumber                  " ...current line number and offsets

set inccommand=split                " Live preview for substitutions
set shortmess+=c                    " No "match x of y" messages for autocompletion

set exrc                            " Allow project specific .vimrc files
set secure                          " ...but with some restriction (no write ops)
set noshowmode                      " Do not show the -- INSERT -- message
set autochdir

let g:tex_flavor = "latex"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keybindings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map \tw :call TextWidthToggle()<CR>
map \s :set hlsearch!<CR>
map \b :b#<CR>
"Highlight a search, independently of normal search
map \* :exe "Match ".expand("<cword>")<CR>
map <S-Tab> :call NextField(' \{1,}',2,' ',0)<CR>
map! <S-Tab> <C-O>:call NextField(' \{2,}',2,' ',0)<CR>
imap <C-a> <C-o>^
imap <C-e> <C-o>$
map \\ :make
map \ll :VimtexCompileSS<CR>
map \n :lnext<CR>
map \p :lprev<CR>
map \o :TagbarToggle<CR>
map \r :r! replyToMarkdown.sh<CR>
map \h :call ReplyToHTMLQuote()<CR>
nnoremap Q <nop>
nnoremap <tab> <C-w>w
nnoremap <s-tab> <C-w>W

" Use tab for selection menu completions
" See the coc section below
"~ inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
"~ inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
"~ inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

" vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

if has('nvim')
    tnoremap <Esc> <C-\><C-n>
    tnoremap <s-tab> <C-\><C-n><C-w>W
    " Map a double escape in the terminal to one escape (zsh -> vim mode)
    tnoremap <Esc><Esc> <Esc>
    " Set a short timeout so that pressing esc once works nearly inmediately.
    " I shouldn't have too much bindings with common prefixes.
    set tm=500
endif

" Show vim color of current word
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

map <MiddleMouse> <Nop>

nnoremap <C-j> :m+1<CR>
nnoremap <C-k> :m-2<CR>
vnoremap <C-j> :m '>+1<CR>gv
vnoremap <C-k> :m '<-2<CR>gv

" Start a local section in the file (for use with cfg tool). We add the
" <ESC>i pair so that this line is not identified by cfg as a split point
" itself
map <leader>l o-= LOCAL<ESC>A-CONFIG =-<ESC>gcc

"~ inoremap <C-b> <C-o>:Denite bibsearch<CR>  " Have to check what happened to the command

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Filetypes
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"autocmd FileType python setlocal completeopt-=preview
autocmd FileType python IndentLinesEnable
autocmd FileType tex setlocal tw=80 
            \| setlocal spell
            \| imap <buffer> " <c-r>=TexQuotes()<cr>
            \| omap <buffer> ap ?^$\\|^\s*\(\\begin\\|\\end\\|\\label\\|\\item\)?1<CR>//-1<CR>.<CR>

au BufRead,BufNewFile *.tape set filetype=ducttape
au BufRead,BufNewFile *.tconf set filetype=ducttape

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Colors
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set background=dark
set t_Co=256
set termguicolors
colorscheme greenOnBlack

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Function/Command definitions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Frequent typo
command! W w                                      
" Close current buffer but keep window layout
command! Bd Bdelete
" Highlight word without search
command! -nargs=1 Match match MatchGroup <q-args>
" Bind two windows
command! Bind set scrollbind | set cursorbind

function! TextWidthToggle()
    if &tw > 0
        setlocal tw=0
    else
        setlocal tw=80
    endif
endfunction

" function: NextField
" Args: fieldsep,minlensep,padstr,offset
"
" NextField checks the line above for field separators and moves the cursor on
" the current line to the next field. The default field separator is two or more
" spaces. NextField also needs the minimum length of the field separator,
" which is two in this case. If NextField is called on the first line or on a
" line that does not have any field separators above it the function echoes an
" error message and does nothing.

func! NextField(fieldsep,minlensep,padstr,offset)
    let curposn = col(".")
    let linenum = line(".")
    let prevline = getline(linenum-1)
    let curline = getline(linenum)
    let nextposn = matchend(prevline,a:fieldsep,curposn-a:minlensep)+1
    let padding = ""

    if nextposn > strlen(prevline) || linenum == 1 || nextposn == 0
        echo "last field or no fields on line above"
        return
    endif

    echo ""

    if nextposn > strlen(curline)
        if &modifiable == 0
            return
        endif
        let i = strlen(curline)
        while i < nextposn - 1
            let i = i + 1
            let padding = padding . a:padstr
        endwhile
        call setline(linenum,substitute(curline,"$",padding,""))
    endif
    call cursor(linenum,nextposn+a:offset)
    return
endfunc

function! TexQuotes()
        let line = getline(".")
        let curpos = col(".")-1
        let insert = "''"
        
        let left = strpart(line, curpos-1, 1)

        if (left == ' ' || left == '        ' || left == '')
                let insert = '``'
        endif

        return insert        
endfu

" Taken care by coc, see below
"~ let g:no_highlight_group_for_current_word=["Statement", "Comment", "Type", "PreProc"]
"~ function! s:HighlightWordUnderCursor()
"~     let l:syntaxgroup = synIDattr(synIDtrans(synID(line("."), stridx(getline("."), expand('<cword>')) + 1, 1)), "name")

"~     if (index(g:no_highlight_group_for_current_word, l:syntaxgroup) == -1)
"~         exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))
"~     else
"~         exe 'match IncSearch /\V\<\>/'
"~     endif
"~ endfunction
"~ autocmd CursorMoved * call s:HighlightWordUnderCursor()

function! ReplyToHTMLQuote()
    " call append(line('.'), ["<blockquote>"] + split(@+, "\n") + ["</blockquote>"])
    let save_pos = getpos(".")
    let replyLine = search("On.*wrote:")
    execute replyLine+1 'delete _'
    call append(replyLine, ["```{=html5}", "<blockquote>"] + split(@+, "\n") + ["</blockquote>", "```"])
    call setpos(".", save_pos)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGIN CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1
call airline#parts#define_function('pythonhelper', 'TagInStatusLine')
let g:airline#extensions#tagbar#flags = 'f'
"~ let g:airline_section_y = airline#section#create_right(['pythonhelper'])
let g:airline_theme = 'base16_grayscale'
let airline_section_x="%{airline#extensions#tagbar#currenttag()}"
let g:airline_section_y = ""
let g:airline_section_z="%#__accent_bold#%{g:airline_symbols.linenr} %3l% /%L%  C:%-3v"


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ale
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_linters = { 'python': ['flake8', 'pyls'], }
"~ let g:ale_linters = { 'python': ['pylint'], }
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_sign_error = ' ✘'
let g:ale_sign_warning = ' '
highlight ALEWarning guibg=NONE guifg=NONE gui=underline
highlight ALEWarningSign guibg=gray10 guifg=yellow

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" csv
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:csv_highlight_column = 'y'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" coc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Denite
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call denite#custom#map(
      \ 'insert',
      \ '<C-j>',
      \ '<denite:move_to_next_line>',
      \ 'noremap'
      \)
call denite#custom#map(
      \ 'insert',
      \ '<C-k>',
      \ '<denite:move_to_previous_line>',
      \ 'noremap'
      \)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" echodoc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:echodoc_enable_at_startup = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" indentline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:indentLine_enabled = 0  " We want it only for python
let g:indentLine_char = "┊"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ncm2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"~ autocmd BufEnter * call ncm2#enable_for_buffer()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" netrw (builtin)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:netrw_silent = 1              " Do not wait for ENTER after copying over scp

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" table-mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:table_mode_corner="|"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tagbar
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:tagbar_left=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ultisnips
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<s-tab>"
let g:UltiSnipsJumpForwardTrigger="<s-tab>"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-multiple-cursors
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
"highlight link multiple_cursors_visual Visual
"highlight multiple_cursors_visual guibg=orange

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-signjk
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <Leader>j <Plug>(signjk-j)
map <Leader>k <Plug>(signjk-k)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vimtex
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:vimtex_view_method = 'zathura'
" Disable overfull/underfull \hbox
let g:vimtex_quickfix_latexlog = {
      \ 'overfull' : 0,
      \ 'underfull' : 0,
      \ 'font' : 0,
      \ 'packages' : {
      \   'hyperref' : 0,
      \ }
      \}
 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vimwiki
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" We let the handle of tables to vim-table-mode
let g:vimwiki_table_mapping=0
let g:vimwiki_table_auto_fmt=0
