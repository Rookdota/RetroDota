--[[ 
	Author: Noya
	Date: March 25, 2015
	Succesful All In, does random damage up to the casters gold
 ]]
function AllInSuccess(event)
	local caster = event.caster
	local target = event.target
	local ability  = event.ability
	local AbilityDamageType = ability:GetAbilityDamageType()
	local damage_cap = ability:GetLevelSpecialValueFor("damage_cap", ability:GetLevel() - 1 )

	-- Adjust the cap for casters gold
	local gold = caster:GetGold()
	if gold < damage_cap then
		damage_cap = gold
	end

	local random_damage = RandomInt(1, damage_cap)
	ApplyDamage({ victim = target, attacker = caster, damage = random_damage, damage_type = AbilityDamageType, ability = ability}) 
	print("All In did "..random_damage.." damage!")

	local pfxPath = "particles/msg_fx/msg_damage.vpcf" 
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, target)
    local color = Vector(255, 0, 0)
    local digits = string.len(damage_cap)+1

    ParticleManager:SetParticleControl(pidx, 1, Vector(1, damage_cap, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3.0, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
	
end



--[[ 
	Author: Noya
	Date: March 25, 2015
	Failed All In, loses random gold up to the casters gold
 ]]
 function AllInFailure(event)
 	local caster = event.caster
	local gold = caster:GetGold()
	local gold_lost = RandomInt(1, gold)

	caster:SetGold(gold - gold_lost, false)
	print("Lost "..gold_lost.." gold, bad gamble")

	local pfxPath = "particles/msg_fx/msg_damage.vpcf" 
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_OVERHEAD_FOLLOW, caster)
    local color = Vector(255, 200, 33)
    local digits = string.len(gold_lost)+1

    ParticleManager:SetParticleControl(pidx, 1, Vector(1, gold_lost, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3.0, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end