--[[
	Author: Noya and wFX with help of Rook
	Date: 18.01.2015.
	Gets the summoning location for the new unit
]]
function SummonLocation(event)
    local caster = event.caster
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()
    
    -- Gets the vector facing 200 units away from the caster origin
	local front_position = origin + fv * 200

    local result = { }
    table.insert(result, front_position)

    return result
end

-- Set the units looking at the same point of the caster
function SetUnitsMoveForward(event)
	local caster = event.caster
	local target = event.target
    local fv = caster:GetForwardVector()
    local origin = caster:GetAbsOrigin()

	target:SetForwardVector(fv)

end

function invoker_retro_scout_on_spell_start(event)
    local caster = event.caster
    local ability = event.ability
    local wex_ability = caster:FindAbilityByName("invoker_retro_wex")
    if wex_ability ~= nil then

        local owl = CreateUnitByName("npc_dota_invoker_retro_scout_unit", caster:GetAbsOrigin(), true, nil, nil, caster:GetTeam())
        local wex_level = wex_ability:GetLevel()

        for i = 0, wex_level, 1 do
            ability:ApplyDataDrivenModifier(caster, owl, "modifier_invoker_retro_scout_movespeed_per_wex", {duration = -1})
        end

--      Set the dymanic vision
--      local owl_vision = 300 + (wex_level * 100)
--      TODO: Make the pure scale and check why the other 2 functions are popping errors
        owl.vOwner = caster:GetOwner()
        owl:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true)
        owl:AddNewModifier(owl, nil, "modifier_kill", {duration = wex_level * 10})

        SummonLocation(event)
        SetUnitsMoveForward(event)

    end
end