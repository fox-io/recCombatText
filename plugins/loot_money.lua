-- $Id: loot_money.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_loot_money  then return end

local gold_pattern = GOLD_AMOUNT:gsub("%%d", "(%%d+)")
local silver_pattern = SILVER_AMOUNT:gsub("%%d", "(%%d+)")
local copper_pattern = COPPER_AMOUNT:gsub("%%d", "(%%d+)")
local GSC_RETURN_PATTERN = "%d|cffffd700%s|r%d|cffc7c7cf%s|r%d|cffeda55f%s|r"
local SC_RETURN_PATTERN = "%d|cffc7c7cf%s|r%d|cffeda55f%s|r"
local C_RETURN_PATTERN = "%d|cffeda55f%s|r"
local OUTPUT_FORMAT = "+ %s"
local string_format = string.format
local tonum = tonumber
local c = RecSCT.constants

local MoneyToCopper = function(s)
	return (tonum(s:match(gold_pattern)) or 0)*10000 + (tonum(s:match(silver_pattern)) or 0)*100 + (tonum(s:match(copper_pattern)) or 0)
end
local PrettyCopper = function(c, long)
	if c > 10000 then
		return string_format(GSC_RETURN_PATTERN, c/10000, long and GOLD or 'g', (c/100)%100, long and SILVER or 's', c%100, long and COPPER or 'c')
	elseif c > 100 then
		return string_format(SC_RETURN_PATTERN, (c/100)%100, long and SILVER or 's', c%100, long and COPPER or 'c')
	else
		return string_format(C_RETURN_PATTERN, c%100, long and COPPER or 'c')
	end
end

RecSCT.loot_money = {
	-- Spam control settings.
	Queue = function(event) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		RecSCT:AddText(string_format(OUTPUT_FORMAT, PrettyCopper(MoneyToCopper(e))), nil, c.NOTIFICATION)
	end
}

-- Register handled events
RecSCT.event_handlers["loot_money"] = {
	["CHAT_MSG_MONEY"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_MONEY")