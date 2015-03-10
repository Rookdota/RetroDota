--[[ ============================================================================================================
	Author: Noya
	Date: March 10, 2015
	Called when Shroud of Flames is cast. Damages the target enemy unit by Exort level
================================================================================================================= ]]
function invoker_retro_shroud_of_flames(keys)
	
	local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
	if exort_ability ~= nil then
		local damage_exort = keys.ability:GetLevelSpecialValueFor("damage_exort", exort_ability:GetLevel() - 1)  --Damage dealt increases per level of Exort.
		
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_exort, damage_type = DAMAGE_TYPE_MAGICAL})
	end
end