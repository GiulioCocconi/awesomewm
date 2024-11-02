local awful = require("awful")
local M = {}

M.cmds = {
	terminal   = os.getenv("TERMINAL") or st,
	editor	   = os.getenv("EDITOR") or "nano",
	screenshot = "flameshot gui",
	browser	   = "chromium",
	calc	   = "rofi -show calc -modi calc -no-show-match -no-sort",
	run        = "rofi -show run",
}

M.autoload = {
	"picom --backend glx",
	"udiskie",
}

M.modkey = "Mod4"

M.theme	 = "cogi-extreme"

M.wibox_autohide = false
M.wibox_position = "top"
M.wibox_height	 = 30

M.use_default_layout_list = false
M.layout_list = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
}

return M
