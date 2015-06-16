--[[
	Author: wFX
	Date: 15.6.2015.
	Creates Summons
]]
function SummonWaterElementalOnSpellStart( event )
	local caster = event.caster
	local ability = event.ability
	local duration = ability:GetSpecialValueFor('summon_duration')
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local golem = CreateUnitByName('conjurer_water_elemental_level_' .. (ability:GetLevel()), origin, true, caster, caster, caster:GetTeamNumber())
	if golem ~= nil then
		golem:SetControllableByPlayer(caster:GetPlayerID(), true)
		golem:AddNewModifier(caster, ability, 'modifier_kill', {duration = duration})
	end
end