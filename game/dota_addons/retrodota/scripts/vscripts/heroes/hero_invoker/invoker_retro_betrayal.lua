--[[ ============================================================================================================
	Author: Rook
	Date: March 02, 2015
	Called when Betrayal is cast.  Moves the target unit to another (custom) team for the duration.
================================================================================================================= ]]
function invoker_retro_betrayal_on_spell_start(keys)
	local target_pid = keys.target:GetPlayerID()
	local target_player = PlayerResource:GetPlayer(target_pid)	
	
	if keys.target:HasModifier("modifier_invoker_retro_betrayal") then  --If the unit is already on a unique team, simply refresh the modifier's duration.  This does not trigger the modifier's OnDestroy event.
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_betrayal", nil)  
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

	if target_player.invoker_retro_betrayal_original_team ~= nil then  --If this value was not stored, we're in trouble.
		PlayerResource:SetCustomTeamAssignment(target_pid, target_player.invoker_retro_betrayal_original_team)
		keys.target:SetTeam(target_player.invoker_retro_betrayal_original_team)
		target_player.invoker_retro_betrayal_original_team = nil
	end
end