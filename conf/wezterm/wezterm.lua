-- https://wezfurlong.org/wezterm/config/lua/config/index.html
local wezterm = require('wezterm')
local appearance = require('appearance')
local environment = require('environment')
local keys = require('keys')
local tabs = require('tabs')

local config = wezterm.config_builder()

wezterm.GLOBAL.sessions = wezterm.GLOBAL.sessions or {}
-- wezterm.add_to_config_reload_watch_list(wezterm.home_dir .. "/.config/nvim/lua/settings_env.lua")

config.set_environment_variables = {
  -- GIT_EDITOR = 'xargs -I % wezterm cli split-pane -- vim % | read',
}
config.default_prog = (environment.os == 'windows' and { 'pwsh' } or { '/Users/towry/.nix-profile/bin/fish' })
config.unzoom_on_switch_pane = false
config.window_decorations = 'RESIZE'
config.switch_to_last_active_tab_when_closing_tab = true
config.cursor_blink_rate = 0
config.animation_fps = 1
config.enable_csi_u_key_encoding = true
config.enable_kitty_keyboard = true
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.debug_key_events = false
config.adjust_window_size_when_changing_font_size = false

keys.setup(config)
appearance.setup(config)
tabs.setup(config)

return config
