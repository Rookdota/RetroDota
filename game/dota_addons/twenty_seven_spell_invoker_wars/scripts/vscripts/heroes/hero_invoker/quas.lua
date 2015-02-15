--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Quas is cast.
================================================================================================================= ]]
function invoker_quas_retro_on_spell_start(keys)
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_quas_retro", nil)
	
end