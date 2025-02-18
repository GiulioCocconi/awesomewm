pcall(require, "luarocks.loader")
local naughty = require("naughty")
local utils = require("core.utils")

require("awful.autofocus")

local core_files = {
   "core.ui",
   "core.keyboard",
}

utils.init()

for _, file in ipairs(core_files) do
   require(file).init()
   utils.debug("Required " .. file)
end

require("core.set_rules")
utils.debug("Rules setted!")

if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
		    title	= "Oops, there were errors during startup!",
		    text	= awesome.startup_errors })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
			     -- Make sure we don't go into an endless error loop
			     if in_error then return end
			     in_error = true

			     naughty.notify({ preset = naughty.config.presets.critical,
					      title = "Oops, an error happened!",
					      text = tostring(err) })
			     in_error = false
   end)
end

