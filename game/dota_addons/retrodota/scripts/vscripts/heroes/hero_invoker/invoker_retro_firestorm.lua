--[[ ============================================================================================================
	Author: Rook
	Date: March 6, 2015
	Called when Firestorm is cast.
	Additional parameters: keys.FireballCastRadius, keys.FireballLandDelay, keys.FireballDelayBetweenSpawns,
		keys.FireballVisionRadius, keys.FireballDamageAoE, keys.FireballLandingDamage, keys.FireballDuration,
		keys.FireballExplosionDamage
================================================================================================================= ]]
function invoker_retro_firestorm_on_spell_start(keys)
	local caster_point = keys.caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	
	local caster_point_temp = Vector(caster_point.x, caster_point.y, 0)
	local target_point_temp = Vector(target_point.x, target_point.y, 0)
	
	local point_difference_normalized = (target_point_temp - caster_point_temp):Normalized()
	
	keys.caster:EmitSound("Hero_EarthSpirit.Petrify")
	keys.caster:EmitSound("Hero_Warlock.RainOfChaos")
	
	--The number of fireballs to spawn is dependent on the level of Exort.
	local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
	local num_fireballs = 0
	if exort_ability ~= nil then
		num_fireballs = keys.ability:GetLevelSpecialValueFor("num_fireballs", exort_ability:GetLevel() - 1)
	end
	
	--Spawn the fireballs.
	local fireballs_spawned_so_far = 0
	Timers:CreateTimer({
		callback = function()
			--Select a random point within the radius around the target point.
			local random_x_offset = RandomInt(0, keys.FireballCastRadius) - (keys.FireballCastRadius / 2)
			local random_y_offset = RandomInt(0, keys.FireballCastRadius) - (keys.FireballCastRadius / 2)
			local fireball_landing_point = Vector(target_point.x + random_x_offset, target_point.y + random_y_offset, target_point.z)
			fireball_landing_point = GetGroundPosition(fireball_landing_point, nil)
			
			--Create a particle effect consisting of the fireball falling from the sky and landing at the target point.
			local fireball_spawn_point = (fireball_landing_point - (point_difference_normalized * 300)) + Vector (0, 0, 800)
			local fireball_fly_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball_fly.vpcf", PATTACH_ABSORIGIN, keys.caster)
			ParticleManager:SetParticleControl(fireball_fly_particle_effect, 0, fireball_spawn_point)
			ParticleManager:SetParticleControl(fireball_fly_particle_effect, 1, fireball_landing_point)
			ParticleManager:SetParticleControl(fireball_fly_particle_effect, 2, Vector(keys.FireballLandDelay, 0, 0))
			
			--Create a dummy unit at the spawn point to emit a sound.
			local fireball_sound_unit = CreateUnitByName("npc_dota_invoker_retro_firestorm_fireball_explosion_unit", fireball_landing_point, false, nil, nil, keys.caster:GetTeam())
			local dummy_unit_ability = fireball_sound_unit:FindAbilityByName("dummy_unit_passive")
			if dummy_unit_ability ~= nil then
				dummy_unit_ability:SetLevel(1)
			end
			fireball_sound_unit:EmitSound("Hero_EarthSpirit.Magnetize.End")
			
			--Spawn the landed fireball when it's supposed to have visually landed.
			Timers:CreateTimer({
				endTime = keys.FireballLandDelay,
				callback = function()
					local fireball_unit = CreateUnitByName("npc_dota_invoker_retro_firestorm_unit", fireball_landing_point, false, nil, nil, keys.caster:GetTeam())
					local fireball_unit_ability = fireball_unit:FindAbilityByName("invoker_retro_firestorm_fireball")
					if fireball_unit_ability ~= nil then
						fireball_unit_ability:SetLevel(1)
					end
					
					fireball_unit.firestorm_fireball_time_to_explode = GameRules:GetGameTime() + keys.FireballDuration
					
					local fireball_ground_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball.vpcf", PATTACH_ABSORIGIN, fireball_unit)
					
					fireball_unit:SetDayTimeVisionRange(keys.FireballVisionRadius)
					fireball_unit:SetNightTimeVisionRange(keys.FireballVisionRadius)
					
					fireball_unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Target")
					fireball_unit:EmitSound("Hero_Phoenix.FireSpirits.Cast")
					
					local firestorm_ability = fireball_unit:FindAbilityByName("invoker_retro_firestorm")
					firestorm_ability:ApplyDataDrivenModifier(keys.caster, fireball_unit, "modifier_invoker_retro_firestorm_fireball_duration", nil)
					firestorm_ability:ApplyDataDrivenModifier(keys.caster, fireball_unit, "modifier_invoker_retro_firestorm_fireball_damage_over_time_aura_emitter", nil)					
					
					--Damage nearby enemy units with fireball landing damage.
					local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), fireball_landing_point, nil, keys.FireballDamageAoE, DOTA_UNIT_TARGET_TEAM_ENEMY,
						DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
					
					for i, individual_unit in ipairs(nearby_enemy_units) do
						ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.FireballLandingDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
					end
					
					--Explode the fireball when it is set to expire.  By doing this here and not in modifier_invoker_retro_firestorm_fireball_duration_on_interval_think,
					--the spell can be made with one less dummy unit.
					Timers:CreateTimer({
						endTime = keys.FireballDuration,
						callback = function()
							local fireball_explosion_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_retro_firestorm_fireball_explosion.vpcf", PATTACH_ABSORIGIN, fireball_sound_unit)
							
							fireball_sound_unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Destroy")
							
							--Damage nearby enemy units with fireball explosion damage.
							local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), fireball_landing_point, nil, keys.FireballDamageAoE, DOTA_UNIT_TARGET_TEAM_ENEMY,
								DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
							
							for i, individual_unit in ipairs(nearby_enemy_units) do
								ApplyDamage({victim = individual_unit, attacker = keys.caster, damage = keys.FireballExplosionDamage, damage_type = DAMAGE_TYPE_MAGICAL,})
							end
							
							fireball_unit:RemoveSelf()
							
							--Destroy the dummy unit used to play the explosion after the effect is finished.
							Timers:CreateTimer({
								endTime = 2,
								callback = function()
									fireball_sound_unit:RemoveSelf()
								end
							})
						end
					})
				end
			})
			
			fireballs_spawned_so_far = fireballs_spawned_so_far + 1
			if fireballs_spawned_so_far >= num_fireballs then 
				return
			else 
				return keys.FireballDelayBetweenSpawns
			end
		end
	})
