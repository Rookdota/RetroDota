--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Removes the third-to-most-recent orb created (if applicable) to make room for the newest orb.
================================================================================================================= ]]
function invoker_remove_oldest_orb(keys)
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	
	--Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
	--placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
	--Therefore, the oldest orb is located in [1], and the newest is located in [3].
	if keys.caster.invoked_orbs[1] ~= nil then
		local orb_name = keys.caster.invoked_orbs[1]:GetName()
		if orb_name == "invoker_quas_retro" then
			keys.caster:RemoveModifierByName("modifier_invoker_quas_instance_retro")
		elseif orb_name == "invoker_wex_retro" then
			keys.caster:RemoveModifierByName("modifier_invoker_wex_instance_retro")
		elseif orb_name == "invoker_exort_retro" then
			keys.caster:RemoveModifierByName("modifier_invoker_exort_instance_retro")
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Quas, Wex, or Exort is upgraded.  Levels the effects of any currently existing orbs.
	Known bugs: Leveling up currently sometimes switches the order of the invoked orbs in the modifier bar (it should
		not switch the stored order of the orbs).
================================================================================================================= ]]
function invoker_orb_retro_on_upgrade(keys)
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end

	--Reapply all the orbs Invoker has out in order to benefit from the upgraded ability's level.  By reapplying all
	--three orb modifiers, they will maintain their order on the modifier bar (so long as all are removed before any
	--are reapplied, since ordering problems arise there are two of the same type of orb otherwise).
	while keys.caster:HasModifier("modifier_invoker_quas_instance_retro") do
		keys.caster:RemoveModifierByName("modifier_invoker_quas_instance_retro")
	end
	while keys.caster:HasModifier("modifier_invoker_wex_instance_retro") do
		keys.caster:RemoveModifierByName("modifier_invoker_wex_instance_retro")
	end
	while keys.caster:HasModifier("modifier_invoker_exort_instance_retro") do
		keys.caster:RemoveModifierByName("modifier_invoker_exort_instance_retro")
	end
	
	for i=1, 3, 1 do
		if keys.caster.invoked_orbs[i] ~= nil then
			local orb_name = keys.caster.invoked_orbs[i]:GetName()
			if orb_name == "invoker_quas_retro" then
				local quas_ability = keys.caster:FindAbilityByName("invoker_quas_retro")
				if quas_ability ~= nil then
					quas_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_quas_instance_retro", nil)
				end
			elseif orb_name == "invoker_wex_retro" then
				local wex_ability = keys.caster:FindAbilityByName("invoker_wex_retro")
				if wex_ability ~= nil then
					wex_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_wex_instance_retro", nil)
				end
			elseif orb_name == "invoker_exort_retro" then
				local exort_ability = keys.caster:FindAbilityByName("invoker_exort_retro")
				if exort_ability ~= nil then
					exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_exort_instance_retro", nil)
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Quas is cast.
================================================================================================================= ]]
function invoker_quas_retro_on_spell_start(keys)
	invoker_remove_oldest_orb(keys)
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_quas_instance_retro", nil)
	
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Wex is cast.
================================================================================================================= ]]
function invoker_wex_retro_on_spell_start(keys)
	invoker_remove_oldest_orb(keys)
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_wex_instance_retro", nil)
	
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Exort is cast.
================================================================================================================= ]]
function invoker_exort_retro_on_spell_start(keys)
	invoker_remove_oldest_orb(keys)
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_exort_instance_retro", nil)
	
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Invoke is cast.  Stores cooldown information for the ability that was bound to D, and adds a new
	ability bound to F based on the order of the orbs around Invoker.
