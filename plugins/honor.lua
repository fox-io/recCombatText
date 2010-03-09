-- $Id: honor.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_honor  then return end

local string_format = string.format
local string_lower = string.lower
local string_find = string.find
local OUTPUT_FORMAT = "|cFFFFFF00+%s honor|r"
local HONOR_PATTERN = "(%d+) honor points"
local c = RecSCT.constants

RecSCT.honor = {
	-- Spam control settings.
	Queue = function(event, e) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		RecSCT:AddText(string_format(OUTPUT_FORMAT, select(3, string_find(string_lower(e), HONOR_PATTERN))), nil, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["honor"] = {
	["CHAT_MSG_COMBAT_HONOR_GAIN"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")