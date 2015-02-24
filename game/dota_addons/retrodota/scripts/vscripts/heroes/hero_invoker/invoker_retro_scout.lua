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

        ability:ApplyDataDrivenModifier(caster, owl, "modifier_invoker_retro_scout", {})

        ability:ApplyDataDrivenModifier(caster, owl, "modifier_invoker_retro_scout_movespeed_per_wex", {})
        owl:SetModifierStackCount("modifier_invoker_retro_scout_movespeed_per_wex", ability, wex_level)

        ability:ApplyDataDrivenModifier(caster, owl, "modifier_invoker_retro_scout_vision_per_wex", {})
        owl:SetModifierStackCount("modifier_invoker_retro_scout_vision_per_wex", ability, wex_level)

        owl.vOwner = caster:GetOwner()
        owl:SetControllableByPlayer(caster:GetOwner():GetPlayerID(), true)
        owl:AddNewModifier(owl, nil, "modifier_kill", {duration = wex_level * 10})
        owl:FindAbilityByName("true_sight"):SetLevel(1)
    end
end