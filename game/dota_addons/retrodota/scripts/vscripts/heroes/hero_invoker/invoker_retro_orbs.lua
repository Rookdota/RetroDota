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
	Called when Quas, Wex, or Exort is cast or upgraded.  Replaces the modifiers on the caster's modifier bar to
	ensure the correct order, which also has the effect of leveling the effects of any currently existing orbs.
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
					--Timers:CreateTimer({
					--	endTime = .03 * i,
					--	callback = function()
							quas_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_quas_instance", nil)
							print(i .. " = quas")
					--	end
					--})
				end
			elseif orb_name == "invoker_retro_wex" then
				local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
				if wex_ability ~= nil then
					--Timers:CreateTimer({
						--endTime = .03 * i,
						--callback = function()
							wex_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_wex_instance", nil)
							print(i .. " = wex")
						--end
					--})
				end
			elseif orb_name == "invoker_retro_exort" then
				local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
				if exort_ability ~= nil then
					--Timers:CreateTimer({
					--	endTime = .03 * i,
					--	callback = function()
							exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_exort_instance", nil)
							print(i .. " = exort")
					--	end
					--})
				end
			end
		end
	end
	print("")
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 18, 2015
	Called when Quas, Wex, or Exort is upgraded.  Makes sure the correct invoked spell is still being used.
