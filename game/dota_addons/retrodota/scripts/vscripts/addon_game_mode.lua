require("timers")
require("physics")
require("popups")
require("retrodota")
require("lib.statcollection")

statcollection.addStats({
	modID = '599fb911391cf8660b988e9a030a4f29' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})

--------------------------------------------------------------------------------
-- PRECACHE
--------------------------------------------------------------------------------
function Precache(context)
	--Precache relevant particle effects.  Custom units with all of Invoker's spells are used to precache because there is an issue with
	--precaching using datadriven blocks when a spell is swapped in for a hero, and most of Invoker's spells are.
	PrecacheUnitByNameSync("npc_dota_invoker_retro_precache_unit_1", context)
	PrecacheUnitByNameSync("npc_dota_invoker_retro_precache_unit_2", context)
	
	--Precache creep-related models.
	PrecacheResource("model", "models/heroes/furion/treant.vmdl", context)
	PrecacheResource("model", "models/items/furion/treant/furion_treant_nelum_red/furion_treant_nelum_red.vmdl", context)
	PrecacheResource("model", "models/heroes/undying/undying_minion.vmdl", context)
	PrecacheResource("model", "models/items/undying/idol_of_ruination/ruin_wight_minion.vmdl", context)
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.RetroDota = RetroDota()
    GameRules.RetroDota:InitGameMode()
end