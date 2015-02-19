--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Invoke is cast.  Stores cooldown information for the ability that was bound to D, and adds a new
	ability bound to F based on the order of the orbs around Invoker.
================================================================================================================= ]]
function invoker_retro_invoke_on_spell_start(keys)
	keys.caster:EmitSound("Hero_Invoker.Invoke")

	
	--[[The following code is for the modern Invoker that can invoke two spells, and is left here but commented out in case
		we decide to allow Invoker to invoke two spells.
		
	--Since cooldowns are tied to the ability but we don't have room to keep all the abilities on Invoker due to the
	--limited number of slots, keep track of the gametime of when abilities were last cast, which we can use to determine
	--if invoked spells should still be on cooldown from when they were last used.
	local ability_d = keys.caster:GetAbilityByIndex(4)
	local ability_d_name = ability_d:GetName()
	--Update keys.caster.invoke_ability_cooldown_remaining[ability_name] of the ability to be removed, so cooldowns can be tracked.
	--We cannot just store the gametime because the ability's maximum cooldown may have changed due to leveling up Invoker's orbs
	--by the time the ability is reinvoked.  Therefore, keys.caster.invoke_ability_gametime_removed[ability_name] is also stored.
	--Items like Refresher Orb should clear this list.
	if keys.caster.invoke_ability_cooldown_remaining == nil then
		keys.caster.invoke_ability_cooldown_remaining = {}
	end
	if keys.caster.invoke_ability_gametime_removed == nil then
		keys.caster.invoke_ability_gametime_removed = {}
	end
	keys.caster.invoke_ability_cooldown_remaining[ability_d_name] = ability_d:GetCooldownTimeRemaining()
	keys.caster.invoke_ability_gametime_removed[ability_d_name] = GameRules:GetGameTime() 
	
	--Shift the ability in the F slot to the D slot, and remove the ability that was in the F slot.
	keys.caster:RemoveAbility(ability_d_name)
	local ability_f = keys.caster:GetAbilityByIndex(5)
	local ability_f_name = ability_f:GetName()
	local ability_f_current_cooldown = ability_f:GetCooldownTimeRemaining()
	keys.caster:RemoveAbility(ability_f_name)
	keys.caster:AddAbility(ability_f_name)  --This will place the ability that was bound to F in the D slot.
	local new_ability_d = keys.caster:FindAbilityByName(ability_f_name)
	new_ability_d:StartCooldown(ability_f_current_cooldown)
	
	]]
	
	--Since cooldowns are tied to the ability but we don't have room to keep all the abilities on Invoker due to the
	--limited number of slots, keep track of the gametime of when abilities were last cast, which we can use to determine
	--if invoked spells should still be on cooldown from when they were last used.
	local old_spell_invoked = keys.caster:GetAbilityByIndex(3)
	local old_spell_invoked_name = old_spell_invoked:GetName()
	local old_spell_invoked_index_name = old_spell_invoked_name
	
	if string.sub(old_spell_invoked_index_name, 1, 22) == "invoker_retro_icy_path" then  --If one of the 7 Icy Path spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_icy_path"
	elseif string.sub(old_spell_invoked_index_name, 1, 20) == "invoker_retro_portal" then  --If one of the 7 Portal spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_portal"
	end
	
	--Update keys.caster.invoke_ability_cooldown_remaining[ability_name] of the ability to be removed, so cooldowns can be tracked.
	--We cannot just store the gametime because the ability's maximum cooldown may have changed due to leveling up Invoker's orbs
	--by the time the ability is reinvoked.  Therefore, keys.caster.invoke_ability_gametime_removed[ability_name] is also stored.
	--Items like Refresher Orb should clear this list.
	if keys.caster.invoke_ability_cooldown_remaining == nil then
		keys.caster.invoke_ability_cooldown_remaining = {}
	end
	if keys.caster.invoke_ability_gametime_removed == nil then
		keys.caster.invoke_ability_gametime_removed = {}
	end
	keys.caster.invoke_ability_cooldown_remaining[old_spell_invoked_index_name] = old_spell_invoked:GetCooldownTimeRemaining()
	keys.caster.invoke_ability_gametime_removed[old_spell_invoked_index_name] = GameRules:GetGameTime() 
	
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	
	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)  --Play the particle effect.
	
	if keys.caster.invoked_orbs[1] ~= nil and keys.caster.invoked_orbs[2] ~= nil and keys.caster.invoked_orbs[3] ~= nil then  --A spell will be invoked only if three orbs have been summoned.
		keys.caster:RemoveAbility(old_spell_invoked_name)  --Remove the ability that was in the F slot.
		
		--The Invoke particle effect changes color depending on which orbs are invoked.
		local quas_particle_effect_color = Vector(60, 185, 255)
		local wex_particle_effect_color = Vector(195, 91, 201)
		local exort_particle_effect_color = Vector(244, 180, 40)
		
		local num_quas_orbs = 0
		local num_wex_orbs = 0
		local num_exort_orbs = 0
		for i=1, 3, 1 do
			if keys.caster.invoked_orbs[i]:GetName() == "invoker_retro_quas" then
				num_quas_orbs = num_quas_orbs + 1
			elseif keys.caster.invoked_orbs[i]:GetName() == "invoker_retro_wex" then
				num_wex_orbs = num_wex_orbs + 1
			elseif keys.caster.invoked_orbs[i]:GetName() == "invoker_retro_exort" then
				num_exort_orbs = num_exort_orbs + 1
			end
		end
		
		 --Set the Invoke particle effect's color depending on which orbs are invoked.
		ParticleManager:SetParticleControl(invoke_particle_effect, 2, ((quas_particle_effect_color * num_quas_orbs) + (wex_particle_effect_color * num_wex_orbs) + (exort_particle_effect_color * num_exort_orbs)) / 3)
		
		--Add the invoked spell depending on the order of the invoked orbs.
		if keys.caster.invoked_orbs[1]:GetName() == "invoker_retro_quas" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_quas" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Quas Quas Quas
					--Since Icy Path's cast range increases with the level of Quas, it is split up into 7 abilities.
					local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
					keys.caster:AddAbility("invoker_retro_icy_path_level_" .. quas_ability:GetLevel() .. "_quas")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Quas Quas Wex
					--Since Portal's cast range increases with the level of Quas, it is split up into 7 abilities.
					local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
					keys.caster:AddAbility("invoker_retro_portal_level_" .. quas_ability:GetLevel() .. "_quas")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Quas Quas Exort
					keys.caster:AddAbility("invoker_retro_frost_nova")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_wex" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Quas Wex Quas
					keys.caster:AddAbility("invoker_retro_betrayal")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Quas Wex Wex
					keys.caster:AddAbility("invoker_retro_tornado_blast")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Quas Wex Exort
					keys.caster:AddAbility("invoker_retro_levitation")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_exort" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Quas Exort Quas
					keys.caster:AddAbility("invoker_retro_power_word")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Quas Exort Wex
					keys.caster:AddAbility("invoker_retro_invisibility_aura")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Quas Exort Exort
					keys.caster:AddAbility("invoker_retro_shroud_of_flames")
				end
			end
		elseif keys.caster.invoked_orbs[1]:GetName() == "invoker_retro_wex" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_quas" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Wex Quas Quas
					keys.caster:AddAbility("invoker_retro_mana_burn")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Wex Quas Wex
					keys.caster:AddAbility("invoker_retro_emp")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Wex Quas Exort
					keys.caster:AddAbility("invoker_retro_soul_blast")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_wex" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Wex Wex Quas
					keys.caster:AddAbility("invoker_retro_telelightning")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Wex Wex Wex
					keys.caster:AddAbility("invoker_retro_shock")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Wex Wex Exort
					keys.caster:AddAbility("invoker_retro_arcane_arts")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_exort" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Wex Exort Quas
					keys.caster:AddAbility("invoker_retro_scout")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Wex Exort Wex
					keys.caster:AddAbility("invoker_retro_energy_ball")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Wex Exort Exort
					keys.caster:AddAbility("invoker_retro_lightning_shield")
				end
			end
		elseif keys.caster.invoked_orbs[1]:GetName() == "invoker_retro_exort" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_quas" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Exort Quas Quas
					keys.caster:AddAbility("invoker_retro_chaos_meteor")
					
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Exort Quas Wex
					keys.caster:AddAbility("invoker_retro_confuse")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Exort Quas Exort
					keys.caster:AddAbility("invoker_retro_disarm")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_wex" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Exort Wex Quas
					keys.caster:AddAbility("invoker_retro_soul_reaver")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Exort Wex Wex
					keys.caster:AddAbility("invoker_retro_firestorm")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Exort Wex Exort
					keys.caster:AddAbility("invoker_retro_incinerate")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_exort" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Exort Exort Quas
					keys.caster:AddAbility("invoker_retro_deafening_blast")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Exort Exort Wex
					keys.caster:AddAbility("invoker_retro_inferno")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Exort Exort Exort
					keys.caster:AddAbility("invoker_retro_firebolt")
				end
			end
		end
		
		--Put the newly invoked ability on cooldown if it should still have a remaining cooldown from the last time it was invoked.
		local new_spell_invoked = keys.caster:GetAbilityByIndex(3)
		if new_spell_invoked ~= nil then
			new_spell_invoked:SetLevel(1)
			
			local new_spell_invoked_name = new_spell_invoked:GetName()
			
			if string.sub(new_spell_invoked_name, 1, 22) == "invoker_retro_icy_path" then  --If one of the 7 Icy Path spells was invoked.
				new_spell_invoked_name = "invoker_retro_icy_path"
			elseif string.sub(new_spell_invoked_name, 1, 20) == "invoker_retro_portal" then  --If one of the 7 Portal spells was invoked.
				new_spell_invoked_name = "invoker_retro_portal"
			end

			if keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] ~= nil and keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name] ~= nil and keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] ~= 0 then
				local current_game_time = GameRules:GetGameTime() 
				if keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] + keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name] >= current_game_time then
					new_spell_invoked:StartCooldown(current_game_time - (keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] + keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name]))
				end
			end
		end
	end
end