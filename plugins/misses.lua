-- $Id: misses.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_misses then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s%s%s%s%s%s|r"
local MINUS = "- 0"
local c = RecSCT.constants

RecSCT.misses = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet and e.source_guid ~= RecSCT.player and e.source_guid ~= RecSCT.pet then return end
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet then e.outgoing = true end

		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			e.skill_school and RecSCT.school_colors[(e.skill_school > 1 and e.skill_school) or 0] or c.WHITE,
			e.amount and MINUS or c.BLANK,
			e.skill_name and string_format(c.TARGET_FORMAT, RecSCT:ShortenAbilityName(e.skill_name)) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and string_format(c.TARGET_FORMAT, RecSCT:ShortenUnitName(e.dest_name, e.dest_guid)) or not(e.outgoing) and e.source_guid ~= RecSCT.player and e.source_guid ~= UnitGUID("target") and string_format(c.TARGET_FORMAT, RecSCT:ShortenUnitName(e.source_name, e.source_guid)) or c.BLANK,
			e.outgoing and e.source_guid == RecSCT.pet and string_format(c.TARGET_FORMAT, c.PET) or not(e.outgoing) and e.dest_guid == RecSCT.pet and string_format(c.TARGET_FORMAT, c.PET) or c.BLANK,
			e.amount and string_format(c.EXTRA_AMOUNT, e.amount, e.miss_type and RecSCT.miss_printable[e.miss_type] or c.MISS) or string_format(c.MISS_FORMAT, e.miss_type and RecSCT.miss_printable[e.miss_type] or c.MISS),
			e.merge_trailer or c.BLANK),
			false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["misses"] = {
	["SWING_MISSED"] = true,
	["SPELL_MISSED"] = true,
	["SPELL_PERIODIC_MISSED"] = true,
	["RANGE_MISSED"] = true,
	["DAMAGE_SHIELD_MISSED"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")