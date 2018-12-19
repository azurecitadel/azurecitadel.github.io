" Vim color file
" Maintainer:   Richard Cheney (from delek.vim)
" Last Change:  2018 Apr 09

hi clear

let g:colors_name = "cloudshell"

" Normal should come first
hi Normal     guifg=Black  guibg=White
hi Cursor     guifg=bg     guibg=fg
hi lCursor    guifg=NONE   guibg=Cyan

" Note: we never set 'term' because the defaults for B&W terminals are OK
hi DiffAdd    ctermbg=LightBlue
hi DiffChange ctermbg=LightMagenta
hi DiffDelete ctermfg=Blue         ctermbg=LightCyan
hi DiffText   ctermbg=Yellow       cterm=bold
hi Directory  ctermfg=DarkBlue
hi ErrorMsg   ctermfg=White        ctermbg=DarkRed
hi FoldColumn ctermfg=DarkBlue     ctermbg=Grey
hi Folded     ctermbg=Grey         ctermfg=DarkBlue
hi IncSearch  cterm=reverse
hi LineNr     ctermfg=Brown
hi ModeMsg    cterm=bold
hi MoreMsg    ctermfg=DarkGreen
hi NonText    ctermfg=Blue
hi Pmenu      guibg=LightBlue
hi PmenuSel   ctermfg=White        ctermbg=DarkBlue
hi Question   ctermfg=DarkGreen
if &background == "light"
    hi Search     ctermfg=NONE     ctermbg=Yellow
else
    hi Search     ctermfg=Black    ctermbg=Yellow
endif
hi SpecialKey ctermfg=DarkBlue
hi StatusLine cterm=bold           ctermbg=blue ctermfg=yellow
hi StatusLineNC cterm=bold         ctermbg=blue ctermfg=black
hi Title      ctermfg=LightMagenta
hi VertSplit  cterm=reverse
hi Visual     ctermbg=NONE         cterm=reverse
hi VisualNOS  cterm=underline,bold gui=underline,bold
hi WarningMsg ctermfg=Yellow
hi WildMenu   ctermfg=Black        ctermbg=Yellow

" syntax highlighting
hi Comment    cterm=NONE ctermfg=DarkGray
hi Constant   cterm=NONE ctermfg=Green
hi Identifier cterm=NONE ctermfg=Yellow
hi PreProc    cterm=NONE ctermfg=LightMagenta
hi Special    cterm=NONE ctermfg=Cyan
hi Statement  cterm=bold ctermfg=Blue
hi Type       cterm=NONE ctermfg=Blue

" vim: sw=2