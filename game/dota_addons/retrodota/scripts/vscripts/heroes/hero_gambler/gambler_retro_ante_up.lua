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
		 PopupNumbers(target, "damage", Vector(0, 255, 0), 2.0, event.DamageHeal, PATTACH_ABSORIGIN_FOLLOW ,POPUP_SYMBOL_PRE_PLUS, nil)
		arg = "modifier_gambler_retro_ante_up_buff"
	else
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = event.DamageHeal,
			damage_type = ability:GetAbilityDamageType()
		})
		PopupDamage(target, event.DamageHeal)
		arg = "modifier_gambler_retro_ante_up_debuff"
	end
	
	caster:EmitSound("retro_dota.gambler_retro_ante_up_gold_cost")
	target:EmitSound("retro_dota.gambler_retro_ante_up_on_spell_start")
	
	local random_int = RandomInt(1, 3)
	if random_int == 1 then
		caster:EmitSound("retro_dota.gambler_retro_spell_cast_voice")
	end
	
	PopupNumbers(caster, "block", Vector(255, 200, 33), 2.0, ability:GetGoldCost(ability:GetLevel() - 1), PATTACH_ABSORIGIN_FOLLOW ,POPUP_SYMBOL_PRE_MINUS, nil)
	ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.caster)
	
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
	Called when the owner of ante up kills another unit.
================================================================================================================= ]]
 function gambler_retro_ante_up_on_owner_kill(event)
	if event.unit:IsRealHero() then
		event.caster:ModifyGold(event.attacker.ante_bounty, false, 0)
		event.attacker:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_buff", event.caster)
		event.attacker:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_debuff", event.caster)
		event.msg = event.attacker.ante_bounty
		event.attacker.ante_bounty = 0
		
		local cash_in_full_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_full.vpcf", PATTACH_OVERHEAD_FOLLOW, event.caster)
		
		--Display twice as many particles since the full amount was cashed in.
		for i=0, 2, 1 do
			ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.caster)
			ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion_backside.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.caster)
		end
		
		AnteUpShowBounty(event)
	end
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up dies.
================================================================================================================= ]]
function gambler_retro_ante_up_on_owner_death(event)
	event.caster:ModifyGold(event.unit.ante_bounty/2, false, 0)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_buff", event.caster)
	event.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_debuff", event.caster)
	event.msg = event.unit.ante_bounty/2
	event.unit.ante_bounty = 0
	
	local cash_in_half_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_half.vpcf", PATTACH_OVERHEAD_FOLLOW, event.caster)
	local cash_in_explosion_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.caster)
	local cash_in_explosion_backside_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion_backside.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.caster)
	AnteUpShowBounty(event)
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called to show popup.
================================================================================================================= ]]
function AnteUpShowBounty(event)
	PopupNumbers(event.caster, "evade", Vector(255, 200, 33), 3.0, event.msg, PATTACH_ABSORIGIN_FOLLOW ,POPUP_SYMBOL_PRE_PLUS, nil)
	event.caster:EmitSound("retro_dota.gambler_retro_ante_up_cash_in")
end