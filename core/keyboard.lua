local gears			= require("gears")
local awful			= require("awful")
local menubar		= require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local utils			= require("core.utils")
local ui			= require("core.ui")
local cmds			= require("core.config").cmds
local modkey		= require("core.config").modkey
local volume		= require("widgets.volume")
local M = {}

M.globalkeys = gears.table.join(
	awful.key({modkey}, "s", hotkeys_popup.show_help, {description="show help"}),

	awful.key({modkey}, "j", function() awful.client.focus.byidx(1) end,
		{description="focus next client"}),
	awful.key({modkey}, "k", function() awful.client.focus.byidx(-1) end,
		{description="focus prev client"}),

	awful.key({modkey, "Shift"}, "j", function() awful.client.swap.byidx(1) end,
		{description="swap with next client"}),
	awful.key({modkey, "Shift"}, "k", function() awful.client.swap.byidx(-1) end,
		{description="swap with prev client"}),

	awful.key({modkey}, "Return", function() awful.spawn(cmds.terminal) end,
		{description = "open a terminal"}),
	awful.key({modkey, "Shift"}, "s", function() awful.spawn(cmds.screenshot) end,
		{description = "take a screenshot"}),
	awful.key({modkey}, "w", function() awful.spawn(cmds.browser) end,
		{description = "open a browser"}),
	awful.key({modkey}, "p", utils.run_menu, {description = "show the run menu"}),
	awful.key({modkey}, "c", function() awful.spawn(cmds.calc) end,
		{description = "show the calculator menu"}),

	awful.key({modkey, "Control"}, "r", awesome.restart, {description = "Restart Awesome"}),

	awful.key({modkey}, "l", function() awful.tag.incmwfact(0.05) end,
		{description = "increase master width"}),
	awful.key({modkey}, "h", function() awful.tag.incmwfact(-0.05) end,
		{description = "decrease master width"}),

	awful.key({modkey}, "a", awful.screen.focused().wibox.toggle_autohide,
		{description = "toggle wibox"}),

	awful.key({modkey}, "F11", volume.increase, {description = "increase the volume"}),
	awful.key({modkey}, "F10", volume.decrease, {description = "decrease the volume"}),
	awful.key({modkey}, "F12", volume.mute,		{description = "toggle volume mute" })


)

M.clientkeys = gears.table.join(
	awful.key({modkey}, "f",
		function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{description = "toggle fullscreen"}),

	awful.key({modkey, "Shift"}, "c", function(c) c:kill() end, {description = "close client"}),
	awful.key({modkey, "Shift"}, "Return", function(c) c:swap(awful.client.getmaster()) end,
		{description = "swap with master"}),
	awful.key({modkey}, "n", function(c) c.minimized = true end, {description = "minimize client"}),
	awful.key({modkey}, "m",
		function(c)
			c.maximized = not c.maximized
			c: raise()
		end,
		{description = "toggle maximized"})
)

function M.init()
	if ui.has_rofi_config() then
		for key, cmd in pairs(cmds) do
			local cmd_name = utils.get_cmd_name(cmd)
			if cmd_name == "rofi" then
				cmds[key] = cmd .. " -config " .. ui.rofi_config
				utils.debug("Using " .. cmd)
			end
		end
	else
		utils.debug("This theme has got no rofi config!")
	end

	for i = 1, 9 do
		M.globalkeys = gears.table.join(M.globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end
	root.keys(M.globalkeys)
end

return M
