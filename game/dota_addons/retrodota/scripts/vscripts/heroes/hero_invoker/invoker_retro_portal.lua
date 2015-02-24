--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Portal's cast point begins.  Starts the particle effect and sound.
	Additional parameters: keys.CastPoint
================================================================================================================= ]]
function invoker_retro_portal_on_ability_phase_start(keys)
	local portal_particle_effect = ParticleManager:CreateParticle("particles/heroes/hero_invoker/invoker_retro_portal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	--Remove the Portal particle after the duration is supposed to end.
	Timers:CreateTimer({
		endTime = keys.CastPoint + .2,
		callback = function()
			ParticleManager:DestroyParticle(portal_particle_effect, false)
		end
	})
	
	keys.target:EmitSound("Hero_Meepo.Poof.Channel")
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Portal's cast point finishes.  Damages the target and moves them to Invoker.
================================================================================================================= ]]
function invoker_retro_portal_on_spell_start(keys)	
	--Portal's damage is dependent on the level of Wex.
	local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
	local portal_damage = 0
	if wex_ability ~= nil then
		portal_damage = keys.ability:GetLevelSpecialValueFor("damage", wex_ability:GetLevel() - 1)
	end
	
	FindClearSpaceForUnit(keys.target, keys.caster:GetAbsOrigin(), false)  --Move the target to Invoker's position.
	keys.target:EmitSound("Hero_Meepo.Poof.End")
	
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = portal_damage, damage_type = DAMAGE_TYPE_MAGICAL,})
end
