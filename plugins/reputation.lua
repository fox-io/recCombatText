-- $Id: reputation.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_reputation  then return end

local string_find = string.find
local string_format = string.format
local INCREASE = "increased"
local REPUTATION_INCREASE = "Reputation with (.+) increased by (%d+)\."
local REPUTATION_DECREASE = "Reputation with (.+) decreased by (%d+)\."
local OUTPUT_FORMAT = "|cFF7F7FFF%s%s %s|r"
local c = RecSCT.constants

RecSCT.reputation = {
	-- Spam control settings.
	Queue = function(e) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		local faction, amount
		if string_find(e, INCREASE) then
			faction, amount = select(3, string_find(e, REPUTATION_INCREASE))
			RecSCT:AddText(string_format(OUTPUT_FORMAT, c.PLUS, amount, faction), nil, c.NOTIFICATION)
		else
			faction, amount = select(3, string_find(e, REPUTATION_DECREASE))
			RecSCT:AddText(string_format(OUTPUT_FORMAT, c.MINUS, amount, faction), nil, c.NOTIFICATION)
		end
	end
}

-- Register handled events
RecSCT.event_handlers["reputation"] = {
	["CHAT_MSG_COMBAT_FACTION_CHANGE"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")