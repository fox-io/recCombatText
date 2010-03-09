-- $Id: healing.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_healing then return end

local string_format = string.format
local OVERHEAL_FORMAT = "(%s overheal)"
local OUTPUT_FORMAT = "|cFF00FF00+%s %s %s %s%s%s%s"
local c = RecSCT.constants

RecSCT.healing = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player and e.source_guid ~= RecSCT.player then return end
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player then e.outgoing = true end
		
		if not(e.outgoing) and e.amount and e.overheal_amount and (e.amount - e.overheal_amount == 0) and e.hot then return end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.amount and e.amount - (e.overheal_amount or 0) or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or not e.outgoing and e.source_guid ~= RecSCT.player and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK,
			e.hot and c.HOT or c.BLANK,
			e.crit and c.CRIT or c.BLANK,
			e.overheal_amount and e.overheal_amount > 0 and string_format(OVERHEAL_FORMAT, e.overheal_amount) or c.BLANK,
			e.merge_trailer or c.BLANK),
			e.crit and true or false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["healing"] = {
	["SPELL_HEAL"] = true,
	["SPELL_PERIODIC_HEAL"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")