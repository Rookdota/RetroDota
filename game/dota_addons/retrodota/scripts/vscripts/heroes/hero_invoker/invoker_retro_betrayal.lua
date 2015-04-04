--[[ ============================================================================================================
	Author: Rook
	Date: March 02, 2015
	Called when Betrayal is cast.  Moves the target unit to another (custom) team for the duration.
================================================================================================================= ]]
function invoker_retro_betrayal_on_spell_start(keys)
	local target_pid = keys.target:GetPlayerID()
	local target_player = PlayerResource:GetPlayer(target_pid)	
	
	local betrayal_explosion_maximum_radius = 75
	local betrayal_explosion = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_betrayal_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:SetParticleControl(betrayal_explosion, 1, Vector(betrayal_explosion_maximum_radius, 0, 0))
	
	local endTime = GameRules:GetGameTime() + 3
	Timers:CreateTimer({  --Remove the Betrayal explosion after a short duration, and decrease its maximum radius steadily until it is removed.
		endTime = .03,
		callback = function()
			if GameRules:GetGameTime() >= endTime or betrayal_explosion_maximum_radius <= 0 then
				ParticleManager:DestroyParticle(betrayal_explosion, false)
				return
			else
				betrayal_explosion_maximum_radius = betrayal_explosion_maximum_radius - 1
				ParticleManager:SetParticleControl(betrayal_explosion, 1, Vector(betrayal_explosion_maximum_radius, 0, 0))
				return .03
			end
		end
	})
	
	if keys.target:HasModifier("modifier_invoker_retro_betrayal") then  --If the unit is already on a unique team, simply refresh the modifier's duration.  This does not trigger the modifier's OnDestroy event.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_betrayal", nil)
		keys.target:EmitSound("Hero_Invoker.Alacrity")
	else
		--Custom teams are DOTA_TEAM_CUSTOM_1 through DOTA_TEAM_CUSTOM_8, which correspond with ints 6-13, inclusive.
		local found_new_team = false
		for i=6, 13, 1 do
			if found_new_team == false then
				if PlayerResource:GetNthPlayerIDOnTeam(i, 1) == -1 then  --If there are currently no players on this custom team.
					keys.target:EmitSound("Hero_Invoker.Alacrity")
					
					--Store the target's original team number, so they can be moved back to that team when Betrayal ends.
					target_player.invoker_retro_betrayal_original_team = keys.target:GetTeam()
				
					PlayerResource:SetCustomTeamAssignment(target_pid, i)
					keys.target:SetTeam(i)
					
					--Set up health labels for every hero now that a unit has Betrayal on them.
					local herolist = HeroList:GetAllHeroes()
					if herolist ~= nil then
						for i, individual_hero in ipairs(herolist) do
							if IsValidEntity(individual_hero) then
								local pid = individual_hero:GetPlayerID()
								if pid ~= nil and PlayerResource:IsValidPlayerID(pid) and PlayerResource:IsValidPlayer(pid) then
									local individual_player = PlayerResource:GetPlayer(pid)
									if individual_player ~= nil then
										if individual_hero:GetTeam() == DOTA_TEAM_GOODGUYS or individual_player.invoker_retro_betrayal_original_team == DOTA_TEAM_GOODGUYS then
											individual_hero:SetCustomHealthLabel("Radiant", 0, 255, 0)
										elseif individual_hero:GetTeam() == DOTA_TEAM_BADGUYS or individual_player.invoker_retro_betrayal_original_team == DOTA_TEAM_BADGUYS then
											individual_hero:SetCustomHealthLabel("Dire", 255, 0, 0)
										end
									end
								end
							end
						end
					end
					
					keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_betrayal", nil)

					found_new_team = true
				end
			end
		end
		
		if found_new_team == false then  --If all the custom teams had at least one unit currently in them (unlikely, but possible), notify the player and restore Betrayal's mana cost and cooldown.
			keys.ability:RefundManaCost()
			keys.ability:EndCooldown()
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", keys.caster:GetPlayerOwner())
			
			--This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
			FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Too Many Units Affected By Betrayal (Technical Limitation)" } )
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: March 02, 2015
	Called when Betrayal's modifier expires.  Moves the unit back to their original team.
================================================================================================================= ]]
function modifier_invoker_retro_betrayal_on_destroy(keys)
	local target_pid = keys.target:GetPlayerID()
	local target_player = PlayerResource:GetPlayer(target_pid)
	local target_team = keys.target:GetTeam()

	--Remove health labels if no heroes have Betrayal on them anymore.
	local someone_has_betrayal = false
	local herolist = HeroList:GetAllHeroes()
	if herolist ~= nil then
		for i, individual_hero in ipairs(herolist) do
			if individual_hero ~= nil and IsValidEntity(individual_hero) and individual_hero:HasModifier("modifier_invoker_retro_betrayal") then
				someone_has_betrayal = true
			end
		end

		if not someone_has_betrayal then
			for i, individual_hero in ipairs(herolist) do
				if individual_hero ~= nil and IsValidEntity(individual_hero) then
					individual_hero:SetCustomHealthLabel("", 0, 0, 0)  --Remove the custom health label.
				end
			end
		end
	end

	if target_player ~= nil and target_player.invoker_retro_betrayal_original_team ~= nil and target_team ~= "DOTA_TEAM_GOODGUYS" and target_team ~= "DOTA_TEAM_BADGUYS" and PlayerResource:IsValidPlayerID(target_pid) and PlayerResource:IsValidPlayer(target_pid) then  --If the invoker_retro_betrayal_original_team was not stored, we're in trouble.
		PlayerResource:SetCustomTeamAssignment(target_pid, target_player.invoker_retro_betrayal_original_team)
		keys.target:SetTeam(target_player.invoker_retro_betrayal_original_team)
		target_player.invoker_retro_betrayal_original_team = nil
	end
end