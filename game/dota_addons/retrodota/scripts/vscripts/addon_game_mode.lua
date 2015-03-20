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
	
	--Precache creep-related models.
	PrecacheResource("model", "models/heroes/furion/treant.vmdl", context)
	PrecacheResource("model", "models/items/furion/treant/furion_treant_nelum_red/furion_treant_nelum_red.vmdl", context)
	PrecacheResource("model", "models/heroes/undying/undying_minion.vmdl", context)
	PrecacheResource("model", "models/items/undying/idol_of_ruination/ruin_wight_minion.vmdl", context)
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
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(retro_dota, 'OnNpcSpawned'), self)
	--ListenToGameEvent('last_hit', Dynamic_Wrap(retro_dota, 'OnLastHit'), self)
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


--Remove movement speed spawn modifiers on lane creeps, and alter the creeps' models.
function retro_dota:OnNpcSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)
	
	if IsValidEntity(npc) then
		local npc_name = npc:GetUnitName()
		
		-- Creep custom models are changed directly through the npc_units.txt override file
		--[[if npc_name == "npc_dota_creep_goodguys_melee" then
			npc:SetOriginalModel("models/heroes/furion/treant.vmdl")
			npc:SetModel("models/heroes/furion/treant.vmdl")
		elseif npc_name == "npc_dota_creep_goodguys_ranged" then
			npc:SetOriginalModel("models/items/furion/treant/furion_treant_nelum_red/furion_treant_nelum_red.vmdl")
			npc:SetModel("models/items/furion/treant/furion_treant_nelum_red/furion_treant_nelum_red.vmdl")
		elseif npc_name == "npc_dota_creep_badguys_melee" then
			npc:SetOriginalModel("models/heroes/undying/undying_minion.vmdl")
			npc:SetModel("models/heroes/undying/undying_minion.vmdl")
		elseif npc_name == "npc_dota_creep_badguys_ranged" then
			npc:SetOriginalModel("models/items/undying/idol_of_ruination/ruin_wight_minion.vmdl")
			npc:SetModel("models/items/undying/idol_of_ruination/ruin_wight_minion.vmdl")
		end]]
	end
	
	--Remove movement speed modifiers that are automatically applied to lane creeps spawned from the npc_dota_spawner entities.
	--We have to wait around 1 second for unknown reasons, or the modifiers won't be removed.
	Timers:CreateTimer({
		endTime = 1,
		callback = function()
			if IsValidEntity(npc) then
				if npc:HasModifier("modifier_creep_haste") or npc:HasModifier("modifier_creep_slow")then
					npc:RemoveModifierByName("modifier_creep_haste")
					npc:RemoveModifierByName("modifier_creep_slow")
				end
			end
		end
	})
end


--Remove ancient invulnerability if both towers have been destroyed.
--[[function retro_dota:OnLastHit(keys)
	if keys.TowerKill == 1 then
		local killed_tower = EntIndexToHScript(keys.EntKilled)
		if killed_tower:IsTower() then
			local tower_team = killed_tower:GetTeam()
			if tower_team == DOTA_TEAM_GOODGUYS then
				--
			elseif tower_team == DOTA_TEAM_BADGUYS then
				local dire_tower_still_alive = false
				
				local towers = Entities:FindAllByClassname("npc_dota_tower")
				for i, individual_tower in ipairs(towers) do
					if individual_tower:GetTeam() == DOTA_TEAM_BADGUYS and individual_tower:IsAlive() then
						dire_tower_still_alive = true
						--print("tower still alive")
					end
				end
				
				if not dire_tower_still_alive then  --Remove invulnerability from the ancient if the towers have been destroyed.
					--local dire_ancient = Entities:FindAllByClassname("npc_dota_badguys_fort")
					local dire_ancient = Entities:FindAllByName("npc_dire_fort")  --This does not appear to return anything.
					for i, individual_ancient in ipairs(dire_ancient) do
						individual_ancient:SetInvulnCount(0)
						print("ancient invulnerability lost")
					end
				end
			end
		end
	end
end]]