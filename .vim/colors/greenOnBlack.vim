" Vim color file
" Maintainer:	David Vilar
" Last Change:	2007 June 11
" green on black

" started from "torte"

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
"colorscheme default
let g:colors_name = "greenOnBlack"

" GUI
highlight Normal       guifg=palegreen  guibg=Black
if !exists('g:gui_oni')
    highlight Search       guifg=Black      guibg=lightseagreen  gui=bold
else
    highlight Search       guifg=Black      guibg=darkblue gui=bold
end
highlight Visual       guibg=#0000CD
highlight Cursor       guifg=Black      guibg=gray80	     gui=NONE
highlight lCursor      guifg=Black      guibg=#FFA500	     gui=NONE
highlight Special      guifg=Orange
highlight Comment      guifg=#FF7F24
highlight CommentedCode      guifg=#965a0f
highlight Statement    guifg=#00FFFF		             gui=NONE
highlight Type	          			             gui=NONE
highlight CursorLine                    guibg=#1A1A1A
highlight CursorColumn                  guibg=#1A1A1A
highlight Include      guifg=#B0C4DE
highlight String       guifg=#FFA07A
highlight Type         guifg=#00FFFF
highlight PreProc      guifg=yellow
highlight Pmenu        guifg=black      guibg=gray60
highlight PmenuSel     guifg=white      guibg=gray30
highlight Boolean      guifg=#7FFFD4
highlight StatusLine   guifg=gray75     guibg=black
highlight StatusLineNC guifg=#505B67    guibg=black
highlight Folded       guifg=gray70     guibg=black          gui=bold
highlight helpNote     guifg=yellow
highlight htmlItalic   guifg=green                           gui=NONE
highlight shShellVariables guifg=#EEDD82
highlight MyTagListFileName guifg=white guibg=black          gui=bold
highlight Title        guifg=gray50     guibg=black          gui=bold
highlight VertSplit    guifg=#505B67    guibg=black
highlight MatchGroup   guifg=black      guibg=yellow
highlight TagListTagName guifg=darkgreen guibg=NONE          gui=bold
highlight SpellBad     guifg=red        guibg=gray18         gui=NONE
highlight LineNr       guifg=gray40
highlight CursorLineNr guifg=gray60
highlight SignColumn   guibg=gray10
highlight ALEErrorSign guibg=#840000 guifg=white
highlight ALEWarningSign   guibg=#848211 guifg=black
highlight ALEWarning   guifg=red        guibg=gray18         gui=NONE
highlight IncSearch    guibg=gray20                          gui=NONE
highlight Todo         guifg=yellow     guibg=NONE
highlight CocHighlightText guibg=gray25
