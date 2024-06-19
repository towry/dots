local wezterm = require('wezterm')
local environment = require('environment')
local utils = require('utils')

local all_characters = [[`1234567890-=qwertyuiop[]\asdfghjkl;'zxcvbnm,./]]
local characters = {}
local cmd_as_alt = false

if cmd_as_alt then
  for i = 1, #all_characters do
    table.insert(characters, all_characters:sub(i, i))
  end
end

local function is_running_tmux(pane)
  return pane:get_title() == 'tmux' or pane:get_lines_as_text(1):sub(2, 4) == '❐'
end

local function create(maps)
  local keys = {}
  local tmux_like = {}
  local seen = {}
  local mod_key = environment.mod

  -- Define all keys and track which are defined
  for _, mapping in ipairs(maps) do
    if not mapping then
      mapping = {}
    end
    if mapping.special == 'leader' then
      -- insert leader mapping
      local leader_mod

      if mapping.mods then
        leader_mod = 'LEADER|' .. mapping.mods
      else
        leader_mod = 'LEADER'
      end

      table.insert(keys, {
        key = mapping.key,
        mods = leader_mod,
        action = mapping.action,
      })

      -- insert keytable mapping
      table.insert(tmux_like, {
        key = mapping.key,
        mods = mapping.mods,
        action = mapping.action,
      })
    elseif mapping.special == 'tmux' then
      local mods = mapping.mods and mapping.mods:gsub('MOD', mod_key)
      local tmux_mods = mapping.mods and mapping.mods:gsub('MOD', 'ALT')
      local key = mapping.key
      local action = mapping.action

      table.insert(keys, {
        key = key,
        mods = mods,
        action = wezterm.action_callback(function(window, pane)
          if is_running_tmux(pane) then
            window:perform_action(wezterm.action.SendKey({ key = key, mods = tmux_mods }), pane)
          else
            window:perform_action(action, pane)
          end
        end),
      })

      seen[mods .. ' ' .. key:lower()] = true
    elseif mapping.special == nil and mapping.key then
      mapping.mods = mapping.mods and mapping.mods:gsub('MOD', mod_key)
      table.insert(keys, mapping)

      seen[(mapping.mods or '') .. ' ' .. mapping.key:lower()] = true
    end
  end

  -- Make CMD behave like ALT on macOS
  if cmd_as_alt and mod_key == 'CMD' then
    for _, key in ipairs(characters) do
      for _, mods in ipairs({ 'CMD', 'CMD|SHIFT' }) do
        local combo = mods .. ' ' .. key

        if not seen[combo] then
          seen[combo] = true

          table.insert(keys, {
            key = key,
            mods = mods,
            action = wezterm.action.SendKey({ key = key, mods = mods:gsub('CMD', 'ALT') }),
          })
        end
      end
    end
  end

  return {
    keys = keys,
    key_tables = {
      tmux_like = tmux_like,
    },
  }
end

local direction_keys = {
  Left = 'h',
  Down = 'j',
  Up = 'k',
  Right = 'l',
  -- reverse lookup
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if utils.is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

local mux_mapping = environment.zellij
    and create({
      -- move between split panes
      split_nav('move', 'h'),
      split_nav('move', 'j'),
      split_nav('move', 'k'),
      split_nav('move', 'l'),
      -- resize panes
      split_nav('resize', 'h'),
      split_nav('resize', 'j'),
      split_nav('resize', 'k'),
      split_nav('resize', 'l'),
      { mods = 'MOD|SHIFT', key = 'p', action = wezterm.action.ActivateCommandPalette },
      { mods = 'MOD', key = 'c', action = wezterm.action.CopyTo('Clipboard') },
      {
        mods = 'MOD|SHIFT',
        key = 'f',
        action = wezterm.action.Search({
          -- use C-u to clear the pattern
          CaseSensitiveString = '',
        }),
      },
      { mods = 'MOD', key = 'v', action = wezterm.action.PasteFrom('Clipboard') },
      { special = 'leader', key = 's', action = wezterm.action.QuickSelect },
    })
  or {}

local mappings = not environment.zellij
    and create({
      not environment.zellij and {
        mods = 'CTRL',
        key = 'z',
        action = wezterm.action_callback(function(window, pane)
          window:perform_action(
            wezterm.action.ActivateKeyTable({ name = 'tmux_like', timeout_millisecons = 5000 }),
            pane
          )
        end),
      } or nil,

      -- move between split panes
      split_nav('move', 'h'),
      split_nav('move', 'j'),
      split_nav('move', 'k'),
      split_nav('move', 'l'),
      -- resize panes
      split_nav('resize', 'h'),
      split_nav('resize', 'j'),
      split_nav('resize', 'k'),
      split_nav('resize', 'l'),
      { mods = 'MOD|SHIFT', key = 'p', action = wezterm.action.ActivateCommandPalette },
      { mods = 'MOD', key = 'c', action = wezterm.action.CopyTo('Clipboard') },
      {
        mods = 'MOD|SHIFT',
        key = 'f',
        action = wezterm.action.Search({
          -- use C-u to clear the pattern
          CaseSensitiveString = '',
        }),
      },
      { mods = 'MOD', key = 'v', action = wezterm.action.PasteFrom('Clipboard') },
      {
        mods = 'MOD|SHIFT',
        key = 'g',
        action = wezterm.action_callback(function(window, pane)
          local info = pane:get_foreground_process_info()
          if not info then
            window:toast_notification('Info', 'No process info', nil, 2000)
            return
          end
          local info_string = table.concat(info.argv, ' ')
          wezterm.log_info('[INFO] ' .. info_string)
          window:perform_action(wezterm.action.ShowDebugOverlay, pane)
          -- window:toast_notification("Info", info_string, nil, 4000)
        end),
      },
      { mods = 'MOD|SHIFT', key = 'n', action = wezterm.action.SpawnWindow },
      { mods = 'CTRL|SHIFT', key = 'r', action = wezterm.action.ShowLauncher },
      { special = 'leader', key = 'L', action = wezterm.action.ShowDebugOverlay },
      { mods = 'CTRL|SHIFT', key = 'f', action = wezterm.action.ToggleFullScreen },
      { mods = 'MOD', key = '[', action = wezterm.action.ActivateTabRelative(-1) },
      { mods = 'MOD', key = ']', action = wezterm.action.ActivateTabRelative(1) },
      { mods = 'CTRL|MOD', key = '1', action = wezterm.action.ActivateTab(0) },
      { mods = 'CTRL|MOD', key = '2', action = wezterm.action.ActivateTab(1) },
      { mods = 'CTRL|MOD', key = '3', action = wezterm.action.ActivateTab(2) },
      { mods = 'CTRL|MOD', key = '4', action = wezterm.action.ActivateTab(3) },
      { mods = 'CTRL|MOD', key = '5', action = wezterm.action.ActivateTab(4) },
      { mods = 'CTRL|MOD', key = '6', action = wezterm.action.ActivateTab(5) },
      { mods = 'CTRL|MOD', key = '7', action = wezterm.action.ActivateTab(6) },
      { mods = 'CTRL|MOD', key = '8', action = wezterm.action.ActivateTab(7) },
      { mods = 'CTRL|MOD', key = '9', action = wezterm.action.ActivateTab(8) },
      { mods = 'MOD', key = 'z', action = wezterm.action.ActivateLastTab },
      { mods = 'MOD', key = '1', action = wezterm.action.ActivateTab(0) },
      { mods = 'MOD', key = '2', action = wezterm.action.ActivateTab(1) },
      { mods = 'MOD', key = '3', action = wezterm.action.ActivateTab(2) },
      { mods = 'MOD', key = '4', action = wezterm.action.ActivateTab(3) },
      { mods = 'MOD', key = '5', action = wezterm.action.ActivateTab(4) },
      { mods = 'MOD', key = '6', action = wezterm.action.ActivateTab(5) },
      { mods = 'MOD', key = '7', action = wezterm.action.ActivateTab(6) },
      { mods = 'MOD', key = '8', action = wezterm.action.ActivateTab(7) },
      { mods = 'MOD', key = '9', action = wezterm.action.ActivateTab(8) },
      { mods = 'SHIFT', key = 'PageUp', action = wezterm.action.ScrollByPage(-1) },
      { mods = 'SHIFT', key = 'PageDown', action = wezterm.action.ScrollByPage(1) },
      { mods = 'SHIFT|MOD', key = 'd', action = wezterm.action.ScrollByPage(0.8) },
      { mods = 'SHIFT|MOD', key = 'u', action = wezterm.action.ScrollByPage(-0.8) },
      { mods = 'CTRL|SHIFT', key = 'b', action = wezterm.action.ScrollToBottom },
      { mods = 'CTRL|SHIFT', key = 't', action = wezterm.action.ScrollToTop },
      { mods = 'SHIFT', key = 'UpArrow', action = wezterm.action.ScrollToPrompt(-1) },
      { mods = 'SHIFT', key = 'DownArrow', action = wezterm.action.ScrollToPrompt(1) },
      { special = 'leader', key = 's', action = wezterm.action.QuickSelect },
      { special = 'leader', key = 'n', action = wezterm.action.SpawnWindow },
      { mods = 'MOD', key = 'n', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
      { special = 'leader', key = 'p', action = wezterm.action.PaneSelect },
      -- { mods = 'MOD', key = 'p', action = wezterm.action.PaneSelect },
      { special = 'leader', key = 'q', action = wezterm.action.ActivateCopyMode },
      { special = 'leader', key = 't', action = wezterm.action.SpawnTab('CurrentPaneDomain') },
      { special = 'leader', key = 'T', action = wezterm.action.SpawnTab('DefaultDomain') },
      { special = 'leader', key = 'u', action = wezterm.action.CharSelect },
      { special = 'leader', key = 'x', action = wezterm.action.CloseCurrentPane({ confirm = true }) },
      { mods = 'MOD', key = 'x', action = wezterm.action.CloseCurrentPane({ confirm = true }) },
      { special = 'leader', key = 'z', action = wezterm.action.TogglePaneZoomState },
      { mods = 'MOD', key = '-', action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },
      { special = 'leader', key = '-', action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },
      {
        special = 'leader',
        key = 'r',
        action = wezterm.action_callback(function(window, pane)
          --- rerun, kill the current pid and send_text the previous command
          local info = pane:get_foreground_process_info()
          if not info then
            return
          end
          -- local pid = info.pid
          local argv = info.argv
          local cmd = table.concat(argv, ' ')
          if utils.basename(cmd) == '' then
            return
          end
          if utils.is_vim(pane) then
            return
          end
          -- os.execute("kill -6 " .. pid)
          window:perform_action(wezterm.action.SendKey({ key = 'c', mods = 'CTRL' }), pane)
          pane:send_text(cmd)
        end),
      },
      {
        special = 'leader',
        key = '/',
        action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
      },
      {
        mods = 'MOD',
        key = '/',
        action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
      },
      {
        special = 'leader',
        key = '_',
        action = wezterm.action.SplitPane({ direction = 'Down', size = { Cells = 6 }, top_level = true }),
      },
      { special = 'leader', key = '<', action = wezterm.action.MoveTabRelative(-1) },
      { special = 'leader', key = '>', action = wezterm.action.MoveTabRelative(1) },

      {
        -- https://github.com/vsiles/config/blob/master/wezterm/wezterm.lua
        special = 'leader',
        key = 'r',
        action = wezterm.action.PromptInputLine({
          description = 'Enter new name for tab',
          action = wezterm.action_callback(function(window, pane, line)
            if line then
              window:active_tab():set_title(line)
            end
          end),
        }),
      },
      {
        --- quick select url in current screen and open it.
        special = 'leader',
        key = 'o',
        action = wezterm.action.QuickSelectArgs({
          label = 'Open URL',
          patterns = { 'https?://\\S+' },
          action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.open_with(url)
          end),
        }),
      },
      {
        special = 'leader',
        key = 'c',
        action = wezterm.action_callback(function(window, pane)
          local workspace = pane:tab():window():get_workspace()
          local cwd = wezterm.GLOBAL.sessions[workspace]

          window:perform_action(wezterm.action.SpawnCommandInNewTab({ cwd = cwd }), pane)
        end),
      },
      {
        --- switch back to default workspace
        special = 'leader',
        key = 'd',
        action = wezterm.action_callback(function(window, pane)
          if window:active_workspace() ~= 'default' then
            window:perform_action(wezterm.action.SwitchToWorkspace({ name = 'default' }), pane)
          end
        end),
      },
      {
        special = 'leader',
        mods = 'CTRL',
        key = 'v',
        action = wezterm.action.ActivateCopyMode,
      },
      {
        mods = 'MOD',
        key = 'w',
        action = wezterm.action.ShowLauncherArgs({ flags = 'WORKSPACES' }),
      },
      -- move back forward between words
      { key = 'h', mods = 'MOD', action = wezterm.action({ SendString = '\x1bb' }) },
      { key = 'l', mods = 'MOD', action = wezterm.action({ SendString = '\x1bf' }) },
      {
        special = 'leader',
        mods = 'CTRL',
        key = 'o',
        action = wezterm.action.RotatePanes('Clockwise'),
      },
    })
  or {}

return {
  setup = function(config)
    local search_mode = wezterm.gui.default_key_tables().search_mode

    config.disable_default_key_bindings = true
    config.leader = { key = 'z', mods = 'CTRL', timeout_millisecons = 3000 }
    config.keys = mappings.keys or mux_mapping.keys
    config.key_tables = {
      tmux_like = not environment.zellij and mappings.key_tables.tmux_like or nil,
      search_mode = search_mode,
    }
    config.mouse_bindings = {
      {
        event = { Down = { streak = 3, button = 'Left' } },
        action = wezterm.action.SelectTextAtMouseCursor('SemanticZone'),
        mods = 'NONE',
      },
    }
  end,
}
