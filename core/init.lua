-- $Id: init.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
--Initialization Steps

-- Make our addons namespace.
_G["RecSCT"] = {}
RecSCT.player = false
RecSCT.pet = false

RecSCT.spam_grouped = {}	-- Stores spam which has been processed into groups.
RecSCT.spam_ready = {}		-- Stores spam which has left the queue.
RecSCT.spam_queue = {}		-- Stores spam which has been queued.
RecSCT.energize_queue = {}	-- Stores energize spam which has been queued.

RecSCT.empty_strings = {}	-- Recycled strings
RecSCT.empty_tables = {}	-- Recycled tables

RecSCT.strings_empty = {}	-- Stores recycled animation strings.

RecSCT.school_colors = {
	[0] = "FFFFFF",
	[1] = "FFFF00",
	[2] = "FFE57F",
	[4] = "FF7F00",
	[8] = "4CFF4C",
	[16] = "7FFFFF",
	[32] = "7F7FFF",
	[64] = "FF7FFF",
}

RecSCT.power_colors = {
	[-2]	= "00FF00",	-- Health
	[0]		= "0000FF",	-- Mana
	[1]		= "FF0000",	-- Rage
	[2]		= "643219",	-- Focus
	[3]		= "FFFF00",	-- Energy
	[4]		= "00FFFF",	-- Happiness
	[5]		= "323232",	-- Runes
	[6]		= "005264",	-- Runic Power
}

RecSCT.miss_printable = {
	["MISS"]	= "Missed",
	["DODGE"]	= "Dodged",
	["BLOCK"]	= "Blocked",
	["DEFLECT"]	= "Deflected",
	["EVADE"]	= "Evaded",
	["IMMUNE"]	= "Immune",
	["PARRY"]	= "Parried",
	["REFLECT"]	= "Reflected",
	["RESIST"]	= "Resisted",
	["ABSORB"]	= "Absorbed"
}

RecSCT.environment_printable = {
	["DROWNING"]	= "Drowning",
	["FALLING"]		= "Falling",
	["FATIGUE"]		= "Fatigued",
	["FIRE"]		= "Fire",
	["LAVA"]		= "Lava",
	["SLIME" ]		= "Slime"
}

RecSCT.anim_strings = {
	["outgoing"] = {},
	["outgoingcrit"] = {},
	["incoming"] = {},
	["incomingcrit"] = {},
	["notification"] = {},
	["notificationcrit"] = {}
}

RecSCT.scroll_area_frames = {
	["outgoing"] = true,
	["outgoingcrit"] = true,
	["incoming"] = true,
	["incomingcrit"] = true,
	["notification"] = true,
	["notificationcrit"] = true
}

RecSCT.event_handlers = {
}

-- Constants
RecSCT.constants = {
	BLANK = "",
	MINUS = "-",
	PLUS = "+",
	WHITE = "FFFFFF",
	OUTGOING = "outgoing",
	INCOMING = "incoming",
	NOTIFICATION = "notification",
	DEBUFF = "DEBUFF",
	STACK_FORMAT = "%sx ",
	MISS = "Miss",
	PET = "(Pet)",
	TARGET_FORMAT = " %s",
	MISS_FORMAT = " (%s)",
	CRIT = "(Crit)",
	CRUSHING = "(Crushing)",
	GLANCING = "(Glancing)",
	EXTRA_AMOUNT = "(%s %s)",
	OVERKILL = "overkill",
	RESISTED = "resisted",
	BLOCKED = "blocked",
	ABSORBED = "absorbed",
	HOT = "(HoT)",
	BUFF = "BUFF",
	DOT = "(DoT)",
}