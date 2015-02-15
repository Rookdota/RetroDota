--[[
27 Spell Invoker Wars game mode
]]

require("timers")
require("physics")

print("27 Spell Invoker Wars game mode loaded.")

if twenty_seven_spell_invoker_wars == nil then
	twenty_seven_spell_invoker_wars = class({})
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.twenty_seven_spell_invoker_wars = twenty_seven_spell_invoker_wars()
    GameRules.twenty_seven_spell_invoker_wars:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function twenty_seven_spell_invoker_wars:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true)

	-- Register Think
	GameMode:SetContextThink("twenty_seven_spell_invoker_wars:GameThink", function() return self:GameThink() end, 0.25)

	
	-- Register Game Events
	
end

--------------------------------------------------------------------------------
function twenty_seven_spell_invoker_wars:GameThink()
	return 0.25
end

--------------------------------------------------------------------------------
-- PRECACHE
--------------------------------------------------------------------------------
function Precache( context)
	
end