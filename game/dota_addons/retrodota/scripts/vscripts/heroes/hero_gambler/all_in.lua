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
	
	
	
	PopupNumbers(caster, "damage", Vector(255, 200, 33), 3.0, gold_lost, PATTACH_OVERHEAD_FOLLOW, POPUP_SYMBOL_PRE_MINUS, nil)
	event.target:EmitSound("General.BigCoins")
end