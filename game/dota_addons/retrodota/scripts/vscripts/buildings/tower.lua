--[[ ============================================================================================================
	Author: Noya
	Date: March 19, 2015
	Applies Invulnerability to the tower, removes it when the clock hits 0:00, removes ancient invuln when 2 towers are destroyed
================================================================================================================= ]]

function ApplyInvulnerability( event )
	local caster = event.caster
	caster:AddNewModifier(caster, nil, "modifier_invulnerable", {})

	-- Add 1 to the Ancient Invuln Count
	if GameRules.AncientInvulnerability then
		GameRules.AncientInvulnerability = GameRules.AncientInvulnerability + 1
	else
		GameRules.AncientInvulnerability = 1
	end
end

function ReduceInvulnerabilityCount( event )
	GameRules.AncientInvulnerability = GameRules.AncientInvulnerability - 1

	if GameRules.AncientInvulnerability <= 0 then
		local caster = event.caster
		local ancients = Entities:FindAllByClassname('npc_dota_fort')
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