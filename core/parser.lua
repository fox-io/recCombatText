-- $Id: parser.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $

-- need plugins for these:
			-- eventType notes
			--"miss" "power" "interrupt" "aura"
			--"enchant" "dispel" "cast" "extraattacks"

		--["SPELL_DISPEL"] = true,
		--["SPELL_STOLEN"] = true,
		--["SPELL_DISPEL_FAILED"] = true,
		--["SPELL_INTERRUPT"] = true,
		--["SWING_EXTRA_ATTACKS"] = true,
		--["SPELL_INTERRUPT"] = true,
		--["SPELL_RESURRECT"] = true,
		--["ENCHANT_APPLIED"] = true,
		--["ENCHANT_REMOVED"] = true,
		--["SPELL_DRAIN"] = true,
		--["SPELL_LEECH"] = true,
		--["SWING_INSTAKILL"] = true,
		--["RANGE_INSTAKILL"] = true,
		--["SPELL_INSTAKILL"] = true,
		--["SPELL_CAST_START"] = true,
		--["SPELL_CAST_SUCCESS"] = true,
		--["SPELL_SUMMON"] = true,
		--["SPELL_AURA_BROKEN_SPELL"] = true,
		--["SPELL_CREATE"] = true,
		--["SPELL_CAST_FAILED"] = true,
		--["SPELL_PERIODIC_LEECH"] = true,
		--["SPELL_AURA_BROKEN"] = true,
		--["SPELL_AURA_REFRESH"] = true,

function RecSCT:ParseEvent(...)
	local e
	if #RecSCT.empty_tables and #RecSCT.empty_tables > 0 then
		e = table.remove(RecSCT.empty_tables, 1)
	else
		e = {}
	end
	RecSCT:EraseTable(e)

	-- Insert common args
	e.timestamp, e.event, e.source_guid, e.source_name, e.source_flags, e.dest_guid, e.dest_name, e.dest_flags = ...
	-- Process damage events
	if e.event == "SWING_DAMAGE" then
		e.type = "damage"
		e.amount, e.overkill_amount, e.damage_type, e.resist_amount, e.block_amount, e.absorb_amount, e.crit, e.glancing, e.crushing = select(9, ...)
	-- Process environmental events
	elseif e.event == "ENVIRONMENTAL_DAMAGE" then
		e.type = "environmental"
		e.hazard_type, e.amount, e.overkill_amount, e.damage_type, e.resist_amount, e.block_amount, e.absorb_amount, e.crit, e.glancing, e.crushing = select(9, ...)
	elseif string.find(e.event, "DAMAGE$") or e.event == "DAMAGE_SHIELD" or e.event == "DAMAGE_SPLIT" then
		if e.event == "RANGE_DAMAGE" then e.range = true
		elseif e.event == "SPELL_PERIODIC_DAMAGE" then e.dot = true
		elseif e.event == "DAMAGE_SHIELD" then e.damage_shield = true end
		e.type = "damage"
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.overkill_amount, e.damage_type, e.resist_amount, e.block_amount, e.absorb_amount, e.crit, e.glancing, e.crushing = select(9, ...)
	-- Process miss events
	elseif e.event == "SWING_MISSED" then
		e.type = "miss"
		e.miss_type, e.amount = select(9, ...)
	elseif e.event == "SPELL_DISPEL_FAILED" then
		e.type = "miss"; e.miss_type = "RESIST"
		e.skill_id, e.skill_name, e.skill_school, e.extra_skill_id, e.extra_skill_name, e.extra_skill_school = select(9, ...)
	elseif string.find(e.event, "MISSED$") then
		if e.event == "DAMAGE_SHIELD_MISSED" then e.damage_shield = true
		elseif e.event == "RANGE_MISSED" then e.range = true end
		e.type = "miss"
		e.skill_id, e.skill_name, e.skill_school, e.miss_type, e.amount = select(9, ...)
	-- Process healing events
	elseif string.find(e.event, "HEAL$") then
		if e.event == "SPELL_PERIODIC_HEAL" then e.hot = true end
		e.type = "heal"
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.overheal_amount, e.absorb_amount, e.crit = select(9, ...)
	-- Process power events.
	elseif e.event == "SPELL_ENERGIZE" or e.event == "SPELL_PERIODIC_ENERGIZE" then
		e.type = "power"; e.gain = true
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.power_type = select(9, ...)
	elseif e.event == "SPELL_DRAIN" or e.event == "SPELL_LEECH" or e.event == "SPELL_PERIODIC_DRAIN" or e.event == "SPELL_PERIODIC_LEECH" then
		if string.find(e.event, "DRAIN$") then e.drain = true else e.leech = true end
		e.type = "power"
		e.skill_id, e.skill_name, e.skill_school, e.amount, e.power_type, e.extra_amount = select(9, ...)
	-- Process interrupt events.
	elseif e.event == "SPELL_INTERRUPT" then
		e.type = "interrupt"
		e.skill_id, e.skill_name, e.skill_school, e.extra_skill_id, e.extra_skill_name, e.extra_skill_school = select(9, ...)
	-- Process aura events.
	elseif e.event == "SPELL_AURA_APPLIED" or e.event == "SPELL_AURA_APPLIED_DOSE" or e.event == "SPELL_AURA_REMOVED" or e.event == "SPELL_AURA_REMOVED_DOSE" then
		if string.find(e.event, "REMOVED") then e.fade = true end
		e.type = "aura"
		e.skill_id, e.skill_name, e.skill_school, e.aura_type, e.amount = select(9, ...)
		if not string.find(e.event, "DOSE$") then e.amount = 1 end
	elseif string.find(e.event, "^ENCHANT") then
		if e.event == "ENCHANT_REMOVED" then e.fade = true end
		e.type = "enchant"
		e.skill_name, e.item_id, e.item_name = select(9, ...)
	elseif e.event == "SPELL_DISPEL" or e.event == "SPELL_STOLEN" then
		e.type = "dispel"
		e.skill_id, e.skill_name, e.skill_school, e.extra_skill_id, e.extra_skill_name, e.extra_skill_school, e.aura_type = select(9, ...)
	elseif e.event == "PARTY_KILL" then
		e.type = "kill"
	elseif e.event == "SPELL_EXTRA_ATTACKS" then
		e.type = "extraattacks"
		e.skill_id, e.skill_name, e.skill_school, e.amount = select(9, ...)
	end

	-- If the event failed, recycle the table now.
	if e and e.type then
		return e
	else
		RecSCT:EraseTable(e)
		RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = e
		return nil
	end
