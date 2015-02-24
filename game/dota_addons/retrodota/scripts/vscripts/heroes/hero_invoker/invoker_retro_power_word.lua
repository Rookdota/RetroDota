--[[ ============================================================================================================
	Author: Rook
	Date: February 23, 2015
	Called when Power Word is cast.  Applies an armor buff if cast on an ally, and an armor debuff if cast on an enemy.
================================================================================================================= ]]
function invoker_retro_power_word_on_spell_start(keys)
	if keys.caster:GetTeam() == keys.target:GetTeam() then  --If Power Word was cast on an ally.
		if keys.caster ~= keys.target then  --If Power Word wasn't self-casted.
			keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
			
			local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
			if quas_ability ~= nil then
				local armor_buff_value = math.abs(keys.ability:GetLevelSpecialValueFor("armor_bonus_ally", quas_ability:GetLevel() - 1))
				for i=0, armor_buff_value, 1 do
					keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_power_word_armor_buff", nil)
				end
				keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_power_word_armor_buff_icon", nil)
			end
		else  --If Power Word was self-casted, which it's not supposed to be able to do.
			keys.ability:RefundManaCost()
			keys.ability:EndCooldown()
			EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", keys.caster:GetPlayerOwner())
			
			--This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
			FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Ability Can't Target Self" } )
		end
	else  --If Power Word was cast on an enemy.
		keys.target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		
		local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
		if quas_ability ~= nil then
			local armor_debuff_value = math.abs(keys.ability:GetLevelSpecialValueFor("armor_reduction_enemy", quas_ability:GetLevel() - 1))
			for i=0, armor_debuff_value, 1 do
				keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_power_word_armor_debuff", nil)
			end
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_retro_power_word_armor_debuff_icon", nil)
		end
	end
end