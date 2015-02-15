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
	--Therefore, the oldest orb is located in [1], and the newest is located in [3].
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
	Called when Quas, Wex, or Exort is upgraded.  Levels the effects of any currently existing orbs.
================================================================================================================= ]]
function invoker_orb_retro_on_upgrade(keys)
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end

	--Reapply all the orbs Invoker has out in order to benefit from the upgraded ability's level.  By reapplying all
	--three orb modifiers, they will maintain their order on the modifier bar (so long as all are removed before any
	--are reapplied, since ordering problems arise there are two of the same type of orb otherwise).
	while keys.caster:HasModifier("modifier_invoker_quas_instance_retro") do
		keys.caster:RemoveModifierByName("modifier_invoker_quas_instance_retro")
	end
	while keys.caster:HasModifier("modifier_invoker_wex_instance_retro") do
		keys.caster:RemoveModifierByName("modifier_invoker_wex_instance_retro")
	end
	while keys.caster:HasModifier("modifier_invoker_exort_instance_retro") do
		keys.caster:RemoveModifierByName("modifier_invoker_exort_instance_retro")
	end
	
	for i=1, 3, 1 do
		if keys.caster.invoked_orbs[i] ~= nil then
			local orb_name = keys.caster.invoked_orbs[i]:GetName()
			if orb_name == "invoker_quas_retro" then
				local quas_ability = keys.caster:FindAbilityByName("invoker_quas_retro")
				if quas_ability ~= nil then
					quas_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_quas_instance_retro", nil)
				end
			elseif orb_name == "invoker_wex_retro" then
				local wex_ability = keys.caster:FindAbilityByName("invoker_wex_retro")
				if wex_ability ~= nil then
					wex_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_wex_instance_retro", nil)
				end
			elseif orb_name == "invoker_exort_retro" then
				local exort_ability = keys.caster:FindAbilityByName("invoker_exort_retro")
				if exort_ability ~= nil then
					exort_ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_invoker_exort_instance_retro", nil)
				end
			end
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