--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Invoke is cast.  Stores cooldown information for the ability that was bound to D, and adds a new
	ability bound to F based on the order of the orbs around Invoker.
================================================================================================================= ]]
function invoker_retro_invoke_on_spell_start(keys)
	keys.caster:EmitSound("Hero_Invoker.Invoke")

	if keys.caster.invoke_ability_cooldown_remaining == nil then
		keys.caster.invoke_ability_cooldown_remaining = {}
	end
	if keys.caster.invoke_ability_gametime_removed == nil then
		keys.caster.invoke_ability_gametime_removed = {}
	end
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	
	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)  --Play the particle effect.
	
	if keys.caster.invoked_orbs[1] ~= nil and keys.caster.invoked_orbs[2] ~= nil and keys.caster.invoked_orbs[3] ~= nil then  --A spell will be invoked only if three orbs have been summoned.
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
		
		local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
		local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
		local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
		
		local ability_d = keys.caster:GetAbilityByIndex(3)
		local ability_d_name = ability_d:GetName()
		
		--Add the invoked spell depending on the order of the invoked orbs.
		if keys.caster.invoked_orbs[1]:GetName() == "invoker_retro_quas" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_quas" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Quas Quas Quas
					local spell_name_to_invoke = "invoker_retro_icy_path_level_" .. quas_ability:GetLevel() .. "_quas"
					if not string.find(ability_d_name, "invoker_retro_icy_path") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local icy_path_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						icy_path_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Quas Quas Wex
					local spell_name_to_invoke = "invoker_retro_portal_level_" .. quas_ability:GetLevel() .. "_quas"
					if not string.find(ability_d_name, "invoker_retro_portal") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local portal_ability = keys.caster:FindAbilityByName()
						portal_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Quas Quas Exort
					local spell_name_to_invoke = "invoker_retro_frost_nova"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local frost_nova_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						frost_nova_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_wex" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Quas Wex Quas
					local spell_name_to_invoke = "invoker_retro_betrayal"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local betrayal_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						betrayal_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Quas Wex Wex
					local spell_name_to_invoke = "invoker_retro_tornado_blast_level_" .. quas_ability:GetLevel() .. "_quas"
					if not string.find(ability_d_name, "invoker_retro_tornado_blast") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local tornado_blast_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						tornado_blast_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Quas Wex Exort
					local spell_name_to_invoke = "invoker_retro_levitation"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local levitation_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						--Set Levitation's level to the average level of Quas, Wex, and Exort.
						local average_level = (quas_ability:GetLevel() + wex_ability:GetLevel() + exort_ability:GetLevel()) / 3
						average_level = math.floor(average_level + .5)  --Round to the nearest integer.
						
						--Ensure that the average level is in-bounds, just in case.
						if average_level < 1 then
							average_level = 1
						end
						if average_level > 8 then
							average_level = 8
						end
						
						levitation_ability:SetLevel(average_level)
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_exort" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Quas Exort Quas
					local spell_name_to_invoke = "invoker_retro_power_word"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local power_word_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						power_word_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Quas Exort Wex
					local spell_name_to_invoke = "invoker_retro_invisibility_aura"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local invisibility_aura_ability = keys.caster:FindAbilityByName("invoker_retro_invisibility_aura")
						invisibility_aura_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Quas Exort Exort
					local spell_name_to_invoke = "invoker_retro_shroud_of_flames_exort" .. exort_ability:GetLevel()
					if not string.find(ability_d_name, "invoker_retro_shroud_of_flames") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local shroud_of_flames_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						shroud_of_flames_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			end
		elseif keys.caster.invoked_orbs[1]:GetName() == "invoker_retro_wex" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_quas" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Wex Quas Quas
					local spell_name_to_invoke = "invoker_retro_mana_burn"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local mana_burn_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						mana_burn_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Wex Quas Wex
					local spell_name_to_invoke = "invoker_retro_emp"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)

						local emp_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						--Set Levitation's level to the average level of Quas and Wex.
						local average_level = (quas_ability:GetLevel() + wex_ability:GetLevel()) / 2
						average_level = math.floor(average_level + .5)  --Round to the nearest integer.
						
						--Ensure that the average level is in-bounds, just in case.
						if average_level < 1 then
							average_level = 1
						end
						if average_level > 8 then
							average_level = 8
						end
						
						emp_ability:SetLevel(average_level)
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Wex Quas Exort
					local spell_name_to_invoke = "invoker_retro_soul_blast_level_" .. wex_ability:GetLevel() .. "_wex"
					if not string.find(ability_d_name, "invoker_retro_soul_blast") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local soul_blast_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						soul_blast_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_wex" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Wex Wex Quas
					local spell_name_to_invoke = "invoker_retro_telelightning_level_" .. wex_ability:GetLevel() .. "_wex"
					if not string.find(ability_d_name, "invoker_retro_telelightning") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local telelightning_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						telelightning_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Wex Wex Wex
					local spell_name_to_invoke = "invoker_retro_shock"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local shock_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						shock_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Wex Wex Exort
					local spell_name_to_invoke = "invoker_retro_arcane_arts"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local arcane_arts_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						arcane_arts_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_exort" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Wex Exort Quas
					local spell_name_to_invoke = "invoker_retro_scout"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local scout_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						scout_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Wex Exort Wex
					local spell_name_to_invoke = "invoker_retro_energy_ball"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local energy_ball_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						energy_ball_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Wex Exort Exort
					local spell_name_to_invoke = "invoker_retro_lightning_shield"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local lightning_shield_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						lightning_shield_ability:SetLevel(wex_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			end
		elseif keys.caster.invoked_orbs[1]:GetName() == "invoker_retro_exort" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_quas" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Exort Quas Quas
					local spell_name_to_invoke = "invoker_retro_chaos_meteor"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local chaos_meteor_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						chaos_meteor_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Exort Quas Wex
					local spell_name_to_invoke = "invoker_retro_confuse_level_" .. exort_ability:GetLevel() .. "_exort"
					if not string.find(ability_d_name, "invoker_retro_confuse") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local confuse_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						confuse_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Exort Quas Exort
					local spell_name_to_invoke = "invoker_retro_disarm_level_" .. exort_ability:GetLevel().."_exort"
					if not string.find(ability_d_name, "invoker_retro_disarm") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local disarm_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						disarm_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_wex" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Exort Wex Quas
					local spell_name_to_invoke = "invoker_retro_soul_reaver"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local soul_reaver_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						soul_reaver_ability:SetLevel(quas_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Exort Wex Wex
					local spell_name_to_invoke = "invoker_retro_firestorm"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local firestorm_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						firestorm_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Exort Wex Exort
					local spell_name_to_invoke = "invoker_retro_incinerate_level_" .. exort_ability:GetLevel() .. "_exort"
					if not string.find(ability_d_name, "invoker_retro_incinerate") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local incinerate_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						incinerate_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_exort" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Exort Exort Quas
					local spell_name_to_invoke = "invoker_retro_deafening_blast"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local deafening_blast_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						deafening_blast_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Exort Exort Wex
					local spell_name_to_invoke = "invoker_retro_inferno_level_" .. wex_ability:GetLevel() .. "_wex"
					if not string.find(ability_d_name, "invoker_retro_inferno") then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local inferno_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						inferno_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_exort" then  --Exort Exort Exort
					local spell_name_to_invoke = "invoker_retro_firebolt"
					if ability_d_name ~= spell_name_to_invoke then
						invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
						keys.caster:AddAbility(spell_name_to_invoke)
						local firebolt_ability = keys.caster:FindAbilityByName(spell_name_to_invoke)
						firebolt_ability:SetLevel(exort_ability:GetLevel())
						invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
					end
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: March 22, 2015
	A helper function for when Invoke is cast and Invoker does not have the spell that he's attempting to invoke in
	slot D already.  Removes the old spell and shifts the D spell over to the F slot if Invoker is allowed to have
	2 spells invoked.
================================================================================================================= ]]
function invoker_retro_invoke_on_spell_start_spell_remover_helper(keys, spell_name_to_invoke)
	--Since cooldowns are tied to the ability but we don't have room to keep all the abilities on Invoker due to the
	--limited number of slots, keep track of the gametime of when abilities were last cast, which we can use to determine
	--if invoked spells should still be on cooldown from when they were last used.
	
	local ability_index_to_remove = 3
	if GameRules.invoke_slots == "2" or GameRules.invoke_slots == 2 then  --Handle removing the spell in the F slot if Invoker is set to have 2 invoked spells.
		ability_index_to_remove = 4
	end
	
	local old_spell_invoked = keys.caster:GetAbilityByIndex(ability_index_to_remove)
	local old_spell_invoked_name = old_spell_invoked:GetName()
	local old_spell_invoked_index_name = old_spell_invoked_name
	
	if string.find(old_spell_invoked_index_name, "invoker_retro_icy_path") then  --If one of the 8 Icy Path spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_icy_path"
	elseif string.find(old_spell_invoked_index_name, "invoker_retro_portal") then  --If one of the 8 Portal spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_portal"
	elseif string.find(old_spell_invoked_index_name, "invoker_retro_tornado_blast") then  --If one of the 8 Tornado Blast spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_tornado_blast"
	elseif string.find(old_spell_invoked_index_name, "invoker_retro_soul_blast") then  --If one of the 8 Soul Blast spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_soul_blast"
	elseif string.find(old_spell_invoked_index_name, "invoker_retro_confuse") then  --If one of the 8 Confuse spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_confuse"
	elseif string.find(old_spell_invoked_index_name, "invoker_retro_inferno") then  --If one of the 8 Inferno spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_inferno"
	elseif string.find(old_spell_invoked_index_name, "invoker_retro_incinerate") then  --If one of the 8 Incinerate spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_incinerate"
	elseif string.find(old_spell_invoked_index_name, "invoker_retro_shroud_of_flames") then  --If one of the 8 Shroud of Flames spells was invoked.
		old_spell_invoked_index_name = "invoker_retro_shroud_of_flames"
	end
	
	--Update keys.caster.invoke_ability_cooldown_remaining[ability_name] of the ability to be removed, so cooldowns can be tracked.
	--We cannot just store the gametime because the ability's maximum cooldown may have changed due to leveling up Invoker's orbs
	--by the time the ability is reinvoked.  Therefore, keys.caster.invoke_ability_gametime_removed[ability_name] is also stored.
	--Items like Refresher Orb should clear this list.
	keys.caster.invoke_ability_cooldown_remaining[old_spell_invoked_index_name] = old_spell_invoked:GetCooldownTimeRemaining()
	keys.caster.invoke_ability_gametime_removed[old_spell_invoked_index_name] = GameRules:GetGameTime() 
	
	keys.caster:RemoveAbility(old_spell_invoked_name)  --Remove the ability that is supposed to be entirely removed.

	--Remove passive modifiers attached to the ability that was previously invoked.
	if string.find(old_spell_invoked_name, "invoker_retro_arcane_arts") then
		keys.caster:RemoveModifierByName("modifier_invoker_retro_arcane_arts")
	elseif string.find(old_spell_invoked_name, "invoker_retro_invisibility_aura") then
		keys.caster:RemoveModifierByName("modifier_invoker_retro_invisibility_aura")
	end
	
	if GameRules.invoke_slots == "2" or GameRules.invoke_slots == 2 then  --If Invoker can have two spells invoked, shift the ability in the D slot over to the F slot.
		local ability_d = keys.caster:GetAbilityByIndex(3)
		local ability_d_name = ability_d:GetName()
		local ability_d_current_cooldown = ability_d:GetCooldownTimeRemaining()
		local ability_d_current_level = ability_d:GetLevel()
		
		keys.caster:RemoveAbility(ability_d_name)
		
		keys.caster:AddAbility("invoker_retro_empty_slot_1")
		keys.caster:AddAbility(ability_d_name)  --This will place the ability that was bound to D in the F slot.
		keys.caster:RemoveAbility("invoker_retro_empty_slot_1")
		
		local new_ability_f = keys.caster:FindAbilityByName(ability_d_name)
		new_ability_f:SetLevel(ability_d_current_level)
		new_ability_f:StartCooldown(ability_d_current_cooldown)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: March 22, 2015
	A helper function for when Invoke is cast and a new spell has been invoked.  Sets the cooldown of the newly
	invoked spell.
