--[[
Retro Dota game mode
]]

print("Retro Dota game mode loaded.")

RETRODOTA_VERSION = "1.0.0"

END_GAME_ON_KILLS = false
KILLS_TO_END_GAME_FOR_TEAM = 0

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
	GameRules.wtf_votes = {}
	GameRules.fast_respawn_votes = {}
	GameRules.gold_multiplier_votes = {}
	GameRules.xp_multiplier_votes = {}

	self.nRadiantKills = 0
  	self.nDireKills = 0

	--Set the hull radius of the ancients.  This is especially important for the Dire ancient, since it allows melee creeps to be able to attack it.
	local ancients = Entities:FindAllByClassname('npc_dota_fort')
	for k,v in pairs(ancients) do
		v:SetHullRadius(190)
	end

	GameRules.vote_options = LoadKeyValues("scripts/npc/kv/vote_options.txt")
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

	GameRules.player_count = GameRules.player_count + 1

end

-- This function is called as the first player loads and sets up the GameMode parameters
function RetroDota:CaptureGameMode()
	if mode == nil then
		-- Set GameMode parameters
		mode = GameRules:GetGameModeEntity()

		-- Custom Settings (not used)
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

end

function RetroDota:OnPlayerPickHero(keys)
	local hero = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
	local playerID = hero:GetPlayerID()
	
	FireGameEvent( 'send_hero_ent', { player_ID = playerID, _ent = PlayerResource:GetSelectedHeroEntity(playerID):GetEntityIndex() } )
	FireGameEvent( 'show_spell_list_button', { player_ID = playerID } )

	-- Check the level of this hero, add the bonus levels if needed
	if GameRules.finished_voting and (hero:GetLevel() ~= GameRules.starting_level) then
		for i=1,(GameRules.starting_level-hero:GetLevel()) do
			hero:HeroLevelUp(false)
		end	
	end
end

--Remove movement speed spawn modifiers on lane creeps, and alter the creeps' models.
function RetroDota:OnNPCSpawned(keys)
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


-- An entity died
function RetroDota:OnEntityKilled( keys )

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	if killedUnit:IsRealHero() and END_GAME_ON_KILLS == true then 
		if killedUnit:GetTeam() == DOTA_TEAM_BADGUYS and killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
			self.nRadiantKills = self.nRadiantKills + 1
			if self.nRadiantKills >= GameRules.win_condition then
				print("Radiant Team Wins")
				GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
				GameRules:SetSafeToLeave( true )
			else
				print("Radiant Team has "..self.nRadiantKills.." kills out of the "..GameRules.win_condition.." needed to win")
			end
		elseif killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killerEntity:GetTeam() == DOTA_TEAM_BADGUYS then
			self.nDireKills = self.nDireKills + 1
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



-- register the 'player_voted' command in our console
Convars:RegisterCommand( "player_voted", function(name, win_condition, level, gold, invoke_cd, invoke_slots, mana_cost_reduction, 
												wtf, fast_respawn, gold_multiplier, xp_multiplier)
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			--if the player is valid, register the vote
        	return RetroDota:RegisterVote( cmdPlayer , win_condition, level, gold, invoke_cd, invoke_slots, mana_cost_reduction, 
												wtf, fast_respawn, gold_multiplier, xp_multiplier)
		else
			print("nil or -1 playerID",playerID)
		end
	end
end, "VOTE button", 0 )


Convars:RegisterCommand( "player_skip_vote", function(name, p)
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
			--if the player is valid, register the vote
        	return RetroDota:IgnoreVote(playerID)
		end
	end
end, "DONT CARE button", 0 )

function RetroDota:IgnoreVote(player)
	print("Player "..player.." skipped vote")
	GameRules.players_skipped_vote = GameRules.players_skipped_vote + 1

	if (GameRules.players_voted + GameRules.players_skipped_vote == GameRules.player_count ) then
    	RetroDota:OnEveryoneVoted()
    end
end


