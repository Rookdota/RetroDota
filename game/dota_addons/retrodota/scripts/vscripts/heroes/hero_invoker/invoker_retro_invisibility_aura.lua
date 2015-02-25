--[[
	Author: Rook
	Date: 23.02.2015.
	Adds invisibility to nearby units.
	Additional parameters: keys.FadeTime
]]
function modifier_invoker_retro_invisibility_aura_on_interval_think(keys)
	local wex_ability = keys.caster:FindAbilityByName("invoker_retro_wex")
	
	if keys.ability == nil then  --If Invisibility Aura is not invoked anymore.
		keys.caster:RemoveAbility("modifier_invoker_retro_invisibility_aura_ability")
	else
		local radius = keys.ability:GetLevelSpecialValueFor("radius", wex_ability:GetLevel() - 1)

		local nearby_ally_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

		for i, individual_unit in ipairs(nearby_ally_units) do
			if keys.caster ~= individual_unit then  --Invisibility Aura does not make Invoker invisible.
				if individual_unit:HasModifier("modifier_invoker_retro_invisibility_aura_effect") then  --Immediately apply the invis if the unit is already invis.
					keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_retro_invisibility_aura_effect", nil)
				else  --Apply the invis after the fade delay if the unit is not already invis.
					Timers:CreateTimer({
						endTime = keys.FadeTime,
						callback = function()
							keys.ability:ApplyDataDrivenModifier(keys.caster, individual_unit, "modifier_invoker_retro_invisibility_aura_effect", nil)
						end
					})
				end
			end
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: 23.02.2015.
	Called regularly while under the effects of Invisibility Aura.  Repeatedly apply the stock modifier_invisible
	for the sole purpose of making the unit have a transparent texture.  This can be gotten rid of when we discover
	how to apply a translucent texture manually.
================================================================================================================= ]]
function modifier_invoker_retro_invisibility_aura_effect_on_interval_think(keys)
	keys.target:AddNewModifier(keys.caster, keys.ability, "modifier_invisible", {duration = .1})
end