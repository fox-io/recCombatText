-- $Id: environmental.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_environmental then return end

local string_format = string.format
local OUTPUT_FORMAT = "|cFFFF0000- %s %s %s%s%s%s%s%s%s%s"
local c = RecSCT.constants

RecSCT.environmental = {
	-- Spam control settings.
	Queue = function(e) return "spam" end,
	
	-- Our module's handler
	Handler = function(e)
		-- Bail if not an event we care about.
		if e.dest_guid ~= RecSCT.player then return end
		
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
			e.amount,
			e.hazard_type and RecSCT.environment_printable[e.hazard_type] or c.BLANK,
			e.crit and c.CRIT or c.BLANK,
			e.crushing and c.CRUSHING or c.BLANK,
			e.glancing and c.GLANCING or c.BLANK,
			e.absorb_amount or c.BLANK,
			e.overkill_amount,
			e.resist_amount or c.BLANK,
			e.block_amount or c.BLANK,
			e.merge_trailer or c.BLANK),
			e.crit and true or false, c.INCOMING)
	end
}

-- Register handled events
RecSCT.event_handlers["environmental"] = {
	["ENVIRONMENTAL_DAMAGE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")