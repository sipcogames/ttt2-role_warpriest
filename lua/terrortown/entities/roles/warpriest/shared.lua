if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_warp.vmt")
end

-- Make sure sound/model is precached
function ROLE:Precache()
	util.PrecacheModel("models/player/saltz1.mdl")
end

WarP = {}

WarP.model = util.IsValidModel("models/player/saltz1.mdl") and Model("models/player/saltz1.mdl") or Model("models/player/kleiner.mdl")
WarP.sounds = {Sound("ttt2/warp_spawn1.wav", 100, 100),Sound("ttt2/warp_spawn2.wav", 100, 100),Sound("ttt2/warp_spawn3.wav", 100, 100)}

function ROLE:PreInitialize()
	self.color = Color(255, 215, 0, 255)

	self.abbr = "warp"
	self.score.surviveBonusMultiplier = 1
	--self.score.timelimitMultiplier = -0.5
	self.score.killsMultiplier = 8
	self.score.teamKillsMultiplier = -8
	self.score.bodyFoundMuliplier = 3
	self.unknownTeam = true

	self.defaultTeam = TEAM_INNOCENT
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.isOmniscientRole = true
	self.isPublicRole = true
	self.isPolicingRole = true

	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 8,
		minKarma = 600,

		credits = 1,
		creditsAwardDeadEnable = 1,
		creditsAwardKillEnable = 0,

		togglable = true,
		shopFallback = SHOP_FALLBACK_DETECTIVE
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_DETECTIVE)
end

if SERVER then

	-- Give Loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		
		-- Give Tome of Sigmar
		ply:GiveEquipmentWeapon("weapon_ttt_sigmartome")

		-- Set Armor and HP
		ply:GiveArmor(GetConVar("ttt2_warpriest_armor"):GetInt())
		ply:SetHealth(GetConVar("ttt2_warpriest_max_health"):GetInt())
		ply:SetMaxHealth(GetConVar("ttt2_warpriest_max_health"):GetInt())

		-- emit spawn noise
		ply:EmitSound(WarP.sounds[math.random(1,3)])
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)

		-- Remove Tome of Sigmar
		ply:StripWeapon("weapon_ttt_sigmartome")

		--Reset Armor and Health
		ply:RemoveArmor(GetConVar("ttt2_warpriest_armor"):GetInt())
		ply:SetHealth(100)
		ply:SetMaxHealth(100)
	end

	hook.Add("TTT2UpdateSubrole", "UpdateWarpriestRoleSelect", function(ply, oldSubrole, newSubrole)
		if GetConVar("ttt2_warpriest_force_model"):GetBool() then
			if newSubrole == ROLE_WARPRIEST then
				ply:SetSubRoleModel(WarP.model)
			elseif oldSubrole == ROLE_WARPRIEST then
				ply:SetSubRoleModel(nil)
			end
		end
	end)
end

if CLIENT then
  function ROLE:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

    form:MakeSlider({
      serverConvar = "ttt2_warpriest_armor",
      label = "ttt2_warpriest_armor",
      min = 0,
      max = 100,
      decimal = 0
    })

    form:MakeComboBox({
    	serverConvar = "ttt2_warpriest_tome_mode",
    	label = "ttt2_warpriest_tome_mode [Use ULX or Console]",
    	choices = {
				"0 - Tome Heals Everyone",
				"1 - Tome Harms Traitors, Heals Others",
				"2 - Tome Harms Others, Heals Innocents",
				"3 - Tome Harms Everyone"
			},
		numStart = 0
    })

    form:MakeSlider({
      serverConvar = "ttt2_warpriest_tome_healing",
      label = "ttt2_warpriest_tome_healing",
      min = 0,
      max = 100,
      decimal = 0
    })

    form:MakeCheckBox({
      serverConvar = "ttt2_warpriest_force_model",
      label = "ttt2_warpriest_force_model"
    })

    form:MakeSlider({
      serverConvar = "ttt2_warpriest_max_health",
      label = "ttt2_warpriest_max_health",
      min = 1,
      max = 300,
      decimal = 0
    })

  end
end
