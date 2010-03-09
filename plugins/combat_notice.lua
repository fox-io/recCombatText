-- $Id: combat_notice.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_combat_notice  then return end

local string_format = string.format
local ENTERED_COMBAT = "PLAYER_REGEN_DISABLED"
local LEFT_COMBAT = "PLAYER_REGEN_ENABLED"
local OUTPUT_PATTERN = "%s Combat"
local c = RecSCT.constants

RecSCT.combat_notice = {
	-- Spam control settings.
	Queue = function(event) return nil end,
	
	-- Our module's handler
	Handler = function(event)
		if event == ENTERED_COMBAT then
			RecSCT:AddText(string_format(OUTPUT_PATTERN, c.PLUS), nil, c.NOTIFICATION)
		else
			RecSCT:AddText(string_format(OUTPUT_PATTERN, c.MINUS), nil, c.NOTIFICATION)
		end
	end
}

-- Register handled events
RecSCT.event_handlers["combat_notice"] = {
	[LEFT_COMBAT] = true,
	[ENTERED_COMBAT] = true
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent(LEFT_COMBAT)
RecSCT.event_frame:RegisterEvent(ENTERED_COMBAT)