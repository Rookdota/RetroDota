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
	print("Chip Stack did "..gold_damage.." damage!")

	local pfxPath = "particles/msg_fx/msg_crit.vpcf" 
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, target)
    local color = Vector(255, 200, 33)
    local digits = string.len(gold_damage)+1

    ParticleManager:SetParticleControl(pidx, 1, Vector(9, gold_damage, 4))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3.0, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
	
end