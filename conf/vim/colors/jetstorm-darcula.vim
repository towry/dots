" Jetstorm Darcula - A dark theme inspired by Darcula
" Author: eenaree
" License: MIT

set background=dark
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "jetstorm-darcula"

" Editor colors
hi Normal           guifg=#bcbec3 guibg=#2b2b2b gui=NONE
hi Cursor           guifg=#2b2b2b guibg=#bbbbbb gui=NONE
hi CursorLine       guifg=NONE    guibg=#26282d gui=NONE
hi LineNr           guifg=#606366 guibg=NONE    gui=NONE
hi CursorLineNr     guifg=#a4a3a3 guibg=NONE    gui=NONE

" Search
hi Search           guifg=#ffffff guibg=#214283 gui=NONE
hi IncSearch        guifg=#ffffff guibg=#214283 gui=NONE

" Window/Tab/Menu
hi VertSplit        guifg=#515151 guibg=NONE    gui=NONE
hi TabLine          guifg=#bbbbbb guibg=#3c3f41 gui=NONE
hi TabLineFill      guifg=NONE    guibg=#3c3f41 gui=NONE
hi TabLineSel       guifg=#ffffff guibg=#2f65ca gui=NONE
hi Title            guifg=#589df6 guibg=NONE    gui=bold
hi Visual           guifg=NONE    guibg=#0e293e gui=NONE

" Message
hi ErrorMsg         guifg=#f75464 guibg=NONE    gui=NONE
hi WarningMsg       guifg=#be9117 guibg=NONE    gui=NONE
hi MoreMsg          guifg=#3592c4 guibg=NONE    gui=NONE
hi Question         guifg=#3592c4 guibg=NONE    gui=NONE

" Syntax groups
hi Comment          guifg=#606366 guibg=NONE    gui=italic
hi Constant         guifg=#2cabb8 guibg=NONE    gui=NONE
hi String           guifg=#6aab73 guibg=NONE    gui=NONE
hi Character        guifg=#6aab73 guibg=NONE    gui=NONE
hi Number           guifg=#2cabb8 guibg=NONE    gui=NONE
hi Boolean          guifg=#2cabb8 guibg=NONE    gui=NONE
hi Float            guifg=#2cabb8 guibg=NONE    gui=NONE
hi Identifier       guifg=#bcbec3 guibg=NONE    gui=NONE
hi Function         guifg=#d5b778 guibg=NONE    gui=NONE
hi Statement        guifg=#c77dbb guibg=NONE    gui=NONE
hi Conditional      guifg=#c77dbb guibg=NONE    gui=NONE
hi Repeat           guifg=#c77dbb guibg=NONE    gui=NONE
hi Label            guifg=#c77dbb guibg=NONE    gui=NONE
hi Operator         guifg=#bcbec3 guibg=NONE    gui=NONE
hi Keyword          guifg=#c77dbb guibg=NONE    gui=NONE
hi Type             guifg=#bcbec3 guibg=NONE    gui=NONE
hi Special          guifg=#d0cfff guibg=NONE    gui=NONE
hi Tag              guifg=#d5b778 guibg=NONE    gui=NONE
hi Delimiter        guifg=#bcbec3 guibg=NONE    gui=NONE
hi Debug            guifg=#f75464 guibg=NONE    gui=NONE

" Treesitter groups
hi! link @comment           Comment
hi! link @constant         Constant
hi! link @constant.builtin Boolean
hi! link @string           String
hi! link @string.escape    Special
hi! link @character        Character
hi! link @number           Number
hi! link @boolean          Boolean
hi! link @float            Float
hi! link @function         Function
hi! link @function.call    Function
hi! link @function.builtin Function
hi! link @method           Function
hi! link @constructor      Special
hi! link @keyword          Keyword
hi! link @keyword.function Keyword
hi! link @keyword.operator Operator
hi! link @operator         Operator
hi! link @variable         Identifier
hi! link @variable.builtin Special
hi! link @property         Special
hi! link @field            Special
hi! link @parameter        Identifier
hi! link @type             Type
hi! link @type.builtin     Type
hi! link @tag              Tag
hi! link @tag.delimiter    Delimiter

" LSP groups
hi LspReferenceText       guibg=#0e293e gui=NONE
hi LspReferenceRead       guibg=#0e293e gui=NONE
hi LspReferenceWrite      guibg=#0e293e gui=NONE
hi DiagnosticError        guifg=#f75464 guibg=NONE    gui=NONE
hi DiagnosticWarn         guifg=#be9117 guibg=NONE    gui=NONE
hi DiagnosticInfo         guifg=#3592c4 guibg=NONE    gui=NONE
hi DiagnosticHint         guifg=#6F737A guibg=NONE    gui=NONE
hi DiagnosticUnderlineError guifg=NONE guibg=NONE gui=undercurl guisp=#f75464
hi DiagnosticUnderlineWarn  guifg=NONE guibg=NONE gui=undercurl guisp=#be9117
hi DiagnosticUnderlineInfo  guifg=NONE guibg=NONE gui=undercurl guisp=#3592c4
hi DiagnosticUnderlineHint  guifg=NONE guibg=NONE gui=undercurl guisp=#6F737A

" Git signs
hi GitSignsAdd           guifg=#447152 guibg=NONE gui=NONE
hi GitSignsChange        guifg=#43698d guibg=NONE gui=NONE
hi GitSignsDelete        guifg=#656e76 guibg=NONE gui=NONE

" Completion menu
hi Pmenu               guifg=#bbbbbb guibg=#3c3f41 gui=NONE
hi PmenuSel            guifg=#ffffff guibg=#2f65ca gui=NONE
hi PmenuSbar           guifg=NONE    guibg=#464a4d gui=NONE
hi PmenuThumb          guifg=NONE    guibg=#646464 gui=NONE

" flash.nvim support
hi FlashMatch          guifg=#ffffff guibg=#589df6 gui=bold
hi FlashCurrent        guifg=#ffffff guibg=#be9117 gui=bold
hi FlashLabel          guifg=#ffffff guibg=#f75464 gui=bold

" fzf-lua.nvim support
hi FzfLuaBorder        guifg=#515151 guibg=NONE    gui=NONE
hi FzfLuaCursor        guifg=#ffffff guibg=#589df6 gui=NONE
hi FzfLuaCursorLine    guifg=NONE    guibg=#0e293e gui=NONE
hi FzfLuaSearch        guifg=#ffffff guibg=#214283 gui=NONE
