-- $Id: experience.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_experience  then return end

local string_find = string.find
local string_format = string.format
local EXPERIENCE_PATTERN = ".+ gain (%d+) experience"
local OUTPUT_FORMAT ="|cFF7F7FFF+%s XP|r"
local c = RecSCT.constants

RecSCT.experience = {
	-- Spam control settings.
	Queue = function(event, e) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		RecSCT:AddText(string_format(OUTPUT_FORMAT, select(3, string_find(e, EXPERIENCE_PATTERN))), false, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["experience"] = {
	["CHAT_MSG_COMBAT_XP_GAIN"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")