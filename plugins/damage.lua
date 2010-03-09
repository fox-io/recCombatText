-- $Id: damage.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_damage then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFF%s- %s %s %s %s%s%s%s%s%s%s%s%s|r"
local c = RecSCT.constants

RecSCT.damage = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet and e.source_guid ~= RecSCT.player and e.source_guid ~= RecSCT.pet then return end
		
		-- Flag for which frame to output to.
		if e.dest_guid ~= RecSCT.player and e.dest_guid ~= RecSCT.pet then e.outgoing = true end
		
		if e.overkill_amount and e.overkill_amount > 0 then
			e.amount = e.amount - e.overkill_amount
			e.overkill_amount = string_format(c.EXTRA_AMOUNT, e.overkill_amount, c.OVERKILL)
		else
			e.overkill_amount = c.BLANK
		end
		if e.resist_amount then e.resist_amount = string_format(c.EXTRA_AMOUNT, e.resist_amount, c.RESISTED) end
		if e.absorb_amount then e.absorb_amount = string_format(c.EXTRA_AMOUNT, e.absorb_amount, c.ABSORBED) end
		if e.block_amount then e.block_amount = string_format(c.EXTRA_AMOUNT, e.block_amount, c.BLOCKED) end
		
		-- Output the text.
		RecSCT:AddText(string_format(OUTPUT_FORMAT,
			(e.event == "SWING_DAMAGE" or e.event == "RANGE_DAMAGE") and RecSCT.school_colors[e.damage_type <= 1 and 0] or e.skill_school and RecSCT.school_colors[e.skill_school] or c.WHITE,
			e.amount or c.BLANK,
			e.skill_name and RecSCT:ShortenAbilityName(e.skill_name) or c.BLANK,
			e.outgoing and e.dest_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.dest_name, e.dest_guid) or not(e.outgoing) and e.source_guid ~= RecSCT.player and e.source_guid ~= UnitGUID("target") and RecSCT:ShortenUnitName(e.source_name, e.source_guid) or c.BLANK,
			e.outgoing and e.source_guid == RecSCT.pet and c.PET or not(e.outgoing) and e.dest_guid == RecSCT.pet and c.PET or c.BLANK,
			e.dot and c.DOT or c.BLANK,
			e.crit and c.CRIT or c.BLANK,
			e.crushing and c.CRUSHING or c.BLANK,
			e.glancing and c.GLANCING or c.BLANK,
			e.absorb_amount or c.BLANK,
			e.overkill_amount or c.BLANK,
			e.resist_amount or c.BLANK,
			e.block_amount or c.BLANK,
			e.merge_trailer or c.BLANK),
			e.crit and true or false, e.outgoing and c.OUTGOING or c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["damage"] = {
	["SWING_DAMAGE"] = true,
	["RANGE_DAMAGE"] = true,
	["SPELL_DAMAGE"] = true,
	["SPELL_PERIODIC_DAMAGE"] = true,
	["DAMAGE_SHIELD"] = true,
	["DAMAGE_SPLIT"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")