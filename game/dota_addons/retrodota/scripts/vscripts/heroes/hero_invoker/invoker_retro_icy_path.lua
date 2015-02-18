--[[ ============================================================================================================
	Author: Rook
	Date: February 16, 2015
	Called when Icy Path is cast.
	Additional parameters: keys.NumWallElements, keys.WallElementSpacing, and keys.WallElementRadius
================================================================================================================= ]]
function invoker_retro_icy_path_on_spell_start(keys)
	local target_point = keys.target_points[1]
	
	local icy_path_unit = CreateUnitByName("npc_dota_invoker_retro_icy_path_unit", target_point, false, nil, nil, keys.caster:GetTeam())
	local icy_path_unit_ability = icy_path_unit:FindAbilityByName("invoker_retro_icy_path_unit_ability")
	
	if icy_path_unit_ability ~= nil then
		icy_path_unit_ability:SetLevel(1)
	end
end