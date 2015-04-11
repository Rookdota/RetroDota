--[[
Retro Dota game mode
]]

print("Retro Dota game mode loaded.")

RETRODOTA_VERSION = "1.0.0"

END_GAME_ON_KILLS = false
KILLS_TO_END_GAME_FOR_TEAM = 0

-- Dota Hero XP Table
XP_BOUNTY_PER_LEVEL_TABLE = {}
XP_BOUNTY_PER_LEVEL_TABLE[1] = 100
for i=2, 5 do
	XP_BOUNTY_PER_LEVEL_TABLE[i] = XP_BOUNTY_PER_LEVEL_TABLE[i-1] + (i-1)*20
end
for i=6, 25 do
	XP_BOUNTY_PER_LEVEL_TABLE[i] = XP_BOUNTY_PER_LEVEL_TABLE[i-1] + 100
end

XP_PER_LEVEL_TABLE = {
	0,
	200,
	400,
	900,
	1400,
	2000,
	2600,
	3200,
	4400,
	5400,
	6000,
	8200,
	9000,
	10400,
	11900,
	13500,
	15200,
	17000,
	18900,
	20900,
	23000,
	25200,
	27500,
	29900,
	32400
}

if RetroDota == nil then
	RetroDota = class({})
end


function RetroDota:InitGameMode()
	RetroDota = self
	print('[RETRODOTA] Starting to load retrodota RetroDota...')

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)

	-- Register Think
	--RetroDota:SetContextThink("RetroDota:GameThink", function() return self:GameThink() end, 0.25)
	
	-- Register Game Events
	ListenToGameEvent('player_connect', Dynamic_Wrap(RetroDota, 'PlayerConnect'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(RetroDota, 'OnConnectFull'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(RetroDota, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(RetroDota, 'OnPlayerPickHero'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(RetroDota, 'OnNPCSpawned'), self)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(RetroDota, 'OnEntityKilled'), self)
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(RetroDota, 'OnPlayerLevelUp'), self)
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(RetroDota, 'OnAbilityUsed'), self)
	--ListenToGameEvent('dota_glyph_used', Dynamic_Wrap(RetroDota, 'OnGlyphUsed'), self) --Doesn't trigger.
	
	-- Vote Data
	GameRules.finished_voting = false
	GameRules.player_count = 0
	GameRules.players_voted = 0
	GameRules.players_skipped_vote = 0
	GameRules.win_condition_votes = {}
	GameRules.level_votes = {}
	GameRules.gold_votes = {}
	GameRules.invoke_cd_votes = {}
	GameRules.invoke_slots_votes = {}
	GameRules.mana_cost_reduction_votes = {}
	GameRules.mirror_votes = {}
	GameRules.fast_respawn_votes = {}
	GameRules.gold_multiplier_votes = {}
	GameRules.xp_multiplier_votes = {}

	GameRules.vote_options = LoadKeyValues("scripts/npc/kv/vote_options.txt")
	
	--Initialize the voting options with their default settings.
	GameRules.win_condition = GameRules.vote_options.kills_to_win["7"]
	GameRules.starting_level = GameRules.vote_options.starting_level["2"]
	GameRules.starting_gold = GameRules.vote_options.starting_gold["1"]
	GameRules.invoke_cd = GameRules.vote_options.invoke_cd["2"]
	GameRules.mana_cost_reduction = GameRules.vote_options.mana_cost_reduction["2"]
	GameRules.invoke_slots = "2"
	GameRules.mirror_match = "0"
	GameRules.fast_respawn = "1"
	GameRules.gold_multiplier = "1"
	GameRules.xp_multiplier = "1"
	
	--Set the hull radius of the ancients.  This is especially important for the Dire ancient, since it allows melee creeps to be able to attack it.
	local ancients = Entities:FindAllByClassname('npc_dota_fort')
	for k,v in pairs(ancients) do
		v:SetHullRadius(190)
	end
	
	--Due to issues with lag, we will create lots of fireballs for use with the Firestorm spell.  These fireballs will hide out in a corner of the map
	--until they are needed, and will return there when they are done.
	firestorm_fireballs = {}
	for i=0, 79, 1 do
		local fireball_unit = CreateUnitByName("npc_dota_invoker_retro_firestorm_unit", Vector(7000, 7000, 128), false, nil, nil, DOTA_TEAM_GOODGUYS)
		local fireball_unit_ability = fireball_unit:FindAbilityByName("invoker_retro_firestorm_fireball")
		if fireball_unit_ability ~= nil then
			fireball_unit_ability:SetLevel(1)
		end
		fireball_unit_ability:ApplyDataDrivenModifier(fireball_unit, fireball_unit, "dummy_modifier_no_health_bar", nil)
		
		firestorm_fireballs[i] = fireball_unit
	end
end


function RetroDota:GameThink()
	return 0.25
end


-- This function is called 1 to 2 times as the player connects initially but before they have completely connected
function RetroDota:PlayerConnect(keys)
	print('[RETRODOTA] PlayerConnect')

end


-- This function is called once when the player fully connects and becomes "Ready" during Loading
function RetroDota:OnConnectFull(keys)
	print ('[RETRODOTA] OnConnectFull')
	RetroDota:CaptureGameMode()

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()
	
	if connected_playerIDs == nil then
		connected_playerIDs = {}
	end
	
	--If the player has not connected before (e.g. so long as they have not disconnected and come back).
	--Without this check, a player disconnecting and returning can trick the code into thinking there are 11 players when in fact, there are only 10.
	if connected_playerIDs[playerID] == nil then
		connected_playerIDs[playerID] = true
		GameRules.player_count = GameRules.player_count + 1
	end
end


-- This function is called as the first player loads and sets up the GameMode parameters
function RetroDota:CaptureGameMode()
	if mode == nil then
		-- Set GameMode parameters
		mode = GameRules:GetGameModeEntity()

		-- Custom Settings
		GameRules:SetUseCustomHeroXPValues(true)
		GameRules:SetUseBaseGoldBountyOnHeroes(false)
		GameRules:SetSameHeroSelectionEnabled(true)
		GameRules:SetPreGameTime(60)
		--[[mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
		mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
		mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
		mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
		mode:SetBuybackEnabled( BUYBACK_ENABLED )
		mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
		mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
		mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
		mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
		--mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
		mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )
		mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
		mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
		mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )]]

		RetroDota:OnFirstPlayerLoaded()
	end
