--[[ ============================================================================================================
	Author: wFX
	Date: March 05, 2015
	Called when Soul Reaver is cast.
================================================================================================================= ]]
function invoker_retro_soul_reaver_on_spell_start(event)
	local damageTable = {
		victim = event.target,
		attacker = event.caster,
		damage = event.ability:GetLevelSpecialValueFor("initial_damage", event.caster:FindAbilityByName("invoker_retro_quas"):GetLevel()),
		damage_type = event.ability:GetAbilityDamageType()
	}
	ApplyDamage(damageTable)
	
	local secondary_damage = event.ability:GetLevelSpecialValueFor("after_damage", event.caster:FindAbilityByName("invoker_retro_exort"):GetLevel())
	event.ability:ApplyDataDrivenModifier(event.caster, event.caster, "modifier_invoker_retro_soul_reaver_movement_speed", {duration = 8})
	event.ability:ApplyDataDrivenModifier(event.caster, event.target, "modifier_invoker_retro_soul_reaver_damage", {duration = 8})	
	event.caster:SetModifierStackCount("modifier_invoker_retro_soul_reaver_movement_speed", event.ability, event.caster:FindAbilityByName("invoker_retro_wex"):GetLevel())
	
	local soul_reaver_speed_boost_particle_effect_beginning = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_soul_reaver_movement_speed_boost_begin.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.caster)
	
	Timers:CreateTimer({
		endTime = 8,
		callback = function()
			local damageTable = {
				victim = event.target,
				attacker = event.caster,
				damage = secondary_damage,
				damage_type = event.ability:GetAbilityDamageType()
			}
			ApplyDamage(damageTable)

		local soul_reaver_number = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_soul_reaver_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, event.target)
		ParticleManager:SetParticleControl(soul_reaver_number, 1, Vector(1, damageTable.damage, 0))
		ParticleManager:SetParticleControl(soul_reaver_number, 2, Vector(2, string.len(math.floor(damageTable.damage)) + 1, 0))
		end
	})
end