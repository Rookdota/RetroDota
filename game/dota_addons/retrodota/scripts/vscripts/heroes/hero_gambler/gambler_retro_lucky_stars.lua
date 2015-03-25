function gambler_retro_lucky_stars_on_success(event)
	-- TODO: Confirm if it's ok to trigger on allies
	if event.target:IsCreature() then
		event.target:Kill(event.ability, event.caster)
	elseif event.target:IsHero() or event.target:IsTower() or event.target.GetInvulnCount ~= nil then
		ApplyDamage({
			victim = event.target,
			attacker = event.caster,
			damage = event.ability:GetSpecialValueFor("bonus_damage"),
			damage_type = event.ability:GetAbilityDamageType()
		})
	end
end

function gambler_retro_lucky_stars_pillage(event)
	-- TODO: Confirm if it's ok to get gold by denying/hitting allied units
	if event.caster.pillaged_gold == nil then
		event.caster.pillaged_gold = 0
	end

	-- print("-------------------------------")
	-- print("Before Pillaged GOLD:" .. event.caster.pillaged_gold)
	local pillage = (event.attack_damage/event.target:GetMaxHealth()) * event.pillage_ratio * event.target:GetGoldBounty()/2
	event.caster.pillaged_gold = event.caster.pillaged_gold + pillage
	local effective_gold = math.floor(event.caster.pillaged_gold)

	-- print("AD: " .. event.attack_damage)
	-- print("MHP: " .. event.target:GetMaxHealth())
	-- print("PR: " .. event.pillage_ratio)
	-- print("BH: " .. event.target:GetGoldBounty())
	-- print("PILLAGE: " .. pillage)
	-- print("Before GOLD:" .. event.caster:GetGold())	
	-- print("Effective: " .. effective_gold)

	if effective_gold > 0 then
		-- print("GREATER THAN 0 MAKING STUFF")
		event.caster:ModifyGold(effective_gold, false, 0)
		event.caster.pillaged_gold = event.caster.pillaged_gold - effective_gold
	end
	-- print("After GOLD:" .. event.caster:GetGold())
	-- print("After Pillaged GOLD:" .. event.caster.pillaged_gold)
end