end


-- This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
function RetroDota:OnFirstPlayerLoaded()
	print("[BAREBONES] First Player has loaded")
end


-- The overall game state has changed
function RetroDota:OnGameRulesStateChange(keys)
	print("[RETRODOTA] GameRules State Changed")

	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_INIT then
		Timers:RemoveTimer("alljointimer")
	elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		
		local et = 6
		if self.bSeenWaitForPlayers then
			et = .01
		end

		Timers:CreateTimer("alljointimer", {
			useGameTime = true,
			endTime = et,
			callback = function()
				
				if PlayerResource:HaveAllPlayersJoined() then

					RetroDota:OnAllPlayersLoaded()
					return
				end
				return 1
			end})
	elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

		if not GameRules.finished_voting then

			-- Finish Voting in case there's still some panels open
			FireGameEvent( 'hide_vote_panel', {} )

			RetroDota:OnEveryoneVoted()
		end
	end
end


function RetroDota:OnAllPlayersLoaded()
	print("[RETRODOTA] All Players have loaded into the game")

	-- Show Vote Panel
	FireGameEvent( 'show_vote_panel', {} )

	GameRules:SendCustomMessage("<font color='#FF9933'>Welcome to Retro Dota!</font>  <font color='##FFCC33'>Vote on the settings you would like to play with.</font>", 0, 0)
	GameRules:SendCustomMessage("<font color='#FF9933'>News:</font> <font color='##FFCC33'>Version 1.0.1 released, which improves stability.</font>", 0, 0)
	GameRules:SendCustomMessage("<font color='##FFCC33'>Please also note that lag issues can arise when a player uses an Invoker cosmetic item that was released within the past few months, since the Source 2 branch of Dota 2 has not yet been updated with the newest cosmetics.</font>", 0, 0)
	
	
	local message30shown = false
	local message10shown = false
	Timers:CreateTimer(function()
		local time = GameRules:GetDOTATime(false,true)
		--print("Time false true "..time)
		if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME and not GameRules.finished_voting then
			if math.abs(time) < 30 and not message30shown then
				GameRules:SendCustomMessage("<font color='#FF9933'>30 seconds left to vote.", 0, 0)
				message30shown = true
			elseif math.abs(time) < 10 and not message10shown then
				GameRules:SendCustomMessage("<font color='#EB4B4B'>10 seconds left to vote.", 0, 0)
				return
			end
		elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			return
		end
		return 1
	end)

