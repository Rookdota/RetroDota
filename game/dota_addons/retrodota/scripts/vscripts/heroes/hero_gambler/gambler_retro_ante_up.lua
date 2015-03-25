--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when Ante up is cast.
================================================================================================================= ]]
function gambler_retro_ante_up_on_spell_start(event)
	local caster = event.caster
	local target = event.target
	local ability  = event.ability
	local arg
	if caster:GetTeamNumber() == target:GetTeamNumber() then
		target:Heal(ability:GetAbilityDamage(), caster)
		arg = "modifier_gambler_retro_ante_up_buff"
	else
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType()
		})
		arg = "modifier_gambler_retro_ante_up_debuff"
	end
	ability:ApplyDataDrivenModifier(caster, target, arg, {})
end



--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up kill another hero.
================================================================================================================= ]]
 function gambler_retro_ante_up_on_owner_hero_kill(event)
	event.caster:ModifyGold(event.ability:GetSpecialValueFor("cash_in"), false, 0)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up", event.caster)
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up die.
================================================================================================================= ]]
function gambler_retro_ante_up_on_owner_death(event)
	event.caster:ModifyGold((event.ability:GetSpecialValueFor("cash_in")/2), false, 0)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up", event.caster)
end