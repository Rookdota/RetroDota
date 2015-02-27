--[[ ============================================================================================================
	Author: Rook
	Date: February 24, 2015
	Called when Soul Blast is cast.  Damages the target enemy unit, and heals Invoker.
================================================================================================================= ]]
function invoker_retro_soul_blast_on_spell_start(keys)
	keys.caster:EmitSound("Hero_NyxAssassin.ManaBurn.Cast")
	keys.target:EmitSound("Hero_NyxAssassin.ManaBurn.Target")
	
	local Quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
	local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
	if wex_ability ~= nil and exort_ability ~= nil then
		local damage = keys.ability:GetLevelSpecialValueFor("damage", exort_ability:GetLevel() - 1)  --Damage dealt increases per level of Exort.
		local healing = keys.ability:GetLevelSpecialValueFor("heal", quas_ability:GetLevel() - 1)  --Damage dealt increases per level of Quas.
		
		local mana_burn_number = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.target)
		ParticleManager:SetParticleControl(mana_burn_number, 1, Vector(1, mana_to_burn, 0))
		ParticleManager:SetParticleControl(mana_burn_number, 2, Vector(2, string.len(math.floor(mana_to_burn)) + 1, 0))
		
		local mana_burn_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_mana_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
		
		keys.target:ReduceMana(mana_to_burn)
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = mana_to_burn, damage_type = DAMAGE_TYPE_MAGICAL,})
	end
end