end

function RetroDota:OnPlayerPickHero(keys)
	local hero = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
	local playerID = hero:GetPlayerID()
	
	FireGameEvent( 'send_hero_ent', { player_ID = playerID, _ent = PlayerResource:GetSelectedHeroEntity(playerID):GetEntityIndex() } )
	FireGameEvent( 'show_spell_list_button', { player_ID = playerID } )

	-- Check the level of this hero, add the bonus levels if needed
	if GameRules.finished_voting and (hero:GetLevel() < GameRules.starting_level) then
		hero:AddExperience(XP_PER_LEVEL_TABLE[GameRules.starting_level], false, false)
		print("Added "..XP_PER_LEVEL_TABLE[GameRules.starting_level] .. " XP.")
	end
	
	--Set the player's gold.  This will override the gold bonus if the player chose to random (which we want to do).
	PlayerResource:SetGold(playerID, 0, false)
	PlayerResource:SetGold(playerID, 0, true)
	PlayerResource:ModifyGold(playerID, GameRules.starting_gold, false, 0)

	-- Set Custom XP Value when a hero is picked after the multiplier was defined
	if GameRules.xp_multiplier then
		local XP_value = XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()] * GameRules.xp_multiplier
		print("Set unit's EXP bounty to " .. XP_value)
		hero:SetCustomDeathXP(XP_value)
	end
	
	--Swap the version of Invoke for the one with the correct cooldown.
	if GameRules.invoke_cd ~= "6" then  --The active version of Invoke defaults to a 6-second cooldown, so don't change anything if the default cooldown was selected.
		if hero:GetName() == "npc_dota_hero_Invoker" then
			local old_invoke_ability = hero:FindAbilityByName("invoker_retro_invoke_6_second_cooldown")
			local old_invoke_ability_level = old_invoke_ability:GetLevel()
			local old_invoke_ability_cooldown = old_invoke_ability:GetCooldownTimeRemaining()
		
			hero:RemoveAbility("invoker_retro_invoke_6_second_cooldown")
			local new_invoke_ability_name = "invoker_retro_invoke_" .. GameRules.invoke_cd .. "_second_cooldown"
			hero:AddAbility(new_invoke_ability_name)
			
			local new_invoke_ability = hero:FindAbilityByName(new_invoke_ability_name)
			new_invoke_ability:SetLevel(old_invoke_ability_level)
			new_invoke_ability:StartCooldown(old_invoke_ability_cooldown)
		end
	end
end


-- A player leveled up
function RetroDota:OnPlayerLevelUp(keys)
	local player = EntIndexToHScript(keys.player)
	local hero = player:GetAssignedHero() 
	local level = keys.level
	local XP_value = XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()] * GameRules.xp_multiplier
	print("Set unit's EXP bounty to " .. XP_value)
	hero:SetCustomDeathXP(XP_value)

end


function RetroDota:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)

	-- Apply Gold & XP Multiplier
	if GameRules.xp_multiplier then
		npc:SetDeathXP(npc:GetDeathXP() * tonumber(GameRules.xp_multiplier))
	end
	
	if GameRules.gold_multiplier then
		npc:SetMaximumGoldBounty(npc:GetGoldBounty() * tonumber(GameRules.gold_multiplier))
		npc:SetMinimumGoldBounty(npc:GetGoldBounty() * 1.1 )
	end

	if IsValidEntity(npc) and GameRules:GetDOTATime(false, false) < 500 then  --Lane creeps stop being given movement speed modifiers at 7:30, so don't bother removing them after that point.
		local npc_name = npc:GetUnitName()
		if npc_name == "npc_dota_creep_goodguys_melee" or npc_name == "npc_dota_creep_goodguys_ranged" or npc_name == "npc_dota_goodguys_siege" or 
			npc_name == "npc_dota_creep_badguys_melee" or npc_name == "npc_dota_creep_badguys_ranged" or npc_name == "npc_dota_badguys_siege" then  --If the entity is a lane creep of some kind.
			
			--Remove movement speed modifiers that are automatically applied to lane creeps spawned from the npc_dota_spawner entities when the gametime is early.
			--We usually end up waiting around a second or so before the modifiers are applied, for unknown reasons.
			Timers:CreateTimer({
				endTime = .03,
				callback = function()
					if IsValidEntity(npc) and npc:IsAlive() then
						if npc:HasModifier("modifier_creep_haste") or npc:HasModifier("modifier_creep_slow")then
							npc:RemoveModifierByName("modifier_creep_haste")
							npc:RemoveModifierByName("modifier_creep_slow")
							return
						else
							return .03
						end
					end
				end
			})
		end
	end
