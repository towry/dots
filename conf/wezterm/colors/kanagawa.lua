return {
  colors = function()
    return {
      tab_bar = {
        background = '#16161D',
        inactive_tab = {
          bg_color = '#363646',
          fg_color = '#9e9e9e',
        },
        active_tab = {
          bg_color = '#938aa9',
          fg_color = '#f9f9f9',
        },
      },
      foreground = '#dcd7ba',
      background = '#1f1f28',

      cursor_bg = '#c8c093',
      cursor_fg = '#c8c093',
      cursor_border = '#c8c093',

      selection_fg = '#c8c093',
      selection_bg = '#2d4f67',

      scrollbar_thumb = '#16161d',
      split = '#16161d',

      ansi = { '#090618', '#c34043', '#76946a', '#c0a36e', '#7e9cd8', '#957fb8', '#6a9589', '#c8c093' },
      brights = { '#727169', '#e82424', '#98bb6c', '#e6c384', '#7fb4ca', '#938aa9', '#7aa89f', '#dcd7ba' },
      indexed = { [16] = '#ffa066', [17] = '#ff5d62' },
    }
  end,
}
