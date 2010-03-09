-- $Id: loot_items.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
if not RecSCT.enable_loot_items  then return end

local lootItem					= '^'..LOOT_ITEM_SELF:gsub("%%s", "(.*)")..'$'
local lootCreatedItem			= '^'..LOOT_ITEM_CREATED_SELF:gsub("%%s", ".*")..'$'
local lootMultipleItems			= '^'..LOOT_ITEM_SELF_MULTIPLE:gsub("%%sx%%d", "(.+)x(%%d+)")..'$'
local lootMultipleCreatedItems	= '^'..LOOT_ITEM_CREATED_SELF_MULTIPLE:gsub("%%sx%%d", "(.+)x(%%d+)")..'$'
local OUTPUT_PATTERN = "%s %s %s%s"
local MULTIPLE = "x"
local string_format = string.format
local c = RecSCT.constants

RecSCT.loot_items = {
	-- Spam control settings.
	Queue = function(event) return nil end,
	
	-- Our module's handler
	Handler = function(event, e)
		local item, player, num
		
		-- First we need to check if there are more than one item being looted or created.
		item, num = select(3, e:find(lootMultipleItems))
		if not item then
			item, num = select(3, e:find(lootMultipleCreatedItems))
		end
		
		-- If we didn't find multiple items, then we can safely set num to 1, and just find a single item.
		if not item then
			num = 1
			item = select(3, e:find(lootItem))
		end
		if not item then
			item = select(3, e:find(lootCreatedItem))
		end
		
		if num then num = tonumber(num) end
		
		-- Send the event.
		if item and num then
			RecSCT:AddText(string_format(OUTPUT_PATTERN, c.PLUS, item, num > 1 and MULTIPLE or c.BLANK, num > 1 and num or c.BLANK), nil, c.NOTIFICATION)
		end
	end
}

-- Register handled events
RecSCT.event_handlers["loot_items"] = {
	["CHAT_MSG_LOOT"] = true,
}
-- Ensure the event frame is set up to get our events.
RecSCT.event_frame:RegisterEvent("CHAT_MSG_LOOT")