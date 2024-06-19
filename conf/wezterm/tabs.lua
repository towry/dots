local wezterm = require('wezterm')
local util = require('utils')

--- @see https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html?h=pl_right_hard_divider
-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_lower_left_triangle

local function get_pane_cwd(pane)
  if not pane or not pane.current_working_dir then
    return '~'
  end
  local cwd = pane.current_working_dir.file_path
  if not cwd then
    return '~'
  end
  return util.basename(cwd)
end
-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
-- @see https://wezfurlong.org/wezterm/config/lua/TabInformation.html?h=tab_id
local function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if not title or #title <= 0 then
    title = nil
  end
  get_pane_cwd(tab_info.active_pane)
  -- Otherwise, use the title from the active pane
  -- in that tab
  return (tab_info.tab_index + 1) .. ': ' .. (title or get_pane_cwd(tab_info.active_pane))
end

return {
  setup = function(config)
    config.show_new_tab_button_in_tab_bar = false
    config.hide_tab_bar_if_only_one_tab = false
    config.use_fancy_tab_bar = false
    config.tab_max_width = 26
    wezterm.on('update-status', function(window, pane)
      local current_workspace = window:active_workspace()
      local right_status_string = ''
      right_status_string = right_status_string .. current_workspace
      window:set_right_status(right_status_string .. ' ')
    end)
    wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
      local colors = config.colors
      local tab_bar_colors = colors.tab_bar

      local edge_background = tab_bar_colors.inactive_tab_edge
      local background = tab_bar_colors.inactive_tab.bg_color
      local foreground = tab_bar_colors.inactive_tab.fg_color

      if tab.is_active then
        background = tab_bar_colors.active_tab.bg_color
        foreground = tab_bar_colors.active_tab.fg_color
      elseif hover then
        background = tab_bar_colors.inactive_tab_hover.bg_color
        foreground = tab_bar_colors.inactive_tab_hover.fg_color
      end

      local edge_foreground = background

      local title = tab_title(tab)

      local is_zoomed = false
      for _, pane in ipairs(tab.panes) do
        if pane.is_zoomed then
          is_zoomed = true
          break
        end
      end
      if is_zoomed then
        title = '[z] ' .. title
      end

      -- ensure that the titles fit in the available space,
      -- and that we have room for the edges.
      title = wezterm.truncate_right(title, max_width - 4)

      title = ' ' .. title .. ' '

      return {
        { Attribute = { Intensity = 'Bold' } },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
      }
    end)

    wezterm.on('user-var-changed', function(_, pane, name, value)
      if name == 'ExecuteCommand' then
        local command
        local message

        command, message = value:match('^([^:]+):(.+)')

        if command ~= nil then
          wezterm.emit('command:' .. command, message, pane)
        end
      end
    end)

    wezterm.on('command:into-session', function(message)
      local workspace, cwd = message:match('^(%S+) %-> (.+)')

      if not util.list_contains(wezterm.mux.get_workspace_names(), workspace) then
        wezterm.mux.spawn_window({ workspace = workspace, cwd = cwd })

        local sessions = wezterm.GLOBAL.sessions
        sessions[workspace] = cwd
        wezterm.GLOBAL.sessions = sessions
      end

      wezterm.mux.set_active_workspace(workspace)
    end)
  end,
}
