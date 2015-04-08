--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when Ante up is cast.
	Additional parameters: event.DamageHeal
================================================================================================================= ]]
function gambler_retro_ante_up_on_spell_start(event)
	
	local caster = event.caster
	local target = event.target
	local ability  = event.ability
	local arg
	if caster:GetTeamNumber() == target:GetTeamNumber() then
		target:Heal(event.DamageHeal, caster)
		arg = "modifier_gambler_retro_ante_up_buff"
	else
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = event.DamageHeal,
			damage_type = ability:GetAbilityDamageType()
		})
		arg = "modifier_gambler_retro_ante_up_debuff"
	end
	ability:ApplyDataDrivenModifier(caster, target, arg, {})
	target.ante_bounty = ability:GetLevelSpecialValueFor("cash_in", ability:GetLevel() - 1)
end


--[[ ============================================================================================================
	Author: Noya
	Date: 14.1.2015.
	Disallows self targeting by checking if the target is not the caster when the ability starts
================================================================================================================= ]]

function AnteUpPreCast(event)
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerOwner()
	local pID = caster:GetPlayerOwnerID()

	-- This prevents the spell from going off
	if target == caster then
		caster:Stop()

		-- Play Error Sound
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", player)

		-- This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
		FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Ability Can't Target Self" } )
	end
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up kill another hero.
================================================================================================================= ]]
 function gambler_retro_ante_up_on_owner_hero_kill(event)
	event.caster:ModifyGold(event.attacker.ante_bounty, false, 0)
	event.attacker:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_buff", event.caster)
	event.attacker:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_debuff", event.caster)
	event.msg = event.attacker.ante_bounty
	event.attacker.ante_bounty = 0
	AnteUpShowBounty(event)
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up die.
================================================================================================================= ]]
function gambler_retro_ante_up_on_owner_death(event)
	event.caster:ModifyGold(event.unit.ante_bounty/2, false, 0)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_buff", event.caster)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_debuff", event.caster)
	event.msg = event.unit.ante_bounty/2
	event.unit.ante_bounty = 0
	AnteUpShowBounty(event)
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called to show popup.
================================================================================================================= ]]
function AnteUpShowBounty(event)
	PopupGoldGain(event.caster, event.msg)
	event.caster:EmitSound("General.Coins")
end