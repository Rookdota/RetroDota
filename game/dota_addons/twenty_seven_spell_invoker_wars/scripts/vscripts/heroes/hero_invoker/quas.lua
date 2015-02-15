--[[ ============================================================================================================
	Author: Rook
	Date: February 15, 2015
	Called when Quas is cast.
================================================================================================================= ]]
function invoker_quas_retro_on_spell_start(keys)
	if keys.caster.invoked_orbs == nil then
		keys.caster.invoked_orbs = {}
	end
	
	--Invoker can only have three orbs active at any time.  Each time an orb is activated, its hscript is
	--placed into keys.caster.invoked_orbs[3], the old [3] is moved into [2], and the old [2] is moved into [1].
	if keys.caster.invoked_orbs[1] ~= nil then
		keys.caster:RemoveModifierByName(keys.caster.invoked_orbs[1]:GetName())
	end
	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_invoker_quas_retro", nil)
	
	keys.caster.invoked_orbs[1] = keys.caster.invoked_orbs[2]
	keys.caster.invoked_orbs[2] = keys.caster.invoked_orbs[3]
	keys.caster.invoked_orbs[3] = keys.ability
	
	--TODO: The control points for this particle still need to be figured out.
	local quas_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf", PATTACH_OVERHEAD_FOLLOW, keys.caster)
end