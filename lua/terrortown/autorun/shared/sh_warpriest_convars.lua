--ConVar syncing
CreateConVar("ttt2_warpriest_armor", "50", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_warpriest_tome_mode", "1", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_warpriest_tome_healing", "50", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_warpriest_force_model", "1", {FCVAR_ARCHIVE, FCVAR_NOTFIY})
CreateConVar("ttt2_warpriest_max_health", "150", {FCVAR_ARCHIVE, FCVAR_NOTFIY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicWarPriestCVars", function(tbl)
	tbl[ROLE_WARPRIEST] = tbl[ROLE_WARPRIEST] or {}

	table.insert(tbl[ROLE_WARPRIEST], {
		cvar = "ttt2_warpriest_armor",
		slider = true,
		min = 0,
		max = 100,
		decimal = 0,
		desc = "ttt2_warpriest_armor [0..100] (Def: 50)"
	})

	table.insert(tbl[ROLE_WARPRIEST], {
		cvar = "ttt2_warpriest_tome_mode",
		combobox = true,
		desc = "ttt2_warpriest_tome_mode (Def: 1)",
		choices = {
			"0 - Tome Heals Everyone",
			"1 - Tome Harms Traitors, Heals Others",
			"2 - Tome Harms Others, Heals Innocents",
			"3 - Tome Harms Everyone"
		},
		numStart = 0
	})

	table.insert(tbl[ROLE_WARPRIEST], {
		cvar = "ttt2_warpriest_tome_healing",
		slider = true,
		min = 0,
		max = 100,
		decimal = 0,
		desc = "ttt2_warpriest_tome_healing [0..100] (Def: 50)"
	})

	table.insert(tbl[ROLE_WARPRIEST], {
    cvar = "ttt2_warpriest_force_model",
    checkbox = true,
    desc = "ttt2_warpriest_force_model (Def. 1)"
    })

    table.insert(tbl[ROLE_WARPRIEST], {
		cvar = "ttt2_warpriest_max_health",
		slider = true,
		min = 1,
		max = 300,
		decimal = 0,
		desc = "ttt2_warpriest_max_health [1..300] (Def: 150)"
	})
end)
