--[[ ============================================================================================================
	Author: wFX
	Date: March 05, 2015
	Called when Soul Reaver is cast.
================================================================================================================= ]]
function invoker_retro_soul_reaver_on_spell_start(event)
	local damageTable = {
		victim = event.target,
		attacker = event.caster,
		damage = event.ability:GetAbilityDamage(),
		damage_type = event.ability:GetAbilityDamageType()
	}
	ApplyDamage(damageTable)
	event.ability:ApplyDataDrivenModifier(event.caster, event.caster, "modifier_invoker_retro_soul_reaver", {duration = 8})	
	event.caster:SetModifierStackCount("modifier_invoker_retro_soul_reaver", event.ability, event.caster:FindAbilityByName("invoker_retro_wex"):GetLevel())
end