end


-- An entity died
function RetroDota:OnEntityKilled( keys )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	if killedUnit ~= nil and killedUnit:IsRealHero() then
		--In version 1.0.0, the Betrayal spell was occasionally erroring out, causing heroes to be stuck on a custom team by themselves.
		--Then, when they attempted to respawn, the game would crash because there was no spawn point for that team.  As a backup,
		--here we make sure a hero is moved back to its original team on death.
		if killedUnit:HasModifier("modifier_invoker_retro_betrayal") then
			killedUnit:RemoveModifierByName("modifier_invoker_retro_betrayal")
		end
		local killed_unit_pid = killedUnit:GetPlayerID()
		if killed_unit_pid ~= nil and PlayerResource:IsValidPlayerID(killed_unit_pid) and PlayerResource:IsValidPlayer(killed_unit_pid) then
			local killed_unit_player = PlayerResource:GetPlayer(killed_unit_pid)
			local killed_unit_current_team = killedUnit:GetTeam()
			if killed_unit_player ~= nil and killed_unit_player.invoker_retro_betrayal_original_team ~= nil and killed_unit_current_team ~= "DOTA_TEAM_GOODGUYS" and killed_unit_current_team ~= "DOTA_TEAM_BADGUYS" then  --If the invoker_retro_betrayal_original_team was not stored, we're in trouble.
				PlayerResource:SetCustomTeamAssignment(killed_unit_pid, killedUnit.invoker_retro_betrayal_original_team)
				killedUnit:SetTeam(killed_unit_player.invoker_retro_betrayal_original_team)
				killedUnit.invoker_retro_betrayal_original_team = nil
			end
		end

		-- Gold Multiplier for hero kills
		if killerEntity ~= nil and killerEntity:IsRealHero() and GameRules.gold_multiplier then
			local bounty = killedUnit:GetGoldBounty() * GameRules.gold_multiplier - killedUnit:GetGoldBounty()
			print(bounty, killedUnit:GetGoldBounty(), GameRules.gold_multiplier, killedUnit:GetGoldBounty())
			if bounty ~= 0 then
				
				-- Additional gold popup needed?
				-- The default dota popup for gold on hero kills still shows up
			    local pfxPath = "particles/msg_fx/msg_gold.vpcf"
			    local pidx = ParticleManager:CreateParticleForPlayer(pfxPath, PATTACH_CUSTOMORIGIN, killedUnit, PlayerResource:GetPlayer( killerEntity:GetPlayerID()) )
			    local digits = #tostring(bounty)+1

			    ParticleManager:SetParticleControl(pidx, 0, killedUnit:GetAbsOrigin())
			    ParticleManager:SetParticleControl(pidx, 1, Vector(0, tonumber(bounty), 0))
			    ParticleManager:SetParticleControl(pidx, 2, Vector(2.0, digits, 0))
			    ParticleManager:SetParticleControl(pidx, 3, Vector(255, 200, 33))

			    print("Granted "..bounty.." extra bounty")
			end
		end

		
		--If the win condition is kills, see if a team has won.
		if END_GAME_ON_KILLS == true then
			local killed_unit_owner = killedUnit:GetPlayerOwner()
			if killed_unit_owner ~= nil then
				if (killedUnit:GetTeam() == DOTA_TEAM_BADGUYS and killerEntity ~= nil and killerEntity:GetTeam() ~= DOTA_TEAM_BADGUYS) or 
				(killedUnit:HasModifier("modifier_invoker_retro_betrayal") and killed_unit_owner.invoker_retro_betrayal_original_team ~= nil and killed_unit_owner.invoker_retro_betrayal_original_team == DOTA_TEAM_BADGUYS) then
					if self.nRadiantKills == nil then
						self.nRadiantKills = 1
					else
						self.nRadiantKills = self.nRadiantKills + 1
					end
					
					if self.nRadiantKills >= GameRules.win_condition then
						print("Radiant Team Wins")
						GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
						GameRules:SetSafeToLeave( true )
					else
						print("Radiant Team has "..self.nRadiantKills.." kills out of the "..GameRules.win_condition.." needed to win")
					end
				elseif (killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killerEntity ~= nil and killerEntity:GetTeam() ~= DOTA_TEAM_GOODGUYS) or 
				(killedUnit:HasModifier("modifier_invoker_retro_betrayal") and killed_unit_owner.invoker_retro_betrayal_original_team ~= nil and killed_unit_owner.invoker_retro_betrayal_original_team == DOTA_TEAM_GOODGUYS) then
					if self.nDireKills == nil then
						self.nDireKills = 1
					else
						self.nDireKills = self.nDireKills + 1
					end

					if self.nDireKills >= GameRules.win_condition then
						print("Dire Team Wins")	
						GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
						GameRules:SetSafeToLeave( true )
					else
						print("Dire Team has "..self.nDireKills.." kills out of the "..GameRules.win_condition.." needed to win")
					end
				end
			end
		end
	end
