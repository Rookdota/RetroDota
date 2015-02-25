--[[
	Author: Rook and wFX
	Date: 23.02.2015.
	Adds invisibility to nearby units.
	Additional parameters: keys.FadeTime
]]
function modifier_invoker_retro_invisibility_aura_on_interval_think(keys)
	local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
	
	if keys.ability == nil then  --If Invisibility Aura is not invoked anymore.
		keys.caster:RemoveModifierByName("modifier_invoker_retro_invisibility_aura")
	elseif quas_ability ~= nil then
		local radius = keys.ability:GetLevelSpecialValueFor("radius", quas_ability:GetLevel() - 1)

		local nearby_ally_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

		for i, individual_unit in ipairs(nearby_ally_units) do
			if keys.caster ~= individual_unit then  --Invisibility Aura does not make Invoker invisible.
				if individual_unit:HasModifier("modifier_invoker_retro_invisibility_aura_effect") then  --Immediately apply the invis if the unit is already invis.
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_retro_invisibility_aura_effect", nil)
				else  --Apply the invis after the fade delay if the unit is not already invis.
					Timers:CreateTimer({
						endTime = keys.FadeTime,
						callback = function()
							keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_retro_invisibility_aura_effect", nil)
						end
					})
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called regularly while under the effects of Invisibility Aura.  Repeatedly apply the stock modifier_invisible
	for the sole purpose of making the unit have a transparent texture.  This can be gotten rid of when we discover
	how to apply a translucent texture manually.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_effect_on_interval_think(keys)
	keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_invisible", {duration = .1})
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called when Invisibility Aura is invoked.  Creates the aura particle effect around Invoker.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_on_created(keys)
	local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
	if quas_ability ~= nil then
		local radius = keys.ability:GetLevelSpecialValueFor("radius", quas_ability:GetLevel() - 1)

		local invisibility_aura_particle = ParticleManager:CreateParticle("particles/heroes/hero_invoker/invoker_retro_invisibility_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
		ParticleManager:SetParticleControl(invisibility_aura_particle, 1, Vector(radius, radius, radius))
		local invisibility_aura_circle_sprite_radius = radius * 1.276  --The circle's sprite extends outwards a bit, so make it slightly larger.
		ParticleManager:SetParticleControl(invisibility_aura_particle, 2, Vector(invisibility_aura_circle_sprite_radius, invisibility_aura_circle_sprite_radius, invisibility_aura_circle_sprite_radius))
		
		keys.caster.invisibility_aura_particle = invisibility_aura_particle
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called when Invisibility Aura is un-invoked.  Destroys the aura particle effect around Invoker.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_on_destroy(keys)
	if keys.caster.invisibility_aura_particle ~= nil then
		ParticleManager:DestroyParticle(keys.caster.invisibility_aura_particle, false)
		keys.caster.invisibility_aura_particle = nil
	end
end