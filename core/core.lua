-- $Id: core.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
--[[-------------------------------------------------------------------
							   RecSCT
	Some settings have easy access just below this comment block.

	To pipe text in, use this global function:
		RecSCT:AddText(text, crit, scrollarea)
			- text = output text (color it before you send it in, if it
			  needs to be done)
			- crit = any value or nil.  Causes the text to show larger
			  than the other text (by default)
			- scrollarea = "outgoing", "incoming", or "notification" (by default)

TODO:
	*	Need to tableize and recycle event string output parsing?
	*	Don't merge melee with melee-generated effects?
	*	Better (GUID?) check for notification aura event sources.
	*	Allow (more) independent control over scroll area settings.
	*	OnUpdate script(s) need to be removed when there is no animation
		occuring, as it is useless.
	*	Fontstrings need to be stored directly into the tables, rather
		than the current (old) method of being attached to a unique frame.
	*	Lots of other little things which I'm not even going to bother
		listing until I get closer to implementing them! =D
----------------------------------------------------------------------]]

-- To handle events
local event = CreateFrame("Frame")
local last_use = 0

-- Scroll area creation
local function CreateScrollArea(id, height, x_pos, y_pos, textalign)
	-- Make our normal area
	local sa = CreateFrame("Frame", nil, UIParent)
	--[[ Temporary - used to see where the frames are, if needed
	sa:SetBackdrop({ bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeFile = nil, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0} })
	sa:SetBackdropColor(0, 0, 0, 1) --]]
	sa:SetWidth(1)
	sa:SetHeight(height)
	sa:SetPoint("BOTTOM", UIParent, "BOTTOM", x_pos, y_pos)
	sa.textalign = textalign
	RecSCT.scroll_area_frames[id] = sa

	-- Make our crit area
	local sac = CreateFrame("Frame", nil, UIParent)
	sac:SetWidth(1)
	sac:SetHeight(height)
	sac:SetPoint("BOTTOM", UIParent, "BOTTOM", x_pos, y_pos)
	sac.textalign = textalign
	RecSCT.scroll_area_frames[string.format("%scrit", id)] = sac
end

--[[This function pushes older fontstrings up higher if adding a new one
	would cause it to overlap.  This occurs -before- we insert the new
	text into the fontstring table, but after it is created. --]]
local function CollisionCheck(newtext)
	local destination_scroll_area = RecSCT.anim_strings[newtext.scrollarea]
	local current_animations = #destination_scroll_area
	if current_animations > 0 then -- Only if there are already animations running

		-- Scale the per pixel time based on the animation speed.
		local perPixelTime = RecSCT.animation_movement_speed / newtext.animationSpeed
		local curtext = newtext -- start with our new string
		local previoustext, previoustime

		-- cycle backwards through the table of fontstrings since our newest ones have the highest index
		for x = current_animations, 1, -1 do
			previoustext = destination_scroll_area[x]

			if not newtext.crit then
				-- Calculate the elapsed time for the top point of the previous display event.
				-- TODO: Does this need to be changed since we anchor LEFT and not TOPLEFT?
				previoustime = previoustext.totaltime - (previoustext.fontSize + RecSCT.animation_vertical_spacing) * perPixelTime

				--[[If there is a collision, then we set the older fontstring to a higher animation time
					Which 'pushes' it upward to make room for the new one--]]
				if (previoustime <= curtext.totaltime) then
					previoustext.totaltime = curtext.totaltime + (previoustext.fontSize + RecSCT.animation_vertical_spacing) * perPixelTime
				else
					return -- If there was no collision, then we can safely stop checking for more of them
				end
			else
				previoustext.curpos = previoustext.curpos + (previoustext.fontSize + RecSCT.animation_vertical_spacing)
			end

			-- Check the next one against the current one
			curtext = previoustext
		end
	end
end

