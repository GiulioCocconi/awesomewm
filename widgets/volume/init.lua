local beautiful = require("beautiful")
local naughty = require("naughty")
local awful	  = require("awful")
local wibox	  = require("wibox")

local utils	  = require("core.utils")

local script = utils.widgets_path .. "volume/script.sh"

local M = {}

M.w = wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	{
		id = "icon",
		align = "center",
		valign = "center",
		font = beautiful.widgets_font or beautiful.font,
		forced_width = 15,
		widget = wibox.widget.textbox
	},
	{
		id = "textbox",
		align = "center",
		valign = "center",
		forced_width = 35,
		widget = wibox.widget.textbox
	}
}

function M.w.update(status)

	local textbox = M.w:get_children_by_id('textbox')[1]
	local icon = M.w:get_children_by_id('icon')[1]

	local volume = tonumber(status:sub(1, -3))

	if volume == nil then
		utils.debug(utils.icons.volume_mute)
		textbox.text = "M"
		icon.text	 = utils.icons.volume_mute
		return
	end

	textbox.text = status

	if volume == 0 then
		icon.text = utils.icons.volume_low
	elseif volume < 20 then
		icon.text = utils.icons.volume_medium
	else
		icon.text = utils.icons.volume_high
	end

end

local function run(cmd)
	awful.spawn.easy_async_with_shell(script .. " " .. cmd, function(status)
		if M.w.update then M.w.update(status) end
	end)

end

function M.increase() run("+")			  end
function M.decrease() run("-")			  end
function M.mute()     run("m")			  end
function M.set(perc)  run(tostring(perc)) 	  end
function M.init()     run("s")                    end

return M