end


-- An ability was used by a player
function RetroDota:OnAbilityUsed(keys)
	--[[local player = EntIndexToHScript(keys.PlayerID)
	local abilityname = keys.abilityname
	
	local hero = player:GetAssignedHero()
	local ability = hero:FindAbilityByName(abilityname)
	if ability then
		local mana_cost = ability:GetManaCost(ability:GetLevel() - 1)
		print("Mana Cost Option : ", GameRules.mana_cost_reduction , "This Spell Mana Cost: ",mana_cost)
		if GameRules.mana_cost_reduction == 50 then
			hero:GiveMana(mana_cost/2)
			print("Refunded "..mana_cost/2)
		elseif GameRules.mana_cost_reduction == 100 then
			hero:GiveMana(mana_cost)
			print("Refunded "..mana_cost)
		end
	end]]

end


function RetroDota:OnGlyphUsed( event )
	print("Glyph Used by Team "..keys.teamnumber)
end


-- register the 'player_voted' command in our console
Convars:RegisterCommand( "player_voted", function(name, string_values)
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 and PlayerResource:IsValidPlayer(playerID) then
			--if the player is valid, register the vote
        	return RetroDota:RegisterVote( cmdPlayer , string_values)
		else
			print("nil or -1 playerID",playerID)
		end
	end
end, "VOTE button", 0 )


Convars:RegisterCommand( "player_skip_vote", function(name, p)
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 and PlayerResource:IsValidPlayer(playerID) then
			--if the player is valid, register the vote
        	return RetroDota:IgnoreVote(cmdPlayer)
		end
	end
end, "DONT CARE button", 0 )


function RetroDota:IgnoreVote(player)
	local pID = player:GetPlayerID()
	print("Player "..pID.." skipped vote")

	EmitSoundOnClient("Draft.PickMade", player)

	GameRules.players_skipped_vote = GameRules.players_skipped_vote + 1
	local vote_count = GameRules.players_voted + GameRules.players_skipped_vote
	GameRules:SendCustomMessage("<font color='#2EFE2E'>("..vote_count.."/"..GameRules.player_count.." players have voted so far.)</font>", 0, 0)

	if (GameRules.players_voted + GameRules.players_skipped_vote == GameRules.player_count ) then
    	RetroDota:OnEveryoneVoted()
    end
end


-- Lua is retarded
function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end


function RetroDota:RegisterVote( player, string_values )
 
 	local pID = player:GetPlayerID()
    print("RegisterVote", string_values )

    local vote = split(string_values, ",")
    DeepPrintTable(vote)

    local win_condition = vote[1]
    local level = vote[2]
    local gold = vote[3]
    local invoke_cd = vote[4]
    local invoke_slots = vote[5]
    local mana_cost_reduction = vote[6]
    local mirror_match = vote[7]
    local fast_respawn = vote[8]
    local gold_multiplier = vote[9]
    local xp_multiplier = vote[10]

    EmitSoundOnClient("HeroPicker.Selected", player)

	GameRules.players_voted = GameRules.players_voted + 1

    -- Insert the different values in each table
    table.insert(GameRules.win_condition_votes, win_condition)
	table.insert(GameRules.level_votes, level)
	table.insert(GameRules.gold_votes, gold)
	table.insert(GameRules.invoke_cd_votes, invoke_cd)
	table.insert(GameRules.invoke_slots_votes, invoke_slots)
	table.insert(GameRules.mirror_match_votes, mirror_match)
	table.insert(GameRules.mana_cost_reduction_votes, mana_cost_reduction)
	table.insert(GameRules.fast_respawn_votes, fast_respawn)
	table.insert(GameRules.gold_multiplier_votes, gold_multiplier)
	table.insert(GameRules.xp_multiplier_votes, xp_multiplier)	

    if (GameRules.players_voted + GameRules.players_skipped_vote == GameRules.player_count ) then
    	RetroDota:OnEveryoneVoted()
    else
    	local vote_count = GameRules.players_voted + GameRules.players_skipped_vote
    	print( vote_count .. " out of " .. GameRules.player_count .. " have voted")
    	GameRules:SendCustomMessage("<font color='#2EFE2E'>("..vote_count.."/"..GameRules.player_count.." players have voted so far.)</font>", 0, 0)
    end

