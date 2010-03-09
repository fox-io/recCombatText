-- $Id: utils.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
-- Utilities

-- Determines what type the GUID passed in is (used for shortening names)
local guid_types = {[0]="player", [3]="npc", [4]="pet", [5]="vehicle"}
function RecSCT:GetUnitType(guid)
	return guid_types[tonumber(guid:sub(5,5), 16)%8] or nil
end

-- Removes the pvp realm from players, if there is one
function RecSCT:RemovePvPRealm(name, guid)
	if RecSCT:GetUnitType(guid) == "player" then
		return (string.find(name, "-", 1, true)) and string.gsub(name, "(.-)%-.*", "%1 [*]") or name
	end
	return name
end

-- Shortens names of abilities
function RecSCT:ShortenAbilityName(ability)
	if not ability then return "" end
	if RecSCT.shorten_ability_names > 0 then
		if string.len(ability) <= RecSCT.shorten_ability_names then return ability end
		if string.find(ability, " ") then
			ability = string.gsub(ability, "(%a)[%l]*[%s%-]*", "%1")
		else
			ability = string.sub(ability, 1, RecSCT.shorten_ability_names)
		end
	end
	return ability
end

-- Shortens names of units
function RecSCT:ShortenUnitName(name, guid)
	if not name or not guid then return "" end
	local guid_type = RecSCT:GetUnitType(guid)
	if guid_type then
		if guid_type == "player" or guid_type == "pet" then
			if RecSCT.shorten_player_names > 0 and string.len(name) > RecSCT.shorten_player_names then
				return string.sub(name, 1, RecSCT.shorten_player_names)
			else
				return name
			end
		elseif RecSCT.shorten_npc_names > 0 and string.len(name) > RecSCT.shorten_npc_names then
			return string.sub(name, 1, RecSCT.shorten_npc_names)
		else
			return name
		end
	end
	return name
end

-- joins all strings in ... together with delimiter, skipping strings which are ""
function RecSCT:Implode(delimiter, ...)
	local more, i, out
    while (more or not i) do
		i = (i or 0) + 1
        more = select(i, ...)
        out = (out or "")..((more and more ~= "") and ((i>1 and delimiter or "")..more) or "")
    end
    return out
end

-- Clears the contents of a table (does not do subtables)
function RecSCT:EraseTable(t)
	for key in next, t do t[key] = nil end
end