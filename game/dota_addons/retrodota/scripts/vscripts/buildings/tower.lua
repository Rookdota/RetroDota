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

	if time > 0 and caster:HasModifier("modifier_invulnerable") and not END_GAME_ON_KILLS then
		caster:RemoveModifierByName("modifier_invulnerable")
		print("Tower is now vulnerable")
	end
end



-- Gives gold to everyone on the killer's team (for radiant towers)
function GiveTeamTowerGold( event )
	local killer = event.attacker
	local allHeroes = HeroList:GetAllHeroes()
	local team_gold = 200

	for k,v in pairs(allHeroes) do
		if v:GetPlayerID() and v:GetTeam() == killer:GetTeam() then
			v:ModifyGold(team_gold, true, 0)
			PopupGoldGain(v, team_gold)
		end
	end
end

-- Keeps an index to the tree of line in the units handle
function FindTreeOfLife( event )
	local caster = event.caster
	local tree = Entities:FindByModel(nil, "models/props_tree/tree_cine_01_10k.vmdl")
	print(tree)

	caster.ancient = tree

end


-- Checks if the tree was glyphed and applies the glyph to the tower if so
function CheckGlyphUsage( event )
	local caster = event.caster
	local ancient = caster.ancient
 	if ancient:HasModifier("modifier_fountain_glyph") and not caster:HasModifier("modifier_fountain_glyph") then
 		print("Glyph used! Applying it to this tower")
 		caster:AddNewModifier(caster, nil, "modifier_fountain_glyph", {duration = 5.0})
 	end
 end 