end


-- Auxiliar function to return the average numeric value of the votes rounded down
function RoundedDownAverage( table )
    	
	local value = 0
	local cant = GameRules.players_voted

	for k,v in pairs(table) do
		value = value + v
	end

	print("   Averaging: " .. value.."/"..GameRules.players_voted)
	value = math.floor(value / cant)
    print("   Rounded: ".. value)

	return tostring(value)
end


function RetroDota:OnEveryoneVoted()
	
	print("All players have voted.")

	-- Handle the case where all players skipped voting
	if GameRules.players_voted == 0 then
		print("Everyone skipped voting.  The game will use default settings.")
		--[[GameRules.win_condition = GameRules.vote_options.kills_to_win["1"]
		GameRules.starting_level = GameRules.vote_options.starting_level["1"]
		GameRules.starting_gold = GameRules.vote_options.starting_gold["1"]
		GameRules.invoke_cd = GameRules.vote_options.invoke_cd["1"]
		GameRules.mana_cost_reduction = GameRules.vote_options.mana_cost_reduction["1"]
		GameRules.invoke_slots = "1"
		GameRules.mirror_match = "0"
		GameRules.fast_respawn = "0"
		GameRules.gold_multiplier = "1"
		GameRules.xp_multiplier = "1"]]
	else
		print("Averaging the voted-on values now.")

		print("-> Win Condition")
	    GameRules.win_condition = GameRules.vote_options.kills_to_win[RoundedDownAverage(GameRules.win_condition_votes)]
	    print("=> "..GameRules.win_condition)

		print("-> Starting Level")
		GameRules.starting_level = GameRules.vote_options.starting_level[RoundedDownAverage(GameRules.level_votes)]
		print("==> "..GameRules.starting_level)

		print("-> Starting Gold")
		GameRules.starting_gold = GameRules.vote_options.starting_gold[RoundedDownAverage(GameRules.gold_votes)]
		print("==> "..GameRules.starting_gold)

		print("-> Invoke Cooldown")
		GameRules.invoke_cd = GameRules.vote_options.invoke_cd[RoundedDownAverage(GameRules.invoke_cd_votes)]
		print("==> "..GameRules.invoke_cd)

		print("-> Mana Cost Reduction")
		GameRules.mana_cost_reduction = GameRules.vote_options.mana_cost_reduction[RoundedDownAverage(GameRules.mana_cost_reduction_votes)]
		print("==> "..GameRules.mana_cost_reduction)

		print("-> Invoke Slots")
		GameRules.invoke_slots = RoundedDownAverage(GameRules.invoke_slots_votes)
		print("==> "..GameRules.invoke_slots)

		print("-> Mirror Match")
		GameRules.mirror_match = RoundedDownAverage(GameRules.mirror_match_votes)
		print("==> "..GameRules.mirror_match)

		print("-> Fast Respawn?")
		GameRules.fast_respawn = RoundedDownAverage(GameRules.fast_respawn_votes)
		print("==> "..GameRules.fast_respawn)

		print("-> Gold Multiplier")
		GameRules.gold_multiplier = RoundedDownAverage(GameRules.gold_multiplier_votes)
		print("==> "..GameRules.gold_multiplier)

		print("-> XP Multiplier")
		GameRules.xp_multiplier = RoundedDownAverage(GameRules.xp_multiplier_votes)
		print("==> "..GameRules.xp_multiplier)

		print("=== FINISHED VOTE AVERAGING ===")
	
	end

	GameRules:SendCustomMessage("<font color='#2EFE2E'>Voting has finished!</font>", 0, 0)
	GameRules.finished_voting = true

	-- Results from voting
	if GameRules.win_condition ~= "0" and GameRules.win_condition ~= 0 then  --If the win condition is kills.
		--print(GameRules.win_condition)
		END_GAME_ON_KILLS = true
		FireGameEvent("show_center_message",{ message = "The first team to "..GameRules.win_condition.." kills wins!", duration = 10.0})
		GameRules:SendCustomMessage("The first team to amass <font color='#FF9933'>"..GameRules.win_condition.." kills</font> wins!", 0, 0)
		
		--Make the towers invulnerable, which in turn will keep the ancients invulnerable, since there is a kills to win condition.
		--The radiant "towers" do not get their invulnerability removed at 0:00 gametime if END_GAME_ON_KILLS == true.
		local towers = Entities:FindAllByClassname('npc_dota_tower')
		for i, individual_tower in ipairs(towers) do
			Timers:CreateTimer({
				endTime = .03,
				callback = function()
					if GameRules:GetDOTATime(false, false) > 0 then
						individual_tower:AddNewModifier(individual_tower, nil, "modifier_invulnerable", {})
						return
					else
						return .03
					end
				end
			})
		end
	else  --If the win condition is the ancient.
		GameRules:SendCustomMessage("Destroy the <font color='#FF9933'>enemy's ancient</font> to win!", 0, 0)
		FireGameEvent("show_center_message",{ message = "Destroy the enemy's ancient to win!", duration = 10.0})
	end
	
	-- Starting Level and Gold
	GameRules:SendCustomMessage("Players start at level <font color='#FF9933'>" ..GameRules.starting_level.. "</font> with <font color='#FF9933'>" .. GameRules.starting_gold .. "</font> starting gold.", 0, 0)
	SetHeroLevels(GameRules.starting_level)
	SetBonusGold(GameRules.starting_gold)
	
	--Invoke slots
	if GameRules.invoke_slots == "1" then
		GameRules:SendCustomMessage("There is <font color='#FF9933'>" ..GameRules.invoke_slots.." slot</font> for invoked spells.", 0, 0)
	else
		GameRules:SendCustomMessage("There are <font color='#FF9933'>" ..GameRules.invoke_slots.." slots</font> for invoked spells.", 0, 0)
	end
	
	--Invoke cooldown and spell mana cost
	if GameRules.mana_cost_reduction == 50 then
		GameRules:SendCustomMessage("Invoke has a <font color='#FF9933'>" .. GameRules.invoke_cd.."-second cooldown</font>, and all spells cost <font color='#FF9933'>half mana</font>.", 0, 0)
	elseif GameRules.mana_cost_reduction == 100 then
		GameRules:SendCustomMessage("Invoke has a <font color='#FF9933'>" .. GameRules.invoke_cd.."-second cooldown</font>, and all spells cost <font color='#FF9933'>no mana</font>.", 0, 0)
	else
		GameRules:SendCustomMessage("Invoke has a <font color='#FF9933'>" .. GameRules.invoke_cd.."-second cooldown</font>, and all spells cost <font color='#FF9933'>full mana</font>.", 0, 0)
	end
	SetInvokeVersion(GameRules.invoke_cd)
	
	
	if GameRules.fast_respawn == "1" then
		GameRules:GetGameModeEntity():SetFixedRespawnTime(3)
	end

	-- Mirror + Insta Respawn
	if GameRules.mirror_match == "1" then
		if GameRules.fast_respawn == "1" then
			GameRules:SendCustomMessage("Mirror Match is <font color='#FF9933'>ON</font>.  Instant respawn mode is <font color='#FF9933'>ON</font>.", 0, 0)
		else
			GameRules:SendCustomMessage("Mirror Match is <font color='#FF9933'>ON</font>.  Instant respawn mode is <font color='#FF9933'>OFF</font>.", 0, 0)
		end
	else
		if GameRules.fast_respawn == "1" then
			GameRules:SendCustomMessage("Mirror Match is <font color='#FF9933'>OFF</font>.  Instant respawn mode is <font color='#FF9933'>ON</font>.", 0, 0)
		else
			GameRules:SendCustomMessage("Mirror Match is <font color='#FF9933'>OFF</font>.  Instant respawn mode is <font color='#FF9933'>OFF</font>.", 0, 0)
		end
	end

	GameRules:SendCustomMessage("The gold multiplier is <font color='#FF9933'>"..GameRules.gold_multiplier.."x</font>.  The XP multiplier is <font color='#FF9933'>"..GameRules.xp_multiplier .. "x</font>.", 0, 0)
	GameRules:SetGoldPerTick(1*GameRules.gold_multiplier)

	-- Set Custom XP Value on all heroes in game
	local allHeroes = HeroList:GetAllHeroes()
	for k, hero in pairs( allHeroes ) do
		local XP_value = XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()] * GameRules.xp_multiplier
		print("Set unit's EXP bounty to " .. XP_value)
		hero:SetCustomDeathXP(XP_value)
	end
	
	local running_in_workshop_tools = true
	for k, hero in pairs( allHeroes ) do
		if running_in_workshop_tools == true and IsValidEntity(hero) then
			local pid = hero:GetPlayerID()
			if pid ~= nil and PlayerResource:IsValidPlayerID(pid) and PlayerResource:IsValidPlayer(pid) then
				local individual_player = PlayerResource:GetPlayer(pid)
				if individual_player ~= nil and PlayerResource:GetPlayerName(pid) ~= nil and PlayerResource:GetPlayerName(pid) ~= "" then
					running_in_workshop_tools = false
					print("The game appears to be running in the main client (not the Workshop Tools), so stats will be collected.")
				end
			end
		end
	end

	-- Mirroring most picked if needed
	if GameRules.mirror_match == "2" then
		DeepPrintTable(allHeroes)
		-- Missing counting and setting the most picked hero
		-- for k, hero in pairs( allHeroes ) do
		-- end
	end
	
	-- Add vote settings to our stat collector, so long as the gamemode is not running in the Workshop Tools.
	if running_in_workshop_tools == false then
		statcollection.addStats({
			modes = {
				win_condition = GameRules.win_condition,
				starting_level = GameRules.starting_level,
				starting_gold = GameRules.starting_gold,
				invoke_cd = GameRules.invoke_cd,
				mana_cost_reduction = GameRules.mana_cost_reduction,
				invoke_slots = GameRules.invoke_slots,
				mirror_match = GameRules.mirror_match,
				fast_respawn = GameRules.fast_respawn,
				gold_multiplier = GameRules.gold_multiplier,
				xp_multiplier = GameRules.xp_multiplier
			}
		})
	end
end


-- Sets all the heroes to this level
-- An additional check is done OnPlayerPickHero for players that still haven't picked when the vote ends
function SetHeroLevels(level)
	local allHeroes = HeroList:GetAllHeroes()
	for k, hero in pairs( allHeroes ) do
		--[[for i=1,level-1 do
			hero:HeroLevelUp(false)
		end]]
		hero:AddExperience(XP_PER_LEVEL_TABLE[level], false, false)
		print("Added "..XP_PER_LEVEL_TABLE[level] .. " XP.")
	end
end


-- Gives bonus gold to all players
function SetBonusGold(gold)
	for pID=0,9 do
		if PlayerResource:IsValidPlayerID(pID) then
			PlayerResource:ModifyGold(pID, gold - 625, false, 0)
		end
	end
end


-- Gives the player the version of Invoke with the correct cooldown.
-- An additional check is done OnPlayerPickHero for players that still haven't picked when the vote ends.
function SetInvokeVersion(cooldown)
	if cooldown ~= "6" then  --The active version of Invoke defaults to a 6-second cooldown, so don't change anything if the default cooldown was selected.
		local allHeroes = HeroList:GetAllHeroes()
		for k, hero in pairs( allHeroes ) do
			if hero:GetName() == "npc_dota_hero_Invoker" then
				local old_invoke_ability = hero:FindAbilityByName("invoker_retro_invoke_6_second_cooldown")
				if old_invoke_ability ~= nil then
					local old_invoke_ability_level = old_invoke_ability:GetLevel()
					local old_invoke_ability_cooldown = old_invoke_ability:GetCooldownTimeRemaining()
				
					hero:RemoveAbility("invoker_retro_invoke_6_second_cooldown")
					local new_invoke_ability_name = "invoker_retro_invoke_" .. cooldown .. "_second_cooldown"
					hero:AddAbility(new_invoke_ability_name)
					
					local new_invoke_ability = hero:FindAbilityByName(new_invoke_ability_name)
					new_invoke_ability:SetLevel(old_invoke_ability_level)
					new_invoke_ability:StartCooldown(old_invoke_ability_cooldown)
				end
			end
		end
	end
end