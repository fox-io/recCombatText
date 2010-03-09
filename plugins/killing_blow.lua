-- $Id: killing_blow.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_killing_blow then return end

local tonum = tonumber
local string_format = string.format
local OUTPUT_FORMAT = "|cFFFF0000 Killing Blow %s %s"
local c = RecSCT.constants

RecSCT.killing_blow = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.source_guid ~= RecSCT.player then return end
		if e.dest_guid == RecSCT.pet then return end
		if tonum(e.dest_guid:sub(5,5), 16)%8 > 3 then return end	-- If we did not kill a player or npc
		
		RecSCT:AddText(string_format(OUTPUT_FORMAT, 
			e.dest_name and RecSCT.MINUS or c.BLANK,
			e.dest_name and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or c.BLANK),
			true, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["killing_blow"] = {
	["PARTY_KILL"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")