================================================================================================================= ]]
function invoker_retro_orb_maintain_invoked_spells(keys)
	--Some spells have seven different versions (one for each level of a reagent).  If one of these is currently invoked, make sure it is the correct version, given the reagent's level.
	local current_invoked_spell = keys.caster:GetAbilityByIndex(3)
	if current_invoked_spell ~= nil then
		local current_invoked_spell_name = current_invoked_spell:GetName()
		
		local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
		local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
		local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
		
		if string.find(current_invoked_spell_name, "invoker_retro_icy_path") then  --If one of the 8 Icy Path spells is invoked, swap it out for the correct version based on Quas' level.
			local current_invoked_spell_cooldown = current_invoked_spell:GetCooldownTimeRemaining()
			keys.caster:RemoveAbility(current_invoked_spell_name)
			local new_invoked_spell_name = "invoker_retro_icy_path_level_" .. quas_ability:GetLevel() .. "_quas"
			keys.caster:AddAbility(new_invoked_spell_name)
			local new_invoked_spell = keys.caster:FindAbilityByName(new_invoked_spell_name)
			new_invoked_spell:StartCooldown(current_invoked_spell_cooldown)
			new_invoked_spell:SetLevel(quas_ability:GetLevel())  --Level up the ability for tooltip purposes.
		elseif string.find(current_invoked_spell_name, "invoker_retro_portal") then  --If one of the 8 Portal spells is invoked, swap it out for the correct version based on Quas' level.
			local current_invoked_spell_cooldown = current_invoked_spell:GetCooldownTimeRemaining()
			keys.caster:RemoveAbility(current_invoked_spell_name)
			local new_invoked_spell_name = "invoker_retro_portal_level_" .. quas_ability:GetLevel() .. "_quas"
			keys.caster:AddAbility(new_invoked_spell_name)
			local new_invoked_spell = keys.caster:FindAbilityByName(new_invoked_spell_name)
			new_invoked_spell:StartCooldown(current_invoked_spell_cooldown)
			new_invoked_spell:SetLevel(1)
		elseif string.find(current_invoked_spell_name, "invoker_retro_tornado_blast") then  --If one of the 8 Tornado Blast spells is invoked, swap it out for the correct version based on Quas' level.
			local current_invoked_spell_cooldown = current_invoked_spell:GetCooldownTimeRemaining()
			keys.caster:RemoveAbility(current_invoked_spell_name)
			local new_invoked_spell_name = "invoker_retro_tornado_blast_level_" .. quas_ability:GetLevel() .. "_quas"
			keys.caster:AddAbility(new_invoked_spell_name)
			local new_invoked_spell = keys.caster:FindAbilityByName(new_invoked_spell_name)
			new_invoked_spell:StartCooldown(current_invoked_spell_cooldown)
			new_invoked_spell:SetLevel(quas_ability:GetLevel())  --Level up the ability for tooltip purposes.
		elseif string.find(current_invoked_spell_name, "invoker_retro_disarm") then  --If one of the 8 Disarm spells is invoked, swap it out for the correct version based on Exort' level.
			local current_invoked_spell_cooldown = current_invoked_spell:GetCooldownTimeRemaining()
			keys.caster:RemoveAbility(current_invoked_spell_name)
			local new_invoked_spell_name = "invoker_retro_disarm_level_" .. exort_ability:GetLevel() .. "_exort"
			keys.caster:AddAbility(new_invoked_spell_name)
			local new_invoked_spell = keys.caster:FindAbilityByName(new_invoked_spell_name)
			new_invoked_spell:StartCooldown(current_invoked_spell_cooldown)
			new_invoked_spell:SetLevel(exort_ability:GetLevel())  --Level up the ability for tooltip purposes.
		elseif string.find(current_invoked_spell_name, "invoker_retro_invisibility_aura") then  --If Invisibility Aura is invoked, increase the particle effect to match the new radius.
			local radius = current_invoked_spell:GetLevelSpecialValueFor("radius", quas_ability:GetLevel() - 1)
			
			if keys.caster.invisibility_aura_particle ~= nil then
				ParticleManager:DestroyParticle(keys.caster.invisibility_aura_particle, false)
				keys.caster.invisibility_aura_particle = nil
			end
			
			local invisibility_aura_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_invisibility_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
			ParticleManager:SetParticleControl(invisibility_aura_particle, 1, Vector(radius, radius, radius))
			local invisibility_aura_circle_sprite_radius = radius * 1.276  --The circle's sprite extends outwards a bit, so make it slightly larger.
			ParticleManager:SetParticleControl(invisibility_aura_particle, 2, Vector(invisibility_aura_circle_sprite_radius, invisibility_aura_circle_sprite_radius, invisibility_aura_circle_sprite_radius))
			
			keys.caster.invisibility_aura_particle = invisibility_aura_particle
			
			current_invoked_spell:SetLevel(quas_ability:GetLevel())
		elseif string.find(current_invoked_spell_name, "invoker_retro_arcane_arts") then
			current_invoked_spell:SetLevel(wex_ability:GetLevel())
		elseif string.find(current_invoked_spell_name, "invoker_retro_power_word") then
			current_invoked_spell:SetLevel(quas_ability:GetLevel())
		elseif string.find(current_invoked_spell_name, "invoker_retro_mana_burn") then
			current_invoked_spell:SetLevel(wex_ability:GetLevel())
		elseif string.find(current_invoked_spell_name, "invoker_retro_scout") then
			current_invoked_spell:SetLevel(wex_ability:GetLevel())
		elseif string.find(current_invoked_spell_name, "invoker_retro_shroud_of_flames") then  --If one of the 8 Shroud of Flames spells is invoked, swap it out for the correct version based on Exort' level.
			local current_invoked_spell_cooldown = current_invoked_spell:GetCooldownTimeRemaining()
			keys.caster:RemoveAbility(current_invoked_spell_name)
			local new_invoked_spell_name = "invoker_retro_shroud_of_flames_exort"..exort_ability:GetLevel()
			keys.caster:AddAbility(new_invoked_spell_name)
			local new_invoked_spell = keys.caster:FindAbilityByName(new_invoked_spell_name)
			new_invoked_spell:StartCooldown(current_invoked_spell_cooldown)
			new_invoked_spell:SetLevel(quas_ability:GetLevel()) -- The leveling of the ability reflects the Quas Level. Exort level is done with lua and shown with tooltip manipulation.
		elseif string.find(current_invoked_spell_name, "invoker_retro_soul_blast") then  --If one of the 8 Soul Blast spells is invoked, swap it out for the correct version based on Wex' level.
			local current_invoked_spell_cooldown = current_invoked_spell:GetCooldownTimeRemaining()
			keys.caster:RemoveAbility(current_invoked_spell_name)
			local new_invoked_spell_name = "invoker_retro_soul_blast_level_" .. wex_ability:GetLevel() .. "_wex"
			keys.caster:AddAbility(new_invoked_spell_name)
			local new_invoked_spell = keys.caster:FindAbilityByName(new_invoked_spell_name)
			new_invoked_spell:StartCooldown(current_invoked_spell_cooldown)
			new_invoked_spell:SetLevel(wex_ability:GetLevel())  --Level up the ability for tooltip purposes.
		elseif string.find(current_invoked_spell_name, "invoker_retro_confuse") then  --If one of the 8 Confuse spells is invoked, swap it out for the correct version based on Exort' level.
			local current_invoked_spell_cooldown = current_invoked_spell:GetCooldownTimeRemaining()
			keys.caster:RemoveAbility(current_invoked_spell_name)
			local new_invoked_spell_name = "invoker_retro_confuse_level_" .. exort_ability:GetLevel() .. "_exort"
			keys.caster:AddAbility(new_invoked_spell_name)
			local new_invoked_spell = keys.caster:FindAbilityByName(new_invoked_spell_name)
			new_invoked_spell:StartCooldown(current_invoked_spell_cooldown)
			new_invoked_spell:SetLevel(exort_ability:GetLevel())  --Level up the ability for tooltip purposes.
		elseif string.find(current_invoked_spell_name, "invoker_retro_chaos_meteor") then
			current_invoked_spell:SetLevel(exort_ability:GetLevel())
		elseif string.find(current_invoked_spell_name, "invoker_retro_betrayal") then
			current_invoked_spell:SetLevel(quas_ability:GetLevel())
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