end


--[[ ============================================================================================================
	Author: Rook
	Date: March 6, 2015
	Called regularly on fireballs that are lying around.  Removes some of the fireball's health to enforce the timer.
	Additional parameters: keys.FireballDuration
================================================================================================================= ]]
function modifier_invoker_retro_firestorm_fireball_duration_on_interval_think(keys)
	local new_health = keys.target:GetMaxHealth()
	
	if keys.target.firestorm_fireball_time_to_explode == nil then
		new_health = keys.target:GetHealth() - ((keys.target:GetMaxHealth() / keys.FireballDuration) * .03)
	else
		new_health = new_health * ((keys.target.firestorm_fireball_time_to_explode - GameRules:GetGameTime()) / keys.FireballDuration)
	end
		
	if new_health > 0 then  --Lower the health.
		keys.target:SetHealth(new_health)
	else
		keys.target:SetHealth(1)
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: March 6, 2015
	Called regularly on fireballs that are lying around.  Damages nearby enemy units.
	Additional parameters: keys.FireballDamageAoE, keys.FireballAoEDamageInterval, keys.FireballAoEDamagePerSecond
================================================================================================================= ]]
function modifier_invoker_retro_firestorm_fireball_damage_over_time_aura_on_interval_think(keys)
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.FireballAoEDamagePerSecond * keys.FireballAoEDamageInterval, damage_type = DAMAGE_TYPE_MAGICAL,})
end