================================================================================================================= ]]
function invoker_invoke_retro_on_spell_start(keys)
	keys.caster:EmitSound("Hero_Invoker.Invoke")

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
	
	--Add the invoked spell depending on the order of the invoked orbs.
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	if keys.caster.invoked_orbs[1] ~= nil and keys.caster.invoked_orbs[2] ~= nil and keys.caster.invoked_orbs[3] ~= nil then  --If three orbs have not been summoned, no spell will be invoked.
		if keys.caster.invoked_orbs[1]:GetName() == "invoker_quas_retro" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_quas_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Quas Quas Quas
					keys.caster:AddAbility("invoker_icy_path_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Quas Quas Wex
					keys.caster:AddAbility("invoker_portal_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Quas Quas Exort
					keys.caster:AddAbility("invoker_frost_nova_retro")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_wex_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Quas Wex Quas
					keys.caster:AddAbility("invoker_betrayal_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Quas Wex Wex
					keys.caster:AddAbility("invoker_tornado_blast_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Quas Wex Exort
					keys.caster:AddAbility("invoker_levitation_retro")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_exort_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Quas Exort Quas
					keys.caster:AddAbility("invoker_power_word_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Quas Exort Wex
					keys.caster:AddAbility("invoker_invisibility_aura_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Quas Exort Exort
					keys.caster:AddAbility("invoker_shroud_of_flame_retro")
				end
			end
		elseif keys.caster.invoked_orbs[1]:GetName() == "invoker_wex_retro" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_quas_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Wex Quas Quas
					keys.caster:AddAbility("invoker_mana_burn_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Wex Quas Wex
					keys.caster:AddAbility("invoker_emp_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Wex Quas Exort
					keys.caster:AddAbility("invoker_soul_blast_retro")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_wex_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Wex Wex Quas
					keys.caster:AddAbility("invoker_telelightning_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Wex Wex Wex
					keys.caster:AddAbility("invoker_shock_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Wex Wex Exort
					keys.caster:AddAbility("invoker_arcane_arts_retro")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_exort_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Wex Exort Quas
					keys.caster:AddAbility("invoker_scout_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Wex Exort Wex
					keys.caster:AddAbility("invoker_energy_ball_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Wex Exort Exort
					keys.caster:AddAbility("invoker_lightning_shield_retro")
				end
			end
		elseif keys.caster.invoked_orbs[1]:GetName() == "invoker_exort_retro" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_quas_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Exort Quas Quas
					keys.caster:AddAbility("invoker_chaos_meteor_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Exort Quas Wex
					keys.caster:AddAbility("invoker_confuse_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Exort Quas Exort
					keys.caster:AddAbility("invoker_disarm_retro")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_wex_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Exort Wex Quas
					keys.caster:AddAbility("invoker_soul_reaver_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Exort Wex Wex
					keys.caster:AddAbility("invoker_firestorm_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Exort Wex Exort
					keys.caster:AddAbility("invoker_incinerate_retro")
				end
			elseif keys.caster.invoked_orbs[2]:GetName() == "invoker_exort_retro" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_quas_retro" then  --Exort Exort Quas
					keys.caster:AddAbility("invoker_deafening_blast_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_wex_retro" then  --Exort Exort Wex
					keys.caster:AddAbility("invoker_inferno_retro")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_exort_retro" then  --Exort Exort Exort
					keys.caster:AddAbility("invoker_firebolt_retro")
				end
			end
		end
	end
	
	--Put the newly invoked ability on cooldown if it should still have a remaining cooldown from the last time it was invoked.
	local new_ability_f = keys.caster:GetAbilityByIndex(5)
	if new_ability_f ~= nil then
		local new_ability_f_name = new_ability_f:GetName()
		if keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] ~= nil and keys.caster.invoke_ability_gametime_removed[new_ability_f_name] ~= nil and keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] ~= 0 then
			local current_game_time = GameRules:GetGameTime() 
			if keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] + keys.caster.invoke_ability_gametime_removed[new_ability_f_name] >= current_game_time then
				new_ability_f:StartCooldown(current_game_time - (keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] + keys.caster.invoke_ability_gametime_removed[new_ability_f_name]))
			end
		end
	end
end