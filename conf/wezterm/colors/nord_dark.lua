local M = {}
local palette = {
  base = '#2E3440',
  overlay = '#3b4353',
  muted = '#475063',
  text = '#D8DEE9',
  love = '#BF616A',
  gold = '#EBCB8B',
  rose = '#D08770',
  pine = '#88C0D0',
  foam = '#8FBCBB',
  iris = '#B48EAD',
  highlight_high = '#8FBCBB',
}

local active_tab = {
  bg_color = palette.base,
  fg_color = '#ffffff',
}

local inactive_tab = {
  bg_color = palette.pine,
  fg_color = palette.muted,
}

function M.colors()
  return {
    foreground = palette.text,
    background = palette.base,
    cursor_bg = palette.highlight_high,
    cursor_border = palette.highlight_high,
    cursor_fg = palette.text,
    selection_bg = '#2a283e',
    selection_fg = palette.text,
    split = palette.overlay,

    ansi = {
      palette.overlay,
      palette.love,
      palette.pine,
      palette.gold,
      palette.foam,
      palette.iris,
      palette.rose,
      palette.text,
    },

    brights = {
      palette.muted,
      palette.love,
      palette.pine,
      palette.gold,
      palette.foam,
      palette.iris,
      palette.rose,
      palette.text,
    },

    tab_bar = {
      background = palette.muted,
      active_tab = active_tab,
      inactive_tab = inactive_tab,
      inactive_tab_hover = active_tab,
      new_tab = inactive_tab,
      new_tab_hover = active_tab,
      inactive_tab_edge = palette.muted, -- (Fancy tab bar only)
    },
  }
end

function M.window_frame() -- (Fancy tab bar only)
  return {
    active_titlebar_bg = palette.base,
    inactive_titlebar_bg = palette.base,
  }
end
return M
