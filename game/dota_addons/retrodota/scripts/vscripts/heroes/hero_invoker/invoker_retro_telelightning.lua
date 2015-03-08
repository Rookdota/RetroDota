--[[ ============================================================================================================
	Author: wFX
	Date: March 05, 2015
	Called when Telelightning is cast.
================================================================================================================= ]]
function invoker_retro_telelightning_on_spell_start(event)

	local caster = event.caster
	local ability = event.ability
	local wex_ability = caster:FindAbilityByName("invoker_retro_wex")
	local target = event.target

	local particle = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf",PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z))
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z))

	target:EmitSound("Hero_Zuus.ArcLightning")
	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ability:GetLevelSpecialValueFor("damage", wex_ability:GetLevel()-1),
		damage_type = ability:GetAbilityDamageType()
	}
	ApplyDamage(damageTable)

end
