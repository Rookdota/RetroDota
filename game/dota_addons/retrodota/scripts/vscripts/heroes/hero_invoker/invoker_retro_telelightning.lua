--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Portal's cast point begins.  Starts the particle effect and sound.
	Additional parameters: keys.CastPoint
================================================================================================================= ]]
function invoker_retro_telelightning_on_ability_phase_start(keys)
	local telelightning_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_portal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	--Remove the Portal particle after the duration is supposed to end.
	Timers:CreateTimer({
		endTime = keys.CastPoint + .7,
		callback = function()
			ParticleManager:DestroyParticle(telelightning_particle_effect, false)
		end
	})

end


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
	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), false)

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = ability:GetLevelSpecialValueFor("damage", wex_ability:GetLevel()-1),
		damage_type = ability:GetAbilityDamageType()
	}
	ApplyDamage(damageTable)
	event.target:EmitSound("DOTA_Item.BlinkDagger.Activate")
end