--[[
Retro Dota game mode
]]

require("timers")
require("physics")

print("Retro Dota game mode loaded.")

if retro_dota == nil then
	retro_dota = class({})
end

--------------------------------------------------------------------------------
-- PRECACHE
--------------------------------------------------------------------------------
function Precache(context)
	--Precache relevant particle effects.  Custom units with all of Invoker's spells are used to precache because there is an issue with
	--precaching using datadriven blocks when a spell is swapped in for a hero, and most of Invoker's spells are.
	PrecacheUnitByNameSync("npc_dota_invoker_retro_precache_unit_1", context)
	PrecacheUnitByNameSync("npc_dota_invoker_retro_precache_unit_2", context)
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.retro_dota = retro_dota()
    GameRules.retro_dota:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function retro_dota:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)

	-- Register Think
	GameMode:SetContextThink("retro_dota:GameThink", function() return self:GameThink() end, 0.25)
	
	-- Register Game Events
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(retro_dota, 'OnPlayerPickHero'), self)
end


function retro_dota:GameThink()
	return 0.25
end


function retro_dota:OnPlayerPickHero(keys)
	local hero = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
	local playerID = hero:GetPlayerID()
	FireGameEvent( 'send_hero_ent', { player_ID = playerID, _ent = PlayerResource:GetSelectedHeroEntity(playerID):GetEntityIndex() } )
	local level = 25
	for i=1,level-1 do
		hero:HeroLevelUp(false)
	end
end