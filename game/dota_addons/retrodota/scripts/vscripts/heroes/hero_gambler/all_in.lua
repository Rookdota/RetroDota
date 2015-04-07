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
	-- print("All In did "..random_damage.." damage!")
	PopupNumbers(target, "damage", Vector(255, 0, 0), 3.0, random_damage, PATTACH_OVERHEAD_FOLLOW, nil, POPUP_SYMBOL_POST_LIGHTNING)
	event.target:EmitSound("General.BigCoins")
	event.target:EmitSound("Hero_OgreMagi.Fireblast.x3")
end



--[[ 
	Author: Noya
	Date: March 25, 2015
	Failed All In, loses random gold up to the casters gold or the damage cap (whichever is lower)
 ]]
 function AllInFailure(event)
 	local caster = event.caster
 	local ability = event.ability
	local gold = caster:GetGold()
	local damage_cap = ability:GetLevelSpecialValueFor("damage_cap", ability:GetLevel() - 1 )

	-- Adjust the cap for casters gold
	local gold = caster:GetGold()
	if gold < damage_cap then
		damage_cap = gold
	end

	local gold_lost = RandomInt(1, damage_cap)

	caster:SpendGold(gold_lost, 0)
	-- print("Lost "..gold_lost.." gold, bad gamble")
	PopupNumbers(caster, "damage", Vector(255, 200, 33), 3.0, gold_lost, PATTACH_OVERHEAD_FOLLOW, POPUP_SYMBOL_PRE_MINUS, nil)]
	event.target:EmitSound("General.BigCoins")
end