-- Animate our texts on update
local function Move(self, elapsed)
	local t
	-- Loop through all active fontstrings
	for k,v in pairs(RecSCT.anim_strings) do

		for l,u in pairs(RecSCT.anim_strings[k]) do
			t = RecSCT.anim_strings[k][l]

			if t and t.inuse then
				--increment it's timer until the animation delay is fulfilled
				t.timer = t.timer + elapsed
				if t.timer >= RecSCT.animation_delay then

					--[[we store it's elapsed time separately so we can continue to delay
						its animation (so we're not updating every onupdate, but can still
						tell what its full animation duration is)--]]
					t.totaltime = t.totaltime + t.timer

					--[[If the animation is not complete, then we need to animate it by moving
						its Y coord (in our sample scrollarea) the proper amount.  If it is complete,
						then we hide it and flag it for recycling --]]
					local percentDone = t.totaltime / RecSCT.animation_duration
					if (percentDone <= 1) then
						t.text:ClearAllPoints()
						if not t.crit then
							t.curpos = RecSCT.scrollframe_height * percentDone -- move up
							t.text:SetPoint(RecSCT.scroll_area_frames[t.scrollarea].textalign, RecSCT.scroll_area_frames[t.scrollarea], "BOTTOMLEFT", 0, t.curpos)
						else
							if t.curpos > RecSCT.scrollframe_height/2 then t.totaltime = 99 end
							t.text:SetPoint(RecSCT.scroll_area_frames[t.scrollarea].textalign, RecSCT.scroll_area_frames[t.scrollarea], RecSCT.scroll_area_frames[t.scrollarea].textalign, 0, t.curpos)
						end

						-- Fade in
						if (percentDone <= 0.05) then t.text:SetAlpha(1 * (percentDone / 0.05))
						-- Fade out
						elseif (percentDone >= 0.80) then t.text:SetAlpha(1 * (1 - percentDone) / (1 - 0.80))
						-- Full vis for times inbetween
						else t.text:SetAlpha(1) end
					else
						t.text:Hide()
						t.inuse = false
					end

					t.timer = 0		--reset our animation delay timer
				end
			end

			--[[Now, we loop backwards through the fontstrings to determine which ones
				can be recycled --]]
			for j = #RecSCT.anim_strings[k], 1, -1 do
				t = RecSCT.anim_strings[k][j]
				if not t.inuse then
					table.remove(RecSCT.anim_strings[k], j)
					-- Place the used frame into our recycled cache
					RecSCT.empty_strings[(#RecSCT.empty_strings or 0) + 1] = t.text
					RecSCT:EraseTable(t)
					RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = t
				end
			end
		end
	end
end

local function PlayerEnteringWorld()
	CreateScrollArea("outgoing", RecSCT.scrollframe_height, 280, 365, "LEFT")
	CreateScrollArea("incoming", RecSCT.scrollframe_height, -280, 365, "RIGHT")
	CreateScrollArea("notification", RecSCT.scrollframe_height, 0, 155, "CENTER")
	RecSCT.scroll_area_frames["outgoing"]:SetScript("OnUpdate", Move)

	RecSCT.player = UnitGUID("player")
end

-- Text processing
-- Scroll text creation, global so you can pipe other text into here
function RecSCT:AddText(text, crit, scrollarea)
	local destination_area
	if not crit then
		destination_area = RecSCT.anim_strings[scrollarea]
	else
		destination_area = RecSCT.anim_strings[scrollarea.."crit"]
	end
	local t
	-- If there are too many frames in the animation area, steal one of them first
	if (#destination_area >= RecSCT.animations_per_scrollframe) then
		t = table.remove(destination_area, 1)

	-- If there are frames in the recycle bin, then snatch one of them!
	elseif #RecSCT.empty_tables > 0 then
		t = table.remove(RecSCT.empty_tables, 1)

	-- If we still don't have a frame, then we'll just have to create a brand new one
	else
		t = {}
	end
	if not t.text then
		t.text = table.remove(RecSCT.empty_strings, 1) or RecSCT.event_frame:CreateFontString(nil, "BORDER")
	end

	-- Settings which need to be set/reset on each fontstring after it is created/obtained
	t.fontSize = t.crit and RecSCT.font_size_crit or RecSCT.font_size_normal
	t.crit = crit
	t.text:SetFont(RecSCT.font, t.fontSize, RecSCT.font_flags)
	t.text:SetText(text)
	t.inuse = true
	t.timer = 0
	t.totaltime = 0
	t.curpos = 0
	t.text:ClearAllPoints()
	if t.crit then
		t.text:SetPoint(RecSCT.scroll_area_frames[scrollarea.."crit"].textalign, RecSCT.scroll_area_frames[scrollarea.."crit"], RecSCT.scroll_area_frames[scrollarea.."crit"].textalign, 0, 0)
		t.text:SetDrawLayer("OVERLAY") -- on top of normal texts.
	else
		t.text:SetPoint(RecSCT.scroll_area_frames[scrollarea].textalign, RecSCT.scroll_area_frames[scrollarea], "BOTTOMLEFT", 0, 0)
		t.text:SetDrawLayer("ARTWORK")
	end
	t.text:SetAlpha(0)
	t.text:Show()
	t.animationSpeed = RecSCT.animation_speed
	t.scrollarea = t.crit and scrollarea.."crit" or scrollarea

	-- Make sure that adding this fontstring will not collide with anything!
	CollisionCheck(t)

	-- Add the fontstring into our table which gets looped through during the OnUpdate
	destination_area[#destination_area+1] = t
	last_use = 0
end

function RecSCT:GenerateText(e)
	-- Loop through each of our events to determine if the event we have should
	-- be inserted into that particular scroll area (allows text to show in multiple
	-- scrollareas

	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[e.event] and e.plugin == module then
			RecSCT[module].Handler(e)
		end
	end
	--recycle cur?
	--RecSCT:EraseTable(e)
	--RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = e
end

local function OnEvent(s,e,...)

	-- If the module is looking for an actual event, rather than a combat event, then let's call those handlers
	for module, event_table in pairs(RecSCT.event_handlers) do
		if event_table[e] then
			RecSCT[module].Handler(e, ...)
		end
	end

	-- Combat log event, pass to handler
	if e == "COMBAT_LOG_EVENT_UNFILTERED" then
		RecSCT:HandleCombatEvent(...)
		return

	-- Update our pet's GUID
	elseif e == "UNIT_PET" then
		if select(1, ...) ~= "player" then return end	-- If it's not our pet, then bail
		RecSCT.pet = UnitGUID("pet")	-- Update our pet's GUID.

	-- Setup the scrollframes
	elseif e == "PLAYER_ENTERING_WORLD" then
		PlayerEnteringWorld()
		event:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

-- Spam Processing
local spamProcessTimer = 0
local function GroupSpam(num)
	if not num or num == 0 then return end
	local test_event
	local make_group = false
	-- Don't attempt to merge any more events than were available when the function was called since more events may get added while the merge is taking place.
	for i=1,num do
		test_event = RecSCT.spam_ready[i]
		for _, spam_event in ipairs(RecSCT.spam_grouped) do
			if test_event.plugin == spam_event.plugin then
				if test_event.type == spam_event.type then
					if not test_event.skill_name and not spam_event.skill_name then
						if test_event.dest_name == spam_event.dest_name then make_group = true end
					elseif test_event.skill_name == spam_event.skill_name then
						if test_event.dest_guid ~= spam_event.dest_guid then spam_event.dest_name = "Multiple" end
						make_group = true
					end
				end
			end
			if make_group then
				test_event.event_merged = true
				if test_event.amount then spam_event.amount = (spam_event.amount or 0) + test_event.amount end
				if test_event.overheal_amount then spam_event.overheal_amount = (spam_event.overheal_amount or 0) + test_event.overheal_amount end
				spam_event.num_merged = spam_event.num_merged + 1
				if test_event.crit then spam_event.num_crits = spam_event.num_crits + 1 else spam_event.crit = false end
				break
			end
		end
		if not make_group then
			test_event.num_merged = 0
			if test_event.crit then test_event.num_crits = 1 else test_event.num_crits = 0 end

			RecSCT.spam_grouped[(#RecSCT.spam_grouped or 0)+1] = test_event
		end
		make_group = false
	end
	for _, spam in ipairs(RecSCT.spam_grouped) do
		if (spam.num_merged > 0) then
			local crit_trailer = ""
			if (spam.num_crits > 0) then
				crit_trailer = string.format("%d %s", spam.num_crits, spam.num_crits == 1 and "Crit" or "Crits")
				spam.num_merged = spam.num_merged - spam.num_crits
			end
			if (spam.num_crits <= 0) then
				spam.merge_trailer = string.format("(%d %s)", spam.num_merged + 1, "Hits")
			elseif (spam.num_crits > 0) and ((spam.num_merged + 1) > 0) then
				spam.merge_trailer = string.format("(%d %s, %s)", spam.num_merged + 1, "Hits", crit_trailer)
			else
				spam.merge_trailer = string.format("(%s)", crit_trailer)
			end
		end
	end
	for i=1,num do
		if (RecSCT.spam_ready[1].event_merged) then
			RecSCT:EraseTable(RecSCT.spam_ready[1])
			RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = RecSCT.spam_ready[1]
		end
		table.remove(RecSCT.spam_ready, 1)
	end
end

local function OnEventUpdate(s,e)
	spamProcessTimer = spamProcessTimer + e
	if spamProcessTimer >= RecSCT.spam_processing_time then
		GroupSpam(#RecSCT.spam_ready)
		for i, spam in ipairs(RecSCT.spam_grouped) do
			RecSCT:GenerateText(spam)
			RecSCT.spam_grouped[i] = nil
			RecSCT:EraseTable(spam)
			RecSCT.empty_tables[(#RecSCT.empty_tables or 0)+1] = spam
		end
	spamProcessTimer = 0
	end

	-- Keep footprint down by releasing stored tables and strings after we've been idle for a bit.
	last_use = last_use + e
	if last_use > 30 then
		if #RecSCT.empty_tables and #RecSCT.empty_tables > 0 then
			RecSCT.empty_tables = {}
		end
		if #RecSCT.empty_strings and #RecSCT.empty_strings > 0 then
			RecSCT.empty_strings = {}
		end
		last_use = 0
		collectgarbage("collect")
	end
end
local spamTimer = CreateFrame("Frame")
spamTimer:Show()
spamTimer.elapsed = 0
spamTimer.energizeTimer = 0
local function CheckSpam(s,e)
	spamTimer.elapsed = spamTimer.elapsed + e
	if spamTimer.elapsed > RecSCT.spam_queue_time then
		spamTimer.elapsed = 0
		if #RecSCT.spam_queue > 0 then
			for i,spam in ipairs(RecSCT.spam_queue) do
				RecSCT.spam_queue[i] = nil
				RecSCT.spam_ready[(#RecSCT.spam_ready or 0)+1] = spam
			end
		end
	end
	spamTimer.energizeTimer = spamTimer.energizeTimer + e
	if spamTimer.energizeTimer > RecSCT.energize_queue_time then
		spamTimer.energizeTimer = 0
		if #RecSCT.energize_queue > 0 then
			for i,energize in ipairs(RecSCT.energize_queue) do
				RecSCT.energize_queue[i] = nil
				RecSCT.spam_ready[(#RecSCT.spam_ready or 0)+1] = energize
			end
		end
	end
end
spamTimer:SetScript("OnUpdate", CheckSpam)

-- Event frame stuffs!
RecSCT.event_frame = CreateFrame("Frame")
RecSCT.event_frame:SetScript("OnEvent", OnEvent)

event:SetScript("OnEvent", OnEvent)					-- Handles events which may cause text to be shown.
event:SetScript("OnUpdate", OnEventUpdate)			-- Handles the spam queue
event:Show()										-- TODO: We need to hide it, and enable it only when events need processing.
--event:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
event:RegisterEvent("UNIT_PET")
event:RegisterEvent("PLAYER_ENTERING_WORLD")
