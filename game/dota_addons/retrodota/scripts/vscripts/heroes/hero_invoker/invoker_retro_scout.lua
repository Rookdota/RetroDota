--[[
	Author: wFX with help of Rook and Noya
	Date: 18.01.2015.
	Gets the summoning location for the new unit
]]

function invoker_retro_scout_on_spell_start(event)
    local caster = event.caster
    local ability = event.ability
    local wex_ability = caster:FindAbilityByName("invoker_retro_wex")
    if wex_ability ~= nil then
        local wex_level = wex_ability:GetLevel()
        -- Gets the vector facing 200 units away from the caster origin    
        local fv = caster:GetForwardVector()
        local origin = caster:GetAbsOrigin()
        local front_position = origin + fv * 200
		
        local owl = CreateUnitByName("npc_dota_invoker_retro_scout_unit", front_position, true, nil, nil, caster:GetTeam())
        owl:SetForwardVector(fv)
		local owl_ability = owl:FindAbilityByName("invoker_retro_scout_unit_ability")
		if owl_ability ~= nil then
			owl_ability:SetLevel(1)
			
			owl_ability:ApplyDataDrivenModifier(caster, owl, "modifier_invoker_retro_scout_unit_ability", {})

			owl_ability:ApplyDataDrivenModifier(caster, owl, "modifier_invoker_retro_scout_unit_ability_movespeed_per_wex", {})
			owl:SetModifierStackCount("modifier_invoker_retro_scout_unit_ability_movespeed_per_wex", ability, wex_level)

			owl_ability:ApplyDataDrivenModifier(caster, owl, "modifier_invoker_retro_scout_unit_ability_vision_per_wex", {})
			owl:SetModifierStackCount("modifier_invoker_retro_scout_unit_ability_vision_per_wex", ability, wex_level)

			owl.vOwner = caster:GetOwner()
			owl:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true)
			owl:AddNewModifier(owl, nil, "modifier_kill", {duration = wex_level * 10})
			owl:AddNewModifier(owl, nil, "modifier_invisible", nil)
		end
    end
end


--[[
	Author: wFX with help of Rook and Noya
	Date: 18.01.2015.
	Removes invisibility from nearby units.
]]
function modifier_invoker_retro_scout_unit_ability_on_interval_think(keys)
	local nearby_enemy_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.caster:GetCurrentVisionRange(), DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	for i, individual_unit in ipairs(nearby_enemy_units) do
		keys.ability:ApplyDataDrivenModifier(individual_unit, keys.caster, "modifier_invoker_retro_scout_unit_ability_reveal", {})
	end
end