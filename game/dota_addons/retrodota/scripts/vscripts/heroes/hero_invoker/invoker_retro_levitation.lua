--[[ ============================================================================================================
	Author: Rook
	Date: February 20, 2015
	Called when Levitation is cast.  Applies the levitating modifier with a duration dependent on Quas, Wex, and Exort.
================================================================================================================= ]]
function invoker_retro_levitation_on_spell_start(keys)	
	--Levitate's duration is dependent on the levels of Quas, Wex, and Exort.
	local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
	local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
	local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
	
	if quas_ability ~= nil and wex_ability ~= nil and exort_ability ~= nil then
		keys.caster:EmitSound("Brewmaster_Storm.Cyclone")
		
		local average_level = (quas_ability:GetLevel() + wex_ability:GetLevel() + exort_ability:GetLevel()) / 3
		average_level = math.floor(average_level + .5)  --Round to the nearest integer.
		
		--Ensure that the average level is in-bounds, just in case.
		if average_level < 1 then
			average_level = 1
		end
		if average_level > 7 then
			average_level = 7
		end
		
		local levitation_duration = keys.ability:GetLevelSpecialValueFor("duration", average_level - 1)
		
		keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_retro_levitation", {duration = levitation_duration})
		
		--Stop the sound when the levitation ends.
		Timers:CreateTimer({
			endTime = levitation_duration,
			callback = function()
				keys.caster:StopSound("Brewmaster_Storm.Cyclone")
			end
		})
	end
end


--[[
	Author: Noya, edited by Rook
	Date: 08.02.2015.
	Progressively sends the target at a max height, then up and down between an interval, and finally back to the original ground position.
]]
function TornadoHeight( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local cyclone_height = ability:GetLevelSpecialValueFor( "cyclone_height" , ability:GetLevel() - 1 )
	local cyclone_min_height = ability:GetLevelSpecialValueFor( "cyclone_min_height" , ability:GetLevel() - 1 )
	local cyclone_max_height = ability:GetLevelSpecialValueFor( "cyclone_max_height" , ability:GetLevel() - 1 )
	local tornado_start = GameRules:GetGameTime()

	-- Position variables
	local target_initial_x = target:GetAbsOrigin().x
	local target_initial_y = target:GetAbsOrigin().y
	local target_initial_z = target:GetAbsOrigin().z
	local position = Vector(target_initial_x, target_initial_y, target_initial_z)

	local duration = 0
	
	--Levitate's duration is dependent on the levels of Quas, Wex, and Exort.
	local quas_ability = keys.caster:FindAbilityByName("invoker_retro_quas")
	local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
	local exort_ability = keys.caster:FindAbilityByName("invoker_retro_exort")
	
	if quas_ability ~= nil and wex_ability ~= nil and exort_ability ~= nil then
		local average_level = (quas_ability:GetLevel() + wex_ability:GetLevel() + exort_ability:GetLevel()) / 3
		average_level = math.floor(average_level + .5)  --Round to the nearest integer.
		
		--Ensure that the average level is in-bounds, just in case.
		if average_level < 1 then
			average_level = 1
		end
		if average_level > 7 then
			average_level = 7
		end
		
		duration = keys.ability:GetLevelSpecialValueFor("duration", average_level - 1)
	end

	-- Height per time calculation
	local time_to_reach_max_height = duration / 10
	local height_per_frame = cyclone_height * 0.03
	--print(height_per_frame)

	-- Time to go down
	local time_to_stop_fly = duration - time_to_reach_max_height
	--print(time_to_stop_fly)

	-- Loop up and down
	local going_up = true

	-- Loop every frame for the duration
	Timers:CreateTimer(function()
		local time_in_air = GameRules:GetGameTime() - tornado_start
		
		-- First send the target at max height very fast
		if position.z < cyclone_height and time_in_air <= time_to_reach_max_height then
			--print("+",height_per_frame,position.z)
			
			position.z = position.z + height_per_frame
			target:SetAbsOrigin(position)
			return 0.03

		-- Go down until the target reaches the initial z
		elseif time_in_air > time_to_stop_fly and time_in_air <= duration then
			--print("-",height_per_frame)

			position.z = position.z - height_per_frame
			target:SetAbsOrigin(position)
			return 0.03

		-- Do Up and down cycles
		elseif time_in_air <= duration then
			-- Up
			if position.z < cyclone_max_height and going_up then 
				--print("going up")
				position.z = position.z + height_per_frame/3
				target:SetAbsOrigin(position)
				return 0.03

			-- Down
			elseif position.z >= cyclone_min_height then
				going_up = false
				--print("going down")
				position.z = position.z - height_per_frame/3
				target:SetAbsOrigin(position)
				return 0.03

			-- Go up again
			else
				--print("going up again")
				going_up = true
				return 0.03
			end

		-- End
		else
			--print("End TornadoHeight")
		end
	end)
end