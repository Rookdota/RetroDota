--[[ 
	Author: Noya
	Date: March 25, 2015
	Deals damage based on target hero gold
 ]]
function ChipStack(event)
	local caster = event.caster
	local target = event.target
	local ability  = event.ability
	local AbilityDamageType = ability:GetAbilityDamageType()
	local gold_to_damage_ratio = ability:GetLevelSpecialValueFor("gold_to_damage_ratio", ability:GetLevel() - 1 )	
	local gold_damage = math.floor(target:GetGold() * gold_to_damage_ratio * 0.01)

	ApplyDamage({ victim = target, attacker = caster, damage = gold_damage, damage_type = AbilityDamageType, ability = ability}) 
	--print("Chip Stack did "..gold_damage.." damage!")

	local chip_stack_beam_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_chip_stack.vpcf",  PATTACH_ABSORIGIN_FOLLOW, event.caster)
	ParticleManager:SetParticleControlEnt(chip_stack_beam_particle, 0, event.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", event.caster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(chip_stack_beam_particle, 1, event.target, PATTACH_POINT_FOLLOW, "attach_hitloc", event.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 400 + (100 * event.ability:GetLevel() - 1)
	ParticleManager:SetParticleControl(chip_stack_beam_particle, 2, Vector(particle_effect_intensity))
	
	local chip_stack_coin_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_chip_stack_coins.vpcf",  PATTACH_ABSORIGIN_FOLLOW, event.target)

	local endTime = GameRules:GetGameTime() + 1.5  --The particle's duration is 2 seconds.
	Timers:CreateTimer({
		callback = function()
			if GameRules:GetGameTime() > endTime then
				return
			else
				local chip_stack_blood_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_chip_stack_blood.vpcf",  PATTACH_ABSORIGIN_FOLLOW, event.target)
				local target_abs_origin = event.target:GetAbsOrigin()
				ParticleManager:SetParticleControl(chip_stack_blood_particle, 1, Vector(target_abs_origin.x, target_abs_origin.y, target_abs_origin.z + 75))
				return .3
			end
		end
	})
	
	event.target:EmitSound("Hero_DoomBringer.DevourCast")
	event.target:EmitSound("DOTA_Item.Hand_Of_Midas")

    PopupNumbers(event.target, "damage", Vector(255, 0, 0), 2.0, gold_damage, PATTACH_OVERHEAD_FOLLOW, nil, POPUP_SYMBOL_POST_LIGHTNING)
end