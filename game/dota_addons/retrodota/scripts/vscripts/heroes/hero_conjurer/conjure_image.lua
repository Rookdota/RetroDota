--[[
	Author: Noya, with modifications by wFX
	Date: 10.1.2015.
	Creates an Illusion, making use of the built in modifier_illusion
]]
function ConjureImageOnSpellStart( event )
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerID()
	local ability = event.ability
	local unit_name = target:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

	-- handle_UnitOwner needs to be nil, else it will crash the game.
	local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetControllableByPlayer(player, true)
	if illusion:IsHero() then
		illusion:SetPlayerID(caster:GetPlayerID())
		local targetLevel = target:GetLevel()
		for i=1,targetLevel-1 do
			illusion:HeroLevelUp(false)
		end

		illusion:SetAbilityPoints(0)
		for abilitySlot=0,15 do
			local ability = target:GetAbilityByIndex(abilitySlot)
			if ability ~= nil then 
				local abilityLevel = ability:GetLevel()
				local abilityName = ability:GetAbilityName()
				local illusionAbility = illusion:FindAbilityByName(abilityName)
				illusionAbility:SetLevel(abilityLevel)
			end
		end

		for itemSlot=0,5 do
			local item = target:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
			end
		end
	end

	-- if caster:HasModifier("modifier_metamorphosis") then
	-- 	local meta_ability = caster:FindAbilityByName("terrorblade_metamorphosis_datadriven")
	-- 	meta_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_metamorphosis", nil)
	-- end

	-- Set the unit as an illusion
	-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

end