end

function RecSCT:HandleCombatEvent(...)
	local we_dont_care = true
	local event = select(2, ...)
	local source = select(3, ...)
	local dest = select(6, ...)
	if not RecSCT.pet and UnitGUID("pet") then RecSCT.pet = UnitGUID("pet") end
	if source ~= RecSCT.player and source ~= RecSCT.pet and dest ~= RecSCT.player and dest ~= RecSCT.pet then return end
	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[event] then
			we_dont_care = false
			break
		end
	end
	if we_dont_care then return end

	-- Get event data
	local e = RecSCT:ParseEvent(...)
	if not e then return end

	-- We need to parse our battleground realms, if present, and shorten names if requested
	if e.dest_name and e.dest_guid then e.dest_name = RecSCT:RemovePvPRealm(e.dest_name, e.dest_guid) end
	if e.source_name and e.source_guid then e.source_name = RecSCT:RemovePvPRealm(e.source_name, e.source_guid) end

	-- Queue events for spam if needed.
	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[e.event] then
			local queue_type = RecSCT[module].Queue(e)
			if queue_type then
				local queue_table = string.format("%s_queue", queue_type)
				if not e.queued then
					e.queued = true
					e.plugin = module
					RecSCT[queue_table][(#RecSCT[queue_table] or 0) +1] = e
				else
					-- More than one output? Make a copy.
					local f = table.remove(RecSCT.empty_tables,1) or {}
					RecSCT:EraseTable(f)
					for k,v in pairs(e) do
						f[k] = e[k]
					end
					f.plugin = module
					RecSCT[queue_table][(#RecSCT[queue_table] or 0) +1] = f
				end
			else
				RecSCT:GenerateText(e)
			end
		end
	end
	if e.queued then return end

	-- Recycle table when done.
	RecSCT:EraseTable(e)
	RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = e
end
