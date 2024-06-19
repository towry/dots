local M = {}

local palette = {
	base = "#333333",
	overlay = "#6C6464",
	muted = "#c2bfa5",
	muted_bright = "#cbc9b2",
	text = "#ffffff",
	love = "#ffa0a0",
	gold = "#ffde9b",
	rose = "#ea9a97",
	rose_bright = "#eda9a7",
	pine = "#88D6E7",
	foam = "#75a0ff",
	iris = "#c285c2",
	-- highlight_high = '#56526e',
}

local active_tab = {
	bg_color = palette.base,
	fg_color = palette.text,
}

local inactive_tab = {
	bg_color = palette.overlay,
	fg_color = palette.muted,
}

function M.colors()
	return {
		foreground = palette.text,
		background = palette.base,
		cursor_bg = "#9acd32",
		cursor_border = "#89fb98",
		cursor_fg = palette.text,
		selection_bg = palette.overlay,
		selection_fg = palette.text,

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
			palette.muted_bright,
			palette.love,
			palette.pine,
			palette.gold,
			palette.foam,
			palette.iris,
			palette.rose_bright,
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
