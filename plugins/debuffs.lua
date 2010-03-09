-- $Id: debuffs.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_debuffs then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s%s%s%s %s|r"
local c = RecSCT.constants

RecSCT.debuffs = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid == RecSCT.pet then return end	-- If the debuff is going to our pet
		if e.source_guid == RecSCT.pet then return end	-- If the debuff came from our pet
		if e.aura_type ~= c.DEBUFF then return end		-- If it is not a DEbuff
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player then e.outgoing = true end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.skill_school and RecSCT.school_colors[e.skill_school] or c.WHITE,
			e.fade and c.MINUS or c.PLUS,
			e.amount > 1 and string_format(c.STACK_FORMAT, e.amount) or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or not e.outgoing and e.source_guid ~= RecSCT.player and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK),
			false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["debuffs"] = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REMOVED"] = true,
	["SPELL_AURA_APPLIED_DOSE"] = true,
	["SPELL_AURA_REMOVED_DOSE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")