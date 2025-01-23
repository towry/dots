" Jetstorm Light - A light theme that looks similar to WebStorm New UI
" Author: eenaree
" License: MIT

set background=light
highlight clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "jetstorm-light"

" Editor colors
hi Normal           guifg=#080808 guibg=#ffffff gui=NONE
hi Cursor           guifg=#ffffff guibg=#000000 gui=NONE
hi CursorLine       guifg=NONE    guibg=#f4f8fe gui=NONE
hi LineNr           guifg=#6c707e guibg=NONE    gui=NONE
hi CursorLineNr     guifg=#000000 guibg=NONE    gui=NONE

" Search
hi Search           guifg=#000000 guibg=#fdc449 gui=NONE
hi IncSearch        guifg=#000000 guibg=#fdc449 gui=NONE

" Window/Tab/Menu
hi VertSplit        guifg=#ebecf0 guibg=NONE    gui=NONE
hi TabLine          guifg=#6c707e guibg=#f7f8fa gui=NONE
hi TabLineFill      guifg=NONE    guibg=#f7f8fa gui=NONE
hi TabLineSel       guifg=#000000 guibg=#ffffff gui=NONE
hi Title            guifg=#000000 guibg=NONE    gui=bold
hi Visual           guifg=NONE    guibg=#d5e1ff gui=NONE

" Message
hi ErrorMsg         guifg=#cf5b56 guibg=NONE    gui=NONE
hi WarningMsg       guifg=#f1bf56 guibg=NONE    gui=NONE
hi MoreMsg          guifg=#4781fa guibg=NONE    gui=NONE
hi Question         guifg=#4781fa guibg=NONE    gui=NONE

" Syntax groups
hi Comment          guifg=#8c8c8c guibg=NONE    gui=italic
hi Constant         guifg=#238f8f guibg=NONE    gui=NONE
hi String           guifg=#077d18 guibg=NONE    gui=NONE
hi Character        guifg=#077d18 guibg=NONE    gui=NONE
hi Number           guifg=#1750eb guibg=NONE    gui=NONE
hi Boolean          guifg=#238f8f guibg=NONE    gui=NONE
hi Float            guifg=#1750eb guibg=NONE    gui=NONE
hi Identifier       guifg=#238f8f guibg=NONE    gui=NONE
hi Function         guifg=#006279 guibg=NONE    gui=NONE
hi Statement        guifg=#0133b3 guibg=NONE    gui=NONE
hi Conditional      guifg=#0133b3 guibg=NONE    gui=NONE
hi Repeat           guifg=#0133b3 guibg=NONE    gui=NONE
hi Label            guifg=#0133b3 guibg=NONE    gui=NONE
hi Operator         guifg=#080808 guibg=NONE    gui=NONE
hi Keyword          guifg=#0133b3 guibg=NONE    gui=NONE
hi Type             guifg=#080808 guibg=NONE    gui=NONE
hi Special          guifg=#861194 guibg=NONE    gui=NONE
hi Tag              guifg=#0133b3 guibg=NONE    gui=NONE
hi Delimiter        guifg=#080808 guibg=NONE    gui=NONE
hi Debug            guifg=#cf5b56 guibg=NONE    gui=NONE

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
hi LspReferenceText       guibg=#d5e1ff gui=NONE
hi LspReferenceRead       guibg=#d5e1ff gui=NONE
hi LspReferenceWrite      guibg=#d5e1ff gui=NONE
hi DiagnosticError        guifg=#cf5b56 guibg=NONE    gui=NONE
hi DiagnosticWarn         guifg=#f1bf56 guibg=NONE    gui=NONE
hi DiagnosticInfo         guifg=#4781fa guibg=NONE    gui=NONE
hi DiagnosticHint         guifg=#6c707e guibg=NONE    gui=NONE
hi DiagnosticUnderlineError guifg=NONE guibg=NONE gui=undercurl guisp=#cf5b56
hi DiagnosticUnderlineWarn  guifg=NONE guibg=NONE gui=undercurl guisp=#f1bf56
hi DiagnosticUnderlineInfo  guifg=NONE guibg=NONE gui=undercurl guisp=#4781fa
hi DiagnosticUnderlineHint  guifg=NONE guibg=NONE gui=undercurl guisp=#6c707e

" Git signs
hi GitSignsAdd           guifg=#0a7700 guibg=NONE gui=NONE
hi GitSignsChange        guifg=#0032a0 guibg=NONE gui=NONE
hi GitSignsDelete        guifg=#616161 guibg=NONE gui=NONE

" Completion menu
hi Pmenu               guifg=#000000 guibg=#ffffff gui=NONE
hi PmenuSel            guifg=#000000 guibg=#d5e1ff gui=NONE
hi PmenuSbar           guifg=NONE    guibg=#ebecf0 gui=NONE
hi PmenuThumb          guifg=NONE    guibg=#c8ccd6 gui=NONE

" flash.nvim support
hi FlashMatch          guifg=#ffffff guibg=#4781fa gui=bold
hi FlashCurrent        guifg=#ffffff guibg=#f1bf56 gui=bold
hi FlashLabel          guifg=#ffffff guibg=#cf5b56 gui=bold

" fzf-lua.nvim support
hi FzfLuaBorder        guifg=#ebecf0 guibg=NONE    gui=NONE
hi FzfLuaCursor        guifg=#ffffff guibg=#4781fa gui=NONE
hi FzfLuaCursorLine    guifg=NONE    guibg=#d5e1ff gui=NONE
hi FzfLuaSearch        guifg=#000000 guibg=#fdc449 gui=NONE
