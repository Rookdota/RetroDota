--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when Ante up is cast.
	Additional parameters: keys.DamageHeal
================================================================================================================= ]]
function gambler_retro_ante_up_on_spell_start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability  = keys.ability
	local arg
	if caster:GetTeamNumber() == target:GetTeamNumber() then
		target:Heal(keys.DamageHeal, caster)
		PopupNumbers(target, "damage", Vector(0, 255, 0), 2.0, keys.DamageHeal, PATTACH_ABSORIGIN_FOLLOW ,POPUP_SYMBOL_PRE_PLUS, nil)
		arg = "modifier_gambler_retro_ante_up_buff"
	else
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = keys.DamageHeal,
			damage_type = ability:GetAbilityDamageType()
		})
		PopupDamage(target, keys.DamageHeal)
		arg = "modifier_gambler_retro_ante_up_debuff"
	end
	
	caster:EmitSound("retro_dota.gambler_retro_ante_up_gold_cost")
	target:EmitSound("retro_dota.gambler_retro_ante_up_on_spell_start")
	
	local random_int = RandomInt(1, 6)
	if random_int == 1 then
		caster:EmitSound("retro_dota.gambler_retro_spell_cast_voice")
	end
	
	PopupNumbers(caster, "block", Vector(255, 200, 33), 2.0, ability:GetGoldCost(ability:GetLevel() - 1), PATTACH_ABSORIGIN_FOLLOW ,POPUP_SYMBOL_PRE_MINUS, nil)
	ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
	
	--Store the amount of gold associated with this modifier on the target.
	if target.gambler_ante_up_bounty == nil then
		target.gambler_ante_up_bounty = {}
	end
	
	--Remove any existing Ante Up modifiers on the target from the caster.
	target:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_buff", caster)
	target:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_debuff", caster)
	
	target.gambler_ante_up_bounty[caster:GetEntityIndex()] = ability:GetLevelSpecialValueFor("cash_in", ability:GetLevel() - 1)
	
	ability:ApplyDataDrivenModifier(caster, target, arg, {})
end


--[[ ============================================================================================================
	Author: Noya
	Date: 14.1.2015.
	Disallows self targeting by checking if the target is not the caster when the ability starts
================================================================================================================= ]]
function AnteUpPreCast(keys)
	local caster = keys.caster
	local target = keys.target
	local player = caster:GetPlayerOwner()
	local pID = caster:GetPlayerOwnerID()

	-- This prevents the spell from going off
	if target == caster then
		caster:Stop()

		-- Play Error Sound
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", player)

		--This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
		FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Ability Can't Target Self" } )
	end
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the owner of ante up kills another unit.
================================================================================================================= ]]
 function gambler_retro_ante_up_on_owner_kill(keys)
	if keys.unit:IsRealHero() and keys.attacker.gambler_ante_up_bounty ~= nil then
		local ante_up_bounty = keys.attacker.gambler_ante_up_bounty[keys.caster:GetEntityIndex()]
		if ante_up_bounty ~= nil then
			keys.caster:ModifyGold(ante_up_bounty, false, 0)

			local cash_in_full_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_full.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.caster)
			
			--Display twice as many particles since the full amount was cashed in.
			for i=0, 2, 1 do
				ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
				ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion_backside.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
			end
			
			AnteUpShowBounty(keys, ante_up_bounty)
		end
		
		keys.attacker:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_buff", keys.caster)
		keys.attacker:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_debuff", keys.caster)
	end
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called when the unit affected by the Ante Up modifier dies.
================================================================================================================= ]]
function gambler_retro_ante_up_on_owner_death(keys)
	if keys.unit.gambler_ante_up_bounty ~= nil then
		local ante_up_bounty = keys.unit.gambler_ante_up_bounty[keys.caster:GetEntityIndex()]
		if ante_up_bounty ~= nil then
			ante_up_bounty = ante_up_bounty / 2  --The bounty is halved if the unit dies before getting a kill.
			keys.caster:ModifyGold(ante_up_bounty, false, 0)

			local cash_in_half_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_half.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.caster)
			local cash_in_explosion_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
			local cash_in_explosion_backside_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_ante_up_cash_in_explosion_backside.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
			
			AnteUpShowBounty(keys, ante_up_bounty)
		end
		
		keys.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_buff", keys.caster)
		keys.unit:RemoveModifierByNameAndCaster("modifier_gambler_retro_ante_up_debuff", keys.caster)
	end
end


--[[ ============================================================================================================
	Author: wFX
	Date: March 16, 2015
	Called to show popup.
================================================================================================================= ]]
function AnteUpShowBounty(keys, msg)
	PopupNumbers(keys.caster, "evade", Vector(255, 200, 33), 3.0, msg, PATTACH_ABSORIGIN_FOLLOW ,POPUP_SYMBOL_PRE_PLUS, nil)
	keys.caster:EmitSound("retro_dota.gambler_retro_ante_up_cash_in")
end