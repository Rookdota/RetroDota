--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Portal is cast.  Damages the target and moves them to Invoker.
	Additional parameters: keys.Delay
================================================================================================================= ]]
function invoker_retro_portal_on_spell_start(keys)
	local portal_particle_effect = ParticleManager:CreateParticle("particles/heroes/hero_invoker/invoker_retro_portal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	
	--Remove the Portal particle after the duration is supposed to end.
	Timers:CreateTimer({
		endTime = keys.Delay + .2,
		callback = function()
			ParticleManager:DestroyParticle(portal_particle_effect, false)
		end
	})
	
	keys.target:EmitSound("Hero_Meepo.Poof.Channel")
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_portal", nil)
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 20, 2015
	Called a short while after Portal is cast on a unit.  Damages the target and moves them to Invoker.
================================================================================================================= ]]
function modifier_invoker_retro_portal_on_interval_think(keys)
	--Portal's damage is dependent on the level of Wex.
	local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
	local portal_damage = 0
	if wex_ability ~= nil then
		portal_damage = keys.ability:GetLevelSpecialValueFor("damage", wex_ability:GetLevel() - 1)
	end
	
	FindClearSpaceForUnit(keys.target, keys.caster:GetAbsOrigin(), false)  --Move the target to Invoker's position.
	keys.target:EmitSound("Hero_Meepo.Poof.End")
	
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = portal_damage, damage_type = DAMAGE_TYPE_MAGICAL,})
	
	keys.target:RemoveModifierByNameAndCaster("modifier_invoker_retro_portal", keys.caster)
end
