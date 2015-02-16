--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Removes the third-to-most-recent orb created (if applicable) to make room for the newest orb.
================================================================================================================= ]]
function invoker_retro_replace_orb(keys, particle_filepath)
	--Initialization, if not already done.
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	if keys.caster.invoked_orbs_particle == nil then
		keys.caster.invoked_orbs_particle = {}
	end
	if keys.caster.invoked_orbs_particle_attach == nil then
		keys.caster.invoked_orbs_particle_attach = {}
		keys.caster.invoked_orbs_particle_attach[1] = "attach_orb1"
		keys.caster.invoked_orbs_particle_attach[2] = "attach_orb2"
		keys.caster.invoked_orbs_particle_attach[3] = "attach_orb3"
	end
	
	--Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
	--placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
	--Therefore, the oldest orb is located in [1], and the newest is located in [3].
	--Shift the ordered list of currently summoned orbs down.
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
	
	--Remove the removed orb's particle effect.
	if keys.caster.invoked_orbs_particle[1] ~= nil then
		ParticleManager:DestroyParticle(keys.caster.invoked_orbs_particle[1], false)
		keys.caster.invoked_orbs_particle[1] = nil
	end
	
	--Shift the ordered list of currently summoned orb particle effects down, and create the new particle.
	keys.caster.invoked_orbs_particle[1] = keys.caster.invoked_orbs_particle[2]
	keys.caster.invoked_orbs_particle[2] = keys.caster.invoked_orbs_particle[3]
	keys.caster.invoked_orbs_particle[3] = ParticleManager:CreateParticle(particle_filepath, PATTACH_OVERHEAD_FOLLOW, keys.caster)
	ParticleManager:SetParticleControlEnt(keys.caster.invoked_orbs_particle[3], 1, keys.caster, PATTACH_POINT_FOLLOW, keys.caster.invoked_orbs_particle_attach[1], keys.caster:GetAbsOrigin(), false)
	
	--Shift the ordered list of currently summoned orb particle effect attach locations down.
	local temp_attachment_point = keys.caster.invoked_orbs_particle_attach[1]
	keys.caster.invoked_orbs_particle_attach[1] = keys.caster.invoked_orbs_particle_attach[2]
	keys.caster.invoked_orbs_particle_attach[2] = keys.caster.invoked_orbs_particle_attach[3]
	keys.caster.invoked_orbs_particle_attach[3] = temp_attachment_point
	
	invoker_retro_orb_replace_modifiers(keys)  --Remove and reapply the orb instance modifiers.
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Quas, Wex, or Exort is upgraded.  Levels the effects of any currently existing orbs.
================================================================================================================= ]]
function invoker_retro_orb_replace_modifiers(keys)
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end

	--Reapply all the orbs Invoker has out in order to benefit from the upgraded ability's level.  By reapplying all
	--three orb modifiers, they will maintain their order on the modifier bar (so long as all are removed before any
	--are reapplied, since ordering problems arise there are two of the same type of orb otherwise).
	while keys.caster:HasModifier("modifier_invoker_retro_quas_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_retro_quas_instance")
	end
	while keys.caster:HasModifier("modifier_invoker_retro_wex_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_retro_wex_instance")
	end
	while keys.caster:HasModifier("modifier_invoker_retro_exort_instance") do
		keys.caster:RemoveModifierByName("modifier_invoker_retro_exort_instance")
	end
	
	for i=1, 3, 1 do
		if keys.caster.invoked_orbs[i] ~= nil then
			local orb_name = keys.caster.invoked_orbs[i]:GetName()
			if orb_name == "invoker_retro_quas" then
				local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
				if quas_ability ~= nil then
					quas_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_quas_instance", nil)
				end
			elseif orb_name == "invoker_retro_wex" then
				local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
				if wex_ability ~= nil then
					wex_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_wex_instance", nil)
				end
			elseif orb_name == "invoker_retro_exort" then
				local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
				if exort_ability ~= nil then
					exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_exort_instance", nil)
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
function invoker_retro_quas_on_spell_start(keys)
	invoker_retro_replace_orb(keys, "particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf")
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Wex is cast.
================================================================================================================= ]]
function invoker_retro_wex_on_spell_start(keys)
	invoker_retro_replace_orb(keys, "particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf")
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Exort is cast.
================================================================================================================= ]]
function invoker_retro_exort_on_spell_start(keys)
	invoker_retro_replace_orb(keys, "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf")
end


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
	local old_spell_invoked = keys.caster:GetAbilityByIndex(5)
	local old_spell_invoked_name = old_spell_invoked:GetName()
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
	keys.caster.invoke_ability_cooldown_remaining[old_spell_invoked_name] = old_spell_invoked:GetCooldownTimeRemaining()
	keys.caster.invoke_ability_gametime_removed[old_spell_invoked_name] = GameRules:GetGameTime() 
	
	--Remove the ability that was in the F slot.
	keys.caster:RemoveAbility(old_spell_invoked_name)
	
	--Add the invoked spell depending on the order of the invoked orbs.
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	if keys.caster.invoked_orbs[1] ~= nil and keys.caster.invoked_orbs[2] ~= nil and keys.caster.invoked_orbs[3] ~= nil then  --If three orbs have not been summoned, no spell will be invoked.
		if keys.caster.invoked_orbs[1]:GetName() == "invoker_retro_quas" then
			if keys.caster.invoked_orbs[2]:GetName() == "invoker_retro_quas" then
				if keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_quas" then  --Quas Quas Quas
					keys.caster:AddAbility("invoker_retro_icy_path")
				elseif keys.caster.invoked_orbs[3]:GetName() == "invoker_retro_wex" then  --Quas Quas Wex
					keys.caster:AddAbility("invoker_retro_portal")
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
	end
	
	--Put the newly invoked ability on cooldown if it should still have a remaining cooldown from the last time it was invoked.
	local new_ability_f = keys.caster:GetAbilityByIndex(5)
	if new_ability_f ~= nil then
		new_ability_f:SetLevel(1)
		
		local new_ability_f_name = new_ability_f:GetName()
		if keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] ~= nil and keys.caster.invoke_ability_gametime_removed[new_ability_f_name] ~= nil and keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] ~= 0 then
			local current_game_time = GameRules:GetGameTime() 
			if keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] + keys.caster.invoke_ability_gametime_removed[new_ability_f_name] >= current_game_time then
				new_ability_f:StartCooldown(current_game_time - (keys.caster.invoke_ability_cooldown_remaining[new_ability_f_name] + keys.caster.invoke_ability_gametime_removed[new_ability_f_name]))
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Icy Wall is cast.
	Additional parameters: keys.NumWallElements, keys.WallElementSpacing, and keys.WallElementRadius
================================================================================================================= ]]
function invoker_retro_icy_wall_on_spell_start(keys)
	
end