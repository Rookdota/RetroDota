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
	
	local gold = caster:GetGold()
	if gold <= 0 then  --If you have 0 gold, you will still do 1 damage.
		gold = 1
	end

	local random_damage = RandomInt(1, gold)
	if random_damage > damage_cap then  --Cap the damage if it is over the damage cap.
		random_damage = damage_cap
	end
	
	ApplyDamage({ victim = target, attacker = caster, damage = random_damage, damage_type = AbilityDamageType, ability = ability}) 
	-- print("All In did "..random_damage.." damage!")
	
	local all_in_success_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_all_in_success.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	local all_in_color_table = {}
	all_in_color_table["0"] = Vector(255, 220, 48)  --Gold
	all_in_color_table["1"] = Vector(172, 49, 31)  --Red
	--all_in_color_table["2"] = Vector(255, 255, 255)  --White
	all_in_color_table["2"] = Vector(1, 71, 105)  --Blue
	all_in_color_table["3"] = Vector(215, 92, 35)  --Orange
	all_in_color_table["4"] = Vector(0, 89, 53)  --Green
	all_in_color_table["5"] = Vector(170, 75, 156)  --Purple
	
	--Cycle through particle colors.
	ParticleManager:SetParticleControl(all_in_success_particle, 3, all_in_color_table["0"])
	local current_color_index = 1
	local endTime = GameRules:GetGameTime() + 3  --The particle's duration is 3 seconds.
	Timers:CreateTimer({
		endTime = .2,
		callback = function()
			if GameRules:GetGameTime() > endTime then
				return
			else
				if all_in_color_table[tostring(current_color_index)] == nil then
					current_color_index = 0
				end
				ParticleManager:SetParticleControl(all_in_success_particle, 3, all_in_color_table[tostring(current_color_index)])
				current_color_index = current_color_index + 1
				return .2
			end
		end
	})
	
	--Display the explosion particle.
	ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_all_in_success_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	
	--Display the damage dealt particle.
    local pidx = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_all_in_success_damage_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, target)

    local digits = 0
    if random_damage ~= nil then
        digits = #tostring(random_damage)
    end
    digits = digits + 1  --This is due to the POPUP_SYMBOL_POST_LIGHTNING postsymbol.

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(nil), tonumber(random_damage), tonumber(POPUP_SYMBOL_POST_LIGHTNING)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3.0, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, Vector(255, 0, 0))

	event.caster:EmitSound("retro_dota.gambler_retro_all_in_success_bell")
	event.caster:EmitSound("Hero_OgreMagi.Fireblast.x3")
	
	local random_int = RandomInt(1, 3)
	if random_int == 1 then
		event.caster:EmitSound("retro_dota.gambler_retro_all_in_success_voice")
	end
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

	local gold = caster:GetGold()
	if gold <= 0 then
		gold = 1
	end

	local gold_lost = RandomInt(1, gold)
	if gold_lost > damage_cap then  --Cap the damage if it is over the damage cap.
		gold_lost = damage_cap
	end
	
	if caster:GetGold() >= gold_lost then
		caster:SpendGold(gold_lost, 0)
	else  --If the caster has less gold than he is supposed to lose, set his gold to 0.  This should only apply when he casts All In with 0 gold, but it prevents his gold count from going negative.
		caster:SetGold(0, true)
		caster:SetGold(0, false)
	end
	-- print("Lost "..gold_lost.." gold, bad gamble")
	
	local all_in_failure_coins_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_all_in_failure_coins.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	
	local all_in_failure_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_all_in_failure.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	local lights_on = Vector(255, 220, 48)  --Gold
	local lights_off = Vector(140, 140, 140)  --Grey
	
	--Play an animation using colors.
	ParticleManager:SetParticleControl(all_in_failure_particle, 3, lights_on)
	Timers:CreateTimer({
		endTime = 1.1,
		callback = function()
			ParticleManager:SetParticleControl(all_in_failure_particle, 3, lights_off)
			
			Timers:CreateTimer({
				endTime = .05,
				callback = function()
					ParticleManager:SetParticleControl(all_in_failure_particle, 3, lights_on)
					
					Timers:CreateTimer({
						endTime = .5,
						callback = function()
							ParticleManager:SetParticleControl(all_in_failure_particle, 3, lights_off)
							
							Timers:CreateTimer({
								endTime = .1,
								callback = function()
									ParticleManager:SetParticleControl(all_in_failure_particle, 3, lights_on)
									
									Timers:CreateTimer({
										endTime = .1,
										callback = function()
											ParticleManager:SetParticleControl(all_in_failure_particle, 3, lights_off)
										end
									})
								end
							})
						end
					})
				end
			})
		end
	})
	
	--Display the gold lost particle.
    local pidx = ParticleManager:CreateParticle("particles/units/heroes/hero_gambler/gambler_all_in_failure_gold_lost_msg.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    local digits = 0
    if gold_lost ~= nil then
        digits = #tostring(gold_lost)
    end
    digits = digits + 1  --This is due to the POPUP_SYMBOL_PRE_MINUS presymbol.

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(POPUP_SYMBOL_PRE_MINUS), tonumber(gold_lost), tonumber(nil)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3.0, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, Vector(255, 200, 33))
	
	event.caster:EmitSound("retro_dota.gambler_retro_all_in_failure_buzzer")
	event.caster:EmitSound("retro_dota.gambler_retro_all_in_failure_gold_lost")
	event.caster:EmitSound("retro_dota.gambler_retro_all_in_failure_voice")
end