local environment = require('environment')
local wezterm = require('wezterm')

local font = {
  font = wezterm.font_with_fallback({
    {
      family = 'Berkeley Mono',
      -- family = 'JetBrains Mono',
    },
    'Iosevka',
    'LXGW Bright',
    'Symbols Nerd Font Mono',
  }),
  font_size = 16,
}

local window_padding = { top = 0, left = 0, right = 0, bottom = 0 }

if environment.os == 'mac' then
  font.line_height = 1

  window_padding.top = 0
  window_padding.bottom = 0
  window_padding.left = 6
  window_padding.right = 6
elseif environment.os == 'windows' then
  font = {
    font = wezterm.font({
      family = 'Cascadia Code',
      harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' },
    }),
    font_size = 12.0,
  }

  window_padding.top = 12
  window_padding.bottom = 12
  window_padding.left = 12
  window_padding.right = 12
else
end

if environment.zellij then
  window_padding = { top = 0, left = 0, right = 0, bottom = 0 }
end

local function resolve_tab_bar_colors(colors, is_dark)
  local tab_bar = colors.tab_bar or {}
  -- local tab_bar = {}

  local active_tab = tab_bar.active_tab
    or {
      bg_color = colors.background or colors.ansi[1],
      fg_color = colors.ansi[6],
    }
  local inactive_tab = tab_bar.inactive_tab or {
    bg_color = colors.brights[1],
    fg_color = colors.brights[8],
  }
  local bg = tab_bar.background or colors.ansi[6]

  return {
    background = bg,
    active_tab = active_tab,
    inactive_tab = inactive_tab,
    inactive_tab_hover = tab_bar.inactive_tab_hover or active_tab,
    new_tab = tab_bar.new_tab or inactive_tab,
    new_tab_hover = tab_bar.new_tab_hover or active_tab,
    inactive_tab_edge = tab_bar.inactive_tab_edge or bg,
  }
end

local function is_dark()
  if wezterm.gui then
    return wezterm.gui.get_appearance():find('Dark')
  end
  return true
end

---@diagnostic disable-next-line: unused-local, unused-function
local function load_toml_colors(fname)
  local colors, _ = wezterm.color.load_scheme(wezterm.config_dir .. '/colors/' .. fname)
  return colors
end

local function get_colors()
  local nolight = false
  local isdark = is_dark()
  -- local colors = wezterm.color.get_builtin_schemes()['GruvboxDark']
  -- local colors = require("colors.json").colors()
  -- local colors = wezterm.color.get_default_colors()
  -- local colors = require('colors.kanagawa').colors()
  -- local colors = load_toml_colors(isdark and 'NvimDark.toml' or 'NvimLight.toml')
  local colors = require(('colors.%s'):format(isdark and 'kanagawa_dragon' or 'kanagawa_light')).colors()
  if not nolight then
    colors.cursor_bg = '#EBCB8B'
    colors.cursor_fg = '#FFFFFF'
    colors.cursor_border = '#EBCB8B'
  end
  colors.tab_bar = resolve_tab_bar_colors(colors, isdark)
  return colors
end

local function setup(config)
  config.font = font.font
  config.font_size = font.font_size
  config.freetype_load_target = 'HorizontalLcd'
  config.tab_bar_at_bottom = false
  config.enable_tab_bar = not environment.zellij
  config.line_height = font.line_height
  config.cursor_blink_ease_in = 'Constant'
  config.cursor_blink_ease_out = 'Constant'
  config.underline_thickness = '1pt'
  config.window_padding = window_padding
  config.color_scheme_dirs = { '~/.config/wezterm/colors' }
  -- config.color_scheme = is_dark() and 'OneNord' or 'OneNord Light'
  config.force_reverse_video_cursor = true
  config.inactive_pane_hsb = {
    saturation = 1,
    brightness = 1,
  }
  config.colors = get_colors()
end

return {
  setup = setup,
}
