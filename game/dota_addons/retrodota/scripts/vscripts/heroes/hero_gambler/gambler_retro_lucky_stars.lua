--[[ ============================================================================================================
	Author: wFX
	Date: March 27, 2015
	Called when lucky stars proc, autokill creeps or do bonus damage against building/hero
================================================================================================================= ]]

function gambler_retro_lucky_stars_on_success(event)
	-- TODO: Confirm if it's ok to trigger on allies
	local flag = false

	if event.target:IsCreature() then
		event.target:Kill(event.ability, event.caster)
	    PopupDeny(event.caster, Vector(255, 200, 33))
	    flag = true
	elseif event.target:IsHero() or event.target:IsTower() or event.target.GetInvulnCount ~= nil then
		ApplyDamage({
			victim = event.target,
			attacker = event.caster,
			damage = event.ability:GetSpecialValueFor("bonus_damage"),
			damage_type = event.ability:GetAbilityDamageType()
		})
		PopupNumbers(event.target, "crit", Vector(255, 200, 33), 1.0, event.ability:GetSpecialValueFor("bonus_damage"), PATTACH_CUSTOMORIGIN, nil, POPUP_SYMBOL_POST_LIGHTNING)
	    flag = true
	end

	if flag == true then
		event.target:StopSound("Hero_OgreMagi.Fireblast.x1")
		event.target:EmitSound("Hero_OgreMagi.Fireblast.x1")
		
		local lucky_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_lucky_stars_lucky.vpcf", PATTACH_OVERHEAD_FOLLOW, event.caster)
	end
end

--[[ ============================================================================================================
	Author: wFX
	Date: March 27, 2015
	Every hit, add some amount to pillaged gold
================================================================================================================= ]]

function gambler_retro_lucky_stars_pillage(event)
	-- TODO: Confirm if it's ok to gain gold by denying/hitting allied units
	if event.caster.pillaged_gold == nil then
		event.caster.pillaged_gold = 0
	end

	local pillage = (event.attack_damage/event.target:GetMaxHealth()) * event.pillage_ratio * event.target:GetGoldBounty()
	event.caster.pillaged_gold = event.caster.pillaged_gold + pillage
	local effective_gold = math.floor(event.caster.pillaged_gold)

	if effective_gold > 0 then
		event.caster:ModifyGold(effective_gold, false, 0)
		event.caster.pillaged_gold = event.caster.pillaged_gold - effective_gold
	end

end