--[[ ============================================================================================================
	Author: Noya
	Date: March 19, 2015
	Applies Invulnerability to the tower, removes it when the clock hits 0:00, removes ancient invuln when 2 towers are destroyed
================================================================================================================= ]]

function ApplyInvulnerability( event )
	local caster = event.caster
	caster:AddNewModifier(caster, nil, "modifier_invulnerable", {})

	-- Add 1 to the Tree Invuln Count
	if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		if GameRules.TreeInvulnerability then
			GameRules.TreeInvulnerability = GameRules.TreeInvulnerability + 1
		else
			GameRules.TreeInvulnerability = 1
		end
	elseif caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		if GameRules.ThroneInvulnerability then
			GameRules.ThroneInvulnerability = GameRules.ThroneInvulnerability + 1
		else
			GameRules.ThroneInvulnerability = 1
		end
	end
end

function ReduceInvulnerabilityCount( event )
	local caster = event.caster
	local ancients = Entities:FindAllByClassname('npc_dota_fort')

	if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		GameRules.TreeInvulnerability = GameRules.TreeInvulnerability - 1
		print("Reduced Tree Invulnerability Count to "..GameRules.TreeInvulnerability)

	elseif caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		GameRules.ThroneInvulnerability = GameRules.ThroneInvulnerability - 1
		print("Reduced Throne Invulnerability Count to "..GameRules.ThroneInvulnerability)
	end

	
	if GameRules.ThroneInvulnerability <= 0 then		
		for k,v in pairs(ancients) do
			print(k,v,v:GetTeam(),caster:GetTeam())
	        if v:GetTeam() == caster:GetTeam()then
	            v:RemoveModifierByName("modifier_invulnerable")
	        end
	    end
	elseif GameRules.TreeInvulnerability <= 0 then
		for k,v in pairs(ancients) do
			print(k,v,v:GetTeam(),caster:GetTeam())
	        if v:GetTeam() == caster:GetTeam()then
	            v:RemoveModifierByName("modifier_invulnerable")
	        end
	    end
	end
end


function InvulnerabilityCheck( event )
	local caster = event.caster
	local time = GameRules:GetDOTATime(false, false)

	if time > 0 and caster:HasModifier("modifier_invulnerable") then
		caster:RemoveModifierByName("modifier_invulnerable")
		print("Tower is now vulnerable")
	end
end