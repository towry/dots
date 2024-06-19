local wezterm = require("wezterm")

local M = {}

function M.colors(name)
	name = name or "random"
	local colors, _ = wezterm.color.load_terminal_sexy_scheme(wezterm.config_dir .. "/colors/json/" .. name .. ".json")
	return colors
end

return M
