local awful		= require("awful")
local beautiful	= require("beautiful")
local gears		= require("gears")
local wibox		= require("wibox")
local config	= require("core.config")
local utils		= require("core.utils")

local dpi = require("beautiful.xresources").apply_dpi

local M = {}

M.rofi_config = utils.get_theme_dir() .. "/config.rasi"

function init_layout_list(use_default, custom)
	local default = {
		awful.layout.suit.tile,
		awful.layout.suit.floating,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.fair.horizontal,
		awful.layout.suit.spiral,
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		awful.layout.suit.magnifier,
		awful.layout.suit.corner.nw,
		awful.layout.suit.corner.ne,
		awful.layout.suit.corner.sw,
		awful.layout.suit.corner.se,
	}
	if use_default then awful.layout.layouts = default
	else awful.layout.layouts = custom end
end

function M.has_rofi_config()
	return gears.filesystem.file_readable(M.rofi_config)
end

function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

function init_promptbox(s) s.promptbox = awful.widget.prompt() end

function init_taglist(s)

	local function update_icon(self, c3)
		local tagicon = self:get_children_by_id('icon_role')[1]


		if c3.selected then
			tagicon.text = " " .. utils.icons.full_dot .. " "
			self.fg = beautiful.bg_focus
		elseif #c3:clients() == 0 then
			tagicon.text = " " .. utils.icons.empty_dot .. " "
			self.fg = beautiful.lighter_black or beautiful.fg_normal
		else
			tagicon.text = " " .. utils.icons.dot_inside_dot .. " "
			self.fg = beautiful.fg_normal
		end
	end

	local taglist_buttons = gears.table.join(
		awful.button({}, 1, function(t) t:view_only() end),
		awful.button({}, 3, awful.tag.viewtoggle)
	)

	s.taglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		widget_template = {
			{
				{ id = 'icon_role', font = beautiful.widgets_font or beautiful.font, widget = wibox.widget.textbox },
				id = 'margin_role',
				top = dpi(0),
				bottom = dpi(0),
				left = dpi(2),
				right = dpi(2),
				widget = wibox.container.margin
			},
			id = 'background_role',
			widget = wibox.container.background,
			create_callback = function(self, c3, index, objects)
				update_icon(self, c3)
			end,

			update_callback = function(self, c3, index, objects)
				update_icon(self, c3)
			end,
		},
		buttons = taglist_buttons
	}

end


function init_tasklist(s)

	local icon_size		 = 20
	local icon_margin	 = icon_size * 3/20

	local function left_button(c)
		if c ~= client.focus then
			c:emit_signal("request::activate", "tasklist", {raise = true})
		end
	end

	local function right_button() awful.menu.client_list() end

	local tasklist_buttons = gears.table.join(
	awful.button({}, 1, left_button),
	awful.button({}, 3, right_button)
	)

	s.tasklist = awful.widget.tasklist {
		screen	= s,
		filter	= awful.widget.tasklist.filter.currenttags,
		style	= {
			shape = gears.shape.rounded_bar,
		},
		layout = {
			spacing = 5,
			layout  = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					{
						{
							{
								id			 = 'icon_role',
								forced_width = icon_size,
								widget		 = wibox.widget.imagebox,
							},

							widget = wibox.container.place -- Icone centrate
						},
						right  = icon_margin,
						widget = wibox.container.margin -- Margine tra icone e testo
					},
					{
						id     = 'text_role',
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				left   = icon_margin*2, -- Margine tra bordo e icone
				widget = wibox.container.margin
			},
			id     = 'background_role',
			widget = wibox.container.background,
		},

		buttons = tasklist_buttons
	}
end

function init_windowsbuttons(s) end

function init_wibox(s)

	init_promptbox(s)
	init_windowsbuttons(s)
	init_taglist(s)
	init_tasklist(s)

	local volume_widget = require('widgets.volume').w

	local text_clock = wibox.widget.textclock()

	s.wibox	= awful.wibar({
		position = config.wibox_position or "top",
		screen	 = s,
		height	 = config.wibox_height or 30,
	})

	s.shadow_wibox = awful.wibar({
		position = config.wibox_position or "top",
		screen	 = s,
		height	 = 1,
	})

	s.wibox.autohide = config.wibox_autohide
	s.wibox.visible = not s.wibox.autohide
	s.shadow_wibox.visible = s.wibox.autohide

	s.wibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s.taglist,
			s.promptbox,
		},

		s.tasklist,

		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			spacing = 3,
			volume_widget,
			text_clock,
		},
	}

	function s.wibox.toggle_autohide()
		s.wibox.autohide = not s.wibox.autohide
		s.shadow_wibox.visible = s.wibox.autohide
		s.wibox.visible = not s.wibox.autohide
	end

	local function callback(hide)
		if not s.wibox.autohide then return end
		s.wibox.visible = not hide
		s.shadow_wibox.visible = hide
	end

	s.wibox:connect_signal("mouse::leave", function() callback(true) end)
	s.shadow_wibox:connect_signal("mouse::enter", function() callback(false) end)
end

function M.init()
	beautiful.init(utils.get_theme_file())
	init_layout_list(config.use_default_layout_list, config.layout_list)

	-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
	screen.connect_signal("property::geometry", set_wallpaper)
	awful.screen.connect_for_each_screen(function(s)
		set_wallpaper(s)
		awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
		init_wibox(s)
	end)
end

return M
