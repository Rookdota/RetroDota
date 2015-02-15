--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Removes the third-to-most-recent orb created (if applicable) to make room for the newest orb.
================================================================================================================= ]]
function invoker_remove_oldest_orb(keys)
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	
	--Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
	--placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
	if keys.caster.invoked_orbs[1] ~= nil then
		local orb_name = keys.caster.invoked_orbs[1]:GetName()
		if orb_name == "invoker_quas_retro" then
			keys.caster:RemoveModifierByName("modifier_invoker_quas_instance_retro")
		elseif orb_name == "invoker_wex_retro" then
			keys.caster:RemoveModifierByName("modifier_invoker_wex_instance_retro")
		elseif orb_name == "invoker_exort_retro" then
			keys.caster:RemoveModifierByName("modifier_invoker_exort_instance_retro")
		end
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Quas is cast.
================================================================================================================= ]]
function invoker_quas_retro_on_spell_start(keys)
	invoker_remove_oldest_orb(keys)
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_quas_instance_retro", nil)
	
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Wex is cast.
================================================================================================================= ]]
function invoker_wex_retro_on_spell_start(keys)
	invoker_remove_oldest_orb(keys)
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_wex_instance_retro", nil)
	
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
end


--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Exort is cast.
================================================================================================================= ]]
function invoker_exort_retro_on_spell_start(keys)
	invoker_remove_oldest_orb(keys)
	
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_exort_instance_retro", nil)
	
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
end