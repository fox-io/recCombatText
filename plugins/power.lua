-- $Id: power.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_power then return end

local OUTPUT_FORMAT = "|cFF%s+%s %s %s %s|r"
local string_format = string.format
local c = RecSCT.constants

RecSCT.power = {
	-- Spam control settings.
	Queue = function(e) return "energize" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player then return end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.power_type and RecSCT.power_colors[e.power_type] or c.WHITE,
			e.amount and e.amount > 0 and e.amount or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.source_guid ~= RecSCT.player and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK,
			e.merge_trailer or c.BLANK),
			false, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["power"] = {
	["SPELL_ENERGIZE"] = true,
	["SPELL_PERIODIC_ENERGIZE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
