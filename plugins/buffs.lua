-- $Id: buffs.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_buffs then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s%s %s %s %s|r"
local c = RecSCT.constants

RecSCT.buffs = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player then return end
		if e.aura_type ~= c.BUFF then return end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			RecSCT.school_colors[e.skill_school],
			e.fade and c.MINUS or c.PLUS,
			e.amount > 1 and string_format(c.STACK_FORMAT, e.amount) or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.source_guid ~= RecSCT.player and e.source_guid ~= UnitGUID("target") and e.source_guid ~= RecSCT.pet and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK),
			false, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["buffs"] = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REMOVED"] = true,
	["SPELL_AURA_APPLIED_DOSE"] = true,
	["SPELL_AURA_REMOVED_DOSE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")