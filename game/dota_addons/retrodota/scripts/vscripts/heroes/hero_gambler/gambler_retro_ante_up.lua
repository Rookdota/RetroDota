--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when Ante up is cast.
================================================================================================================= ]]
function gambler_retro_ante_up_on_spell_start(event)
	local caster = event.caster
	local target = event.target
	local ability  = event.ability
	local args
	if caster:GetTeamNumber() == target:GetTeamNumber() then
		target:Heal(ability:GetAbilityDamage(), caster)
		args = {IsBuff = 1, IsDebuff = 0}
	else
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = ability:GetAbilityDamage(),
			damage_type = ability:GetAbilityDamageType()
		})
		args = {IsBuff = 0, IsDebuff = 1}
	end
	ability:ApplyDataDrivenModifier(caster, target,"modifier_gambler_retro_ante_up", args)
end



--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up kill another hero.
================================================================================================================= ]]
 function gambler_retro_ante_up_on_owner_hero_kill(event)
	event.caster:SetGold(event.ability:GetSpecialValueFor("cash_in"), false)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up", event.caster)
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up die.
================================================================================================================= ]]
function gambler_retro_ante_up_on_owner_death(event)
	event.caster:SetGold(event.ability:GetSpecialValueFor("cash_in")/2, false)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up", event.caster)
end