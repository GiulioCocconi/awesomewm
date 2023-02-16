local naughty		= require("naughty")
local awful			= require("awful")
local gears			= require("gears")
local config		= require("core.config")

local M = {}

M.config_path	 = gears.filesystem.get_configuration_dir()
M.widgets_path	 = M.config_path .. "widgets/"
M.themes_path	 = M.config_path .. "themes/"

local debug_file = M.config_path .. "debug"

M.icons = {
	full_dot	   = utf8.char(61713),
	empty_dot	   = utf8.char(61708),
	dot_inside_dot = utf8.char(61842),
	volume_low	   = utf8.char(984447),
	volume_medium  = utf8.char(984448),
	volume_high	   = utf8.char(984446),
	volume_mute	   = utf8.char(984927),
	sleep		   = 'X',
	wifi		   = 'X',

}

function M.debug(msg)
	if gears.filesystem.file_readable(debug_file) then
		naughty.notify({ preset = naughty.config.presets.low,
		title = "Debug!",
		text  = msg })
	end
end

function get_cmd_name(cmd)
	local findme = cmd
	local firstspace = cmd:find(' ')

	if firstspace then
		findme = cmd:sub(0, firstspace - 1)
	end

	return findme
end

function run_once(cmd)
	cmd_name = get_cmd_name(cmd)
	awful.spawn.with_shell(string.format('pgrep -u $USER -x %s > /dev/null || (%s)',
		cmd_name, cmd))
end

function required_commands()
	req_cmds = {}

	for i, c in ipairs(config.autoload) do
		cmd_table = { name = "autoload cmd " .. tostring(i), cmd = c}
		table.insert(req_cmds, cmd_table)
	end

	for k, c in pairs(config.cmds) do
		if c == "default" then M.debug(k .. " set as default") end
		cmd_table = { name = k .. " cmd", cmd = c}
		table.insert(req_cmds, cmd_table)
	end
	return req_cmds
end

function M.is_command_installed(cmd)
	if cmd == "default" then return true end
	local test_cmd = os.execute("command -v " .. get_cmd_name(cmd))
	return test_cmd ~= nil
end

function M.run_menu()
	local menu_cmd = config.cmds.run
	if menu_cmd == "default" or not M.is_command_installed(menu_cmd) then
		require("menubar").show()
		else awful.spawn(menu_cmd) end
end


function M.init()
	local msg = "Awesome started using " .. M.config_path .. "config";
	M.debug(msg)

	for _, c in ipairs(required_commands()) do
		if not M.is_command_installed(c.cmd) then
			local msg = string.format("%s (%s) is required for your config to work, please install it", get_cmd_name(c.cmd), c.name)

			naughty.notify({ preset = naughty.config.presets.critical,
			title	= "Required program is missing!",
			text	= msg })

		end
	end

	for _, cmd in ipairs(config.autoload) do run_once(cmd) end

	client.connect_signal("manage", function (c)
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.

		if awesome.startup
			and not c.size_hints.user_position
			and not c.size_hints.program_position then
			-- Prevent clients from being unreachable after screen count changes.
			awful.placement.no_offscreen(c)
		end
	end)

	client.connect_signal("mouse::enter", function(c)
		c:emit_signal("request::activate", "mouse_enter", {raise = false})
	end)

end

function M.get_theme_file()
	local theme_name = config.theme or "default"
	return M.themes_path .. theme_name .. "/theme.lua"
end

return M
