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

		-- Custom Settings
		GameRules:SetUseCustomHeroXPValues(true)
		GameRules:SetUseBaseGoldBountyOnHeroes(false)
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

	-- Set Custom XP Value when a hero is picked after the multiplier was defined
	if GameRules.xp_multiplier then
		local XP_value = XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()] * GameRules.xp_multiplier
		print("Set unit's EXP bounty to " .. XP_value)
		hero:SetCustomDeathXP(XP_value)
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
		npc:SetMinimumGoldBounty(npc:GetGoldBounty() * tonumber(GameRules.gold_multiplier))
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

	if killedUnit:IsRealHero() then

		-- Gold Multiplier for hero kills
		if killerEntity:IsRealHero() and GameRules.gold_multiplier then
			local bounty = killedUnit:GetGoldBounty() * GameRules.gold_multiplier - killedUnit:GetGoldBounty()
			killerEntity:ModifyGold(bounty, true, 0)

			-- Assist Gold?
			
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



		if END_GAME_ON_KILLS == true then 
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
end

-- An ability was used by a player
function RetroDota:OnAbilityUsed(keys)
	local player = EntIndexToHScript(keys.PlayerID)
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
	end

end



-- register the 'player_voted' command in our console
Convars:RegisterCommand( "player_voted", function(name, string_values)
	local cmdPlayer = Convars:GetCommandClient()
	if cmdPlayer then
		local playerID = cmdPlayer:GetPlayerID()
		if playerID ~= nil and playerID ~= -1 then
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
		if playerID ~= nil and playerID ~= -1 then
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
	GameRules:SendCustomMessage("<font color='#2EFE2E'>("..vote_count.."/"..GameRules.player_count.." votes)</font>", 0, 0)

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
    local wtf = vote[7]
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
	table.insert(GameRules.mana_cost_reduction_votes, mana_cost_reduction)
	table.insert(GameRules.wtf_votes, wtf)
	table.insert(GameRules.fast_respawn_votes, fast_respawn)
	table.insert(GameRules.gold_multiplier_votes, gold_multiplier)
	table.insert(GameRules.xp_multiplier_votes, xp_multiplier)	

    if (GameRules.players_voted + GameRules.players_skipped_vote == GameRules.player_count ) then
    	RetroDota:OnEveryoneVoted()
    else
    	local vote_count = GameRules.players_voted + GameRules.players_skipped_vote
    	print( vote_count .. " out of " .. GameRules.player_count .. " have voted")
    	GameRules:SendCustomMessage("<font color='#2EFE2E'>("..vote_count.."/"..GameRules.player_count.." votes)</font>", 0, 0)
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
		GameRules.mana_cost_reduction = GameRules.vote_options.mana_cost_reduction["1"]
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

		print("-> Mana Cost Reduction")
		GameRules.mana_cost_reduction = GameRules.vote_options.mana_cost_reduction[RoundedDownAverage(GameRules.mana_cost_reduction_votes)]
		print("==> "..GameRules.mana_cost_reduction)

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

	-- Results from voting

	-- Set Kills to Win if the option is not the default (Ancient)
	if GameRules.win_condition ~= "0" and GameRules.win_condition ~= 0 then
		print(GameRules.win_condition)
		END_GAME_ON_KILLS = true
		FireGameEvent("show_center_message",{ message = "First Team to "..GameRules.win_condition.." Kills Wins", duration = 10.0})
		GameRules:SendCustomMessage("The game will end when one team gets "..GameRules.win_condition.." kills!", 0, 0)
	end
	
	-- Starting Level and Gold
	GameRules:SendCustomMessage("Starting level is "..GameRules.starting_level.."! Bonus Gold is "..GameRules.starting_gold, 0, 0)
	SetHeroLevels(GameRules.starting_level)
	SetBonusGold(GameRules.starting_gold)
	
	if GameRules.mana_cost_reduction == "2" then
		GameRules:SendCustomMessage("There will be "..GameRules.invoke_slots.." Invoke Slots, with " .. GameRules.invoke_cd.." sec Invoke Cooldown, and 50% less mana cost on all spells", 0, 0)
	elseif GameRules.mana_cost_reduction == "3" then
		GameRules:SendCustomMessage("There will be "..GameRules.invoke_slots.." Invoke Slots, with " .. GameRules.invoke_cd.." sec Invoke Cooldown, and spells cost 0 mana to cast", 0, 0)
	else
		GameRules:SendCustomMessage("There will be "..GameRules.invoke_slots.." Invoke Slots", 0, 0)
	end
	
	if GameRules.fast_respawn == "1" then
		GameRules:GetGameModeEntity():SetFixedRespawnTime(0)
	end

	if GameRules.wtf == "1" then
		SendToConsole("dota_ability_debug 1")
		SendToServerConsole("dota_ability_debug 1")
	end

	-- WTF + Insta Respawn
	if GameRules.wtf == "1" then
		if GameRules.fast_respawn == "1" then
			GameRules:SendCustomMessage("WTF Mode is ON. Instant Respawn is ON", 0, 0)
		else
			GameRules:SendCustomMessage("WTF Mode is ON", 0, 0)
		end
	else
		if GameRules.fast_respawn == "1" then
			GameRules:SendCustomMessage("Instant Respawn is ON", 0, 0)
		end
	end

	if GameRules.gold_multiplier ~= "1" or GameRules.xp_multiplier ~= "1" then
		GameRules:SendCustomMessage("Gold Multiplier: "..GameRules.gold_multiplier.." -- XP Multiplier: "..GameRules.xp_multiplier, 0, 0)
	end

	-- Set Custom XP Value on all heroes in game
	local allHeroes = HeroList:GetAllHeroes()
	for k, hero in pairs( allHeroes ) do
		local XP_value = XP_BOUNTY_PER_LEVEL_TABLE[hero:GetLevel()] * GameRules.xp_multiplier
		print("Set unit's EXP bounty to " .. XP_value)
		hero:SetCustomDeathXP(XP_value)
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