================================================================================================================= ]]
function invoker_retro_invoke_on_spell_start_new_spell_cooldown_helper(keys)
	--Put the newly invoked ability on cooldown if it should still have a remaining cooldown from the last time it was invoked.
	local new_spell_invoked = keys.caster:GetAbilityByIndex(3)
	if new_spell_invoked ~= nil then
		if new_spell_invoked:GetLevel() == 0 then
			new_spell_invoked:SetLevel(1)
		end
		
		local new_spell_invoked_name = new_spell_invoked:GetName()
		
		if string.find(new_spell_invoked_name, "invoker_retro_icy_path") then  --If one of the 8 Icy Path spells was invoked.
			new_spell_invoked_name = "invoker_retro_icy_path"
		elseif string.find(new_spell_invoked_name, "invoker_retro_portal") then  --If one of the 8 Portal spells was invoked.
			new_spell_invoked_name = "invoker_retro_portal"
		elseif string.find(new_spell_invoked_name, "invoker_retro_tornado_blast") then  --If one of the 8 Tornado Blast spells was invoked.
			new_spell_invoked_name = "invoker_retro_tornado_blast"
		elseif string.find(new_spell_invoked_name, "invoker_retro_soul_blast") then  --If one of the 8 Soul Blast spells was invoked.
			new_spell_invoked_name = "invoker_retro_soul_blast"
		elseif string.find(new_spell_invoked_name, "invoker_retro_confuse") then  --If one of the 8 Confuse spells was invoked.
			new_spell_invoked_name = "invoker_retro_confuse"
		elseif string.find(new_spell_invoked_name, "invoker_retro_inferno") then  --If one of the 8 Inferno spells was invoked.
			new_spell_invoked_name = "invoker_retro_inferno"
		elseif string.find(new_spell_invoked_name, "invoker_retro_incinerate") then  --If one of the 8 Incinerate spells was invoked.
			new_spell_invoked_name = "invoker_retro_incinerate"
		elseif string.find(new_spell_invoked_name, "invoker_retro_shroud_of_flames") then  --If one of the 8 Shroud of Flames spells was invoked.
			new_spell_invoked_name = "invoker_retro_shroud_of_flames"
		end

		if keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] ~= nil and keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name] ~= nil and keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] ~= 0 then
			local current_game_time = GameRules:GetGameTime()
			if keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] + keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name] >= current_game_time then
				new_spell_invoked:StartCooldown(current_game_time - (keys.caster.invoke_ability_cooldown_remaining[new_spell_invoked_name] + keys.caster.invoke_ability_gametime_removed[new_spell_invoked_name]))
			else
				new_spell_invoked:EndCooldown()
			end
		else
			new_spell_invoked:EndCooldown()
		end
	end
end