function RetroDota:RegisterVote( player, win_condition, level, gold, invoke_cd, invoke_slots, mana_cost_reduction, wtf, fast_respawn, gold_multiplier, xp_multiplier )
 
    --get the player's ID
    local pID = player:GetPlayerID()
    print("RegisterVote", pID, win_condition, level, gold, invoke_cd, invoke_slots, mana_cost_reduction, wtf, fast_respawn, gold_multiplier, xp_multiplier)

	GameRules.players_voted = GameRules.players_voted + 1

    -- Insert the different values in each table
    table.insert(GameRules.win_condition_votes, win_condition)
	table.insert(GameRules.level_votes, level)
	table.insert(GameRules.gold_votes, gold)
	table.insert(GameRules.invoke_cd_votes, invoke_cd)
	table.insert(GameRules.invoke_slots_votes, invoke_slots)
	table.insert(GameRules.mana_cost_reduction_votes, mana_cost_reduction)
	table.insert(GameRules.wtf_votes, wtf)
	table.insert(GameRules.fast_respawn_votes, fast_respawn)
	table.insert(GameRules.gold_multiplier_votes, gold_multiplier)
	table.insert(GameRules.xp_multiplier_votes, xp_multiplier)	

    if (GameRules.players_voted + GameRules.players_skipped_vote == GameRules.player_count ) then
    	RetroDota:OnEveryoneVoted()
    else
    	print( GameRules.players_voted + GameRules.players_skipped_vote .. " out of " .. GameRules.player_count .. " have voted")
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
	
	print("All Players have voted.")

	-- Handle the case where all players skipped voting
	if GameRules.players_voted == 0 then
		print("Everyone skipped voting. Setting the defaults")
		GameRules.win_condition = GameRules.vote_options.kills_to_win["1"]
		GameRules.starting_level = GameRules.vote_options.starting_level["1"]
		GameRules.starting_gold = GameRules.vote_options.starting_gold["1"]
		GameRules.invoke_cd = GameRules.vote_options.invoke_cd["1"]
		GameRules.mana_cost = GameRules.vote_options.mana_cost["1"]
		GameRules.invoke_slots = "1"
		GameRules.wtf = "0"
		GameRules.fast_respawn = "0"
		GameRules.gold_multiplier = "1"
		GameRules.xp_multiplier = "1"

	else
		print("Averaging the values now")

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

		print("-> Mana Cost")
		GameRules.mana_cost = GameRules.vote_options.mana_cost[RoundedDownAverage(GameRules.mana_cost_reduction_votes)]
		print("==> "..GameRules.mana_cost)

		print("-> Invoke Slots")
		GameRules.invoke_slots = RoundedDownAverage(GameRules.invoke_slots_votes)
		print("==> "..GameRules.invoke_slots)

		print("-> WTF?")
		GameRules.wtf = RoundedDownAverage(GameRules.wtf_votes)
		print("==> "..GameRules.wtf)

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

	GameRules:SendCustomMessage("<font color='#2EFE2E'>Finished voting!</font>", 0, 0)
	GameRules.finished_voting = true

	-- Apply the settings

	-- Set Kills to Win if the option is not the default (Ancient)
	if GameRules.win_condition ~= "0" then
		print(GameRules.win_condition)
		END_GAME_ON_KILLS = true
	end

	SetHeroLevels(GameRules.starting_level)
	SetBonusGold(GameRules.starting_gold)

	if GameRules.wtf == "1" then
		SendToConsole("dota_ability_debug 1")
		SendToServerConsole("dota_ability_debug 1")
	end

	if GameRules.fast_respawn == "1" then
		GameRules:GetGameModeEntity():SetFixedRespawnTime(0)
	end

 --[[  
    -- Add settings to our stat collector
    statcollection.addStats({
        modes = {
            difficulty = GameRules.DIFFICULTY
        }
    })]]
end

-- Sets all the heroes to this level
-- An additional check is done OnHeroPicked for players that still haven't picked when the vote ends
function SetHeroLevels(level)
	local allHeroes = HeroList:GetAllHeroes()
	for k, hero in pairs( allHeroes ) do
		for i=1,level-1 do
			hero:HeroLevelUp(false)
		end
	end
end


-- Gives bonus gold to all players
function SetBonusGold(gold)
	for pID=0,9 do
		if PlayerResource:IsValidPlayerID(pID) then
			PlayerResource:ModifyGold(pID, gold, false, 0)
		end
	end
end