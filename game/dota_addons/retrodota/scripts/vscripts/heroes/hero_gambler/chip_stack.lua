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

	local pfxID = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_chip_stack.vpcf",  PATTACH_ABSORIGIN_FOLLOW, event.caster)
	ParticleManager:SetParticleControlEnt(pfxID, 1, event.target, PATTACH_POINT_FOLLOW, "attach_hitloc", event.target:GetAbsOrigin(), false)
	local particle_effect_intensity = 400 + (100 * event.ability:GetLevel() - 1)
	ParticleManager:SetParticleControl(pfxID, 2, Vector(particle_effect_intensity))
	
	-- Change this with EmitSoundParams or another fancy thins, this is ridiculous
	event.target:EmitSound("DOTA_Item.MagicWand.Activate")
	event.target:EmitSound("DOTA_Item.MagicWand.Activate")
	event.target:EmitSound("DOTA_Item.MagicWand.Activate")
	event.target:EmitSound("DOTA_Item.MagicWand.Activate")
	event.target:EmitSound("DOTA_Item.MagicStick.Activate")
	event.target:EmitSound("DOTA_Item.MagicStick.Activate")
	event.target:EmitSound("DOTA_Item.Hand_Of_Midas")
	
    PopupNumbers(event.target, "crit", Vector(255, 200, 33), 3.0, gold_damage, PATTACH_OVERHEAD_FOLLOW, nil, POPUP_SYMBOL_POST_LIGHTNING)
	
end