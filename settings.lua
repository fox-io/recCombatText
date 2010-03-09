-- $Id: settings.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
-- Plugins (not required for core operation) (Plugin settings are at the end of this file)
RecSCT.enable_combat_notice			= true		-- Will show "+ Combat" or "- Combat" when you enter/exit combat.
RecSCT.enable_loot_items			= false		-- Will show any items looted.
RecSCT.enable_loot_money			= false		-- Will show any cash looted.
RecSCT.enable_experience			= false		-- Will show experience gains.
RecSCT.enable_reputation			= false		-- Will show reputation gains.
RecSCT.enable_honor					= false		-- Will show honor gains.
RecSCT.enable_debuffs				= true		-- Will show debuffs (gain/fade, NOT damage from them).
RecSCT.enable_killing_blow			= false		-- Will show "Killing Blow" notices.
RecSCT.enable_buffs					= true		-- Will show buffs (gain/fade)
RecSCT.enable_damage				= true		-- Will show damage
RecSCT.enable_healing				= true		-- Will show healing
RecSCT.enable_power					= true		-- Will show power gains.
RecSCT.enable_misses				= true		-- Will show misses, as well as full absorbs, full block, etc.
RecSCT.enable_environmental			= true		-- Will show environmental damage (lava, falling etc)

-- Name shortening settings
RecSCT.shorten_player_names			= 4			-- Max number of characters to display. 0:Show full name.
RecSCT.shorten_npc_names			= 8			-- Max number of characters to display. 0:Show full name.
RecSCT.shorten_ability_names		= 8			-- Max number of characters to display. 0:Show full name.
RecSCT.show_outgoing_target			= 0			-- 0:Show no names, 1:Names that are not your target, 2:Show all names
RecSCT.show_incoming_source			= 0			-- 0:Show no names, 1:Names that are not your target, 2:Show all names
RecSCT.show_notification_source		= 0			-- 0:Show no names, 1:Names that are not your target, 2:Show all names

-- Font Settings
RecSCT.font							= recMedia.fontFace.NORMAL
RecSCT.font_flags					= "OUTLINE"	-- Some text can be hard to read without it.
RecSCT.font_size_normal				= 10
RecSCT.font_size_crit				= 30

-- Scrollframe Settings
RecSCT.scrollframe_height			= 200		-- Height of each scrollframe.

-- Animation Settings
RecSCT.animation_duration			= 5			-- Time it takes for an animation to complete. (in seconds)
RecSCT.animations_per_scrollframe	= 10		-- Maximum number of displayed animations in each scrollframe.
RecSCT.animation_vertical_spacing	= 8			-- Minimum spacing between animations.

-- Spam Settings
RecSCT.spam_queue_time				= 0.5		-- Length of time to wait before displaying events in order to catch spammy ones.
RecSCT.energize_queue_time			= 4			-- A slower spam queue allows for -really- spammy events to wait longer for grouping.
RecSCT.energize_spells				= {			-- Spells which should go into the energize queue instead of spam queue.
	["Replenishment"] = true,
	["Judgement of Wisdom"] = true,
	["Glyph of Seal of Blood"] = true,
	["Aspect of the Viper"] = true,
	["Invigoration"] = true,
	["Vampiric Embrace"] = true,
}

--[[ NYI
RecSCT.plugin_settings = {}
if RecSCT.enable_debuffs then
	RecSCT.plugin_settings["debuffs"] = {
		-- Outgoing Debuffs
		["enable_outgoing"]							= true,
		["outgoing_destination_name"]				= 1,
		["outgoing_destination_name_max_length"]	= 8,
		["outgoing_scrollframe"]					= "outgoing",
		-- Incoming Debuffs
		["enable_incoming"]							= true,
		["incoming_source_name"]					= 1,
		["outgoing_source_name_max_length"]			= 8,
		["incoming_scrollframe"]					= "incoming",
	}
end--]]

--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--
-- DO NOT EDIT BELOW THIS WARNING UNLESS YOU KNOW WTF YOU ARE DOING! --
--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--
RecSCT.animation_speed				= 1			-- Modifies animation_duration.  1 = 100%
RecSCT.animation_delay				= 0.015		-- Frequency of animation updates. (in seconds)
RecSCT.animation_movement_speed		= RecSCT.animation_duration / RecSCT.scrollframe_height
RecSCT.spam_processing_time			= 0.3		-- How often un-queued spam is processed.

--[[ NYI Settings
RecSCT.animation_style = "scrollup"
RecSCT.show_overhealing = 0
--]]