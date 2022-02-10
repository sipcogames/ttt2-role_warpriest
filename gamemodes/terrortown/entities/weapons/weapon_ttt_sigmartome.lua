AddCSLuaFile()

SWEP.PrintName = "Tome of Sigmar"
SWEP.Category = "TTT2"
SWEP.Author = "SipcoGames"
SWEP.Contact = "info@sipcogames.ca"
SWEP.Purpose = "Slap other to heal or hurt them."
SWEP.Instructions = "Primary attack - Heal/Hurt. Secondary - Throw. Reload - Praise Sigmar"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.AdminOnly = false

SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/c_arms.mdl"
SWEP.ViewModelFlip = false
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {}
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.EquipMenuData = {
    type = "sigmartome",
    desc = "Preach through pain."
}

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = nil -- only traitors can buy
SWEP.LimitedStock = true -- only buyable once
SWEP.IsSilent = true
SWEP.DeploySpeed = 2
SWEP.NoSights = true
SWEP.AutoSpawnable = false
SWEP.Icon = "vgui/ttt/icon_knife"
SWEP.IconLetter = "c"
SWEP.InLoadoutFor = nil

if SERVER then
    resource.AddFile("materials/vgui/ttt/icon_knife.vmt")
end

local ST = {}
ST.healsounds = {Sound("weapons/sigmartome/heal1.wav",100,100),Sound("weapons/sigmartome/heal2.wav",100,100),Sound("weapons/sigmartome/heal3.wav",100,100),Sound("weapons/sigmartome/heal4.wav",100,100)}
ST.hurtsounds = {Sound("weapons/sigmartome/hurt1.wav",100,100),Sound("weapons/sigmartome/hurt2.wav",100,100),Sound("weapons/sigmartome/hurt3.wav",100,100),Sound("weapons/sigmartome/hurt4.wav",100,100)}
ST.chantsounds = {Sound("weapons/sigmartome/chant1.wav",100,100),Sound("weapons/sigmartome/chant2.wav",100,100),Sound("weapons/sigmartome/chant3.wav",100,100),Sound("weapons/sigmartome/chant4.wav",100,100)}

SWEP.Slot = 8
SWEP.SlotPos = 1

SWEP.UseHands = true
SWEP.HoldType = "slam"

SWEP.FiresUnderwater = true
SWEP.DrawCrosshair = false
SWEP.DrawAmmo = true
SWEP.ReloadSound = ""
SWEP.Base = "weapon_tttbase"

SWEP.Primary.Delay			= 3
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay		= 10
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.ThrownHoldType 		= "normal"
SWEP.ShowViewModel 			= true
SWEP.ShowWorldModel 		= true

SWEP.TossDelay 				= 15
SWEP.HealSound 				= ST.healsounds[math.random(1,4)]

local ClassName 			= SWEP.ClassName

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_Spine4"] = {scale = Vector(1,1,1), pos = Vector(0,0,1), angle = Angle(10,0,0)},
	["ValveBiped.Grenade_body"] = {scale = Vector(0.009,0.009,0.009), pos = Vector(0,0,0), angle = Angle(0,0,0)}
}

SWEP.VElements = {
	["Book"] = {type = "Model", model = "models/props_lab/binderblue.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5,4.349,-5.1), angle = Angle(0,105,0), size = Vector(0.56,0.56,0.56), color = Color(150,125,125,255), surpresslightning = false, material = "", skin = 0, bodygroup = {}}
}

SWEP.WElements = {
	["Book"] = {type = "Model", model = "models/props_lab/binderblue.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.199,3.9,-4), angle = Angle(0,110,0), size = Vector(0.625,0.625,0.625), color = Color(150,125, 125,255), surpresslightning = false, material = "", skin = 0, bodygroup = {}}
}

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 	0, "D20")
	self:NetworkVar("Float", 	1, "NextSwing")
	self:NetworkVar("Float", 	2, "NextChant")
	self:NetworkVar("Float", 	3, "NextThrow")
	self:NetworkVar("Bool", 	0, "ThrownState")
end

function SWEP:Initialize()

	self:SetHoldType(self.HoldType)
	self:SetNextSwing(CurTime())
	self:SetNextChant(CurTime())
	self:SetNextThrow(CurTime())
	self:SetThrownState(false)
	
	-- SWEP Construction Kit code

	if CLIENT then

		self.VElements = table.FullCopy(self.VElements)
		self.WElements = table.FullCopy(self.WElements)
		self.ViewModelBoneMods = table.FullCopy(self.ViewModelBoneMods)

		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)

		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function PlayTomeSounds(type, wep)

	if (wep:GetNextChant() < CurTime()) then
		
		local chant

		if (type == "heal") then --heal sounds 
		
			chant = ST.healsounds[math.random(1,4)]

		elseif (type == "hurt") then --hurt sounds
		
			chant = ST.hurtsounds[math.random(1,4)]

		else --chant sounds
		
			chant = ST.chantsounds[math.random(1,4)]

		end

		--check duration and play chant
		local duration = SoundDuration(chant)
		if not (game.SinglePlayer() and CLIENT) then
			wep.Owner:EmitSound(chant, 100, 120, 1, CHAN_VOICE)
		end
		wep:SetNextChant(CurTime() + duration)
		--end Chant
	end
end

function SWEP:Deploy()
	self.ResetAnimation = nil
	self:SetNextSwing(CurTime())
	return true
end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	if SERVER and IsValid(self.Owner) then
		self.Owner:DrawViewModel(true)
		self.Owner:DrawWorldModel(true)
	end
	
	self.Swing = nil
	self.AttemptHit = nil
	self.ResetAnimation = nil
	self:SetNextSwing(CurTime())

	return true
	
end

function SWEP:ResetState()

	if self:GetThrownState() then
		if SERVER and IsValid(self.Owner) then 
			self.Owner:DrawViewModel(true)
			self.Owner:DrawWorldModel(true)
			self.Owner:EmitSound("items/ammo_pickup.wav", 100, 100)
		end
		self:SetHoldType(self.HoldType)
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self:SetThrownState(false)
		self:SetNextSwing(CurTime())
		self:SetNextThrow(CurTime())
		self:SetNextPrimaryFire(CurTime())
	else
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
	end
	
end

function SWEP:Think()

	if self.Swing and self.Swing < CurTime() then
		self.Weapon:SendWeaponAnim(ACT_VM_THROW)
		if not (game.SinglePlayer() and CLIENT) then
			self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 100, 80)
		end
		self.Swing = nil
	end
	
	if self.AttemptHit and self.AttemptHit < CurTime() then
	
		self.Owner:LagCompensation(true)
	
		local tr = {}
		tr.start = self.Owner:GetShootPos()
		tr.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 50
		tr.filter = self.Owner
		tr.mins = Vector(-10,-10,-8)
		tr.maxs = Vector(10,10,8)
		tr.mask = MASK_SHOT_HULL
		
		local res = util.TraceLine(tr)
		
		if not IsValid(res.Entity) then
			res = util.TraceHull(tr)
		end
		
		if res.Hit then
		
			if not (game.SinglePlayer() and CLIENT) then
				self.Weapon:EmitSound("physics/body/body_medium_impact_hard"..math.random(1,6)..".wav", 100, 100)
			end
			
			local ent = res.Entity

			local TOME_MODE = GetConVar("ttt2_warpriest_tome_mode"):GetInt()
			local TOME_HEAL = GetConVar("ttt2_warpriest_tome_healing"):GetInt()
			
			if IsValid(ent) then

				if ((TOME_MODE == 0) or (TOME_MODE == 1 and ent:GetTeam() ~= TEAM_TRAITOR) or (TOME_MODE == 2 and ent:GetTeam() == TEAM_INNOCENT)) then --heal types (0=all, 1=innocents and others, 2=only innocents, 3=none)
					if ((ent:IsPlayer() or ent:IsNPC()) and ent:Health() > 0) then --heal script
					
						local bless = EffectData()
						bless:SetEntity(ent)
						bless:SetOrigin(ent:GetPos())
						util.Effect("rj_blessedbeam", bless)
						
						--Heal Target
						if((ent:GetMaxHealth() < TOME_HEAL and ent:Health() < ent:GetMaxHealth()) or (ent:Health() + TOME_HEAL) >= ent:GetMaxHealth()) then -- if overhealing
							ent:SetHealth(ent:GetMaxHealth())
						else
							ent:SetHealth(ent:Health() + TOME_HEAL)
						end
						
						if not (game.SinglePlayer() and CLIENT) then
							PlayTomeSounds("heal",self)
						end
					end
				else --hurt types (If fails condition or mode = 3)

					if SERVER then

						local dmg = DamageInfo()

						if IsValid(self.Owner) then 
							dmg:SetAttacker(self.Owner)
						else
							dmg:SetAttacker(self)
						end
						
						dmg:SetDamage(TOME_HEAL)
						dmg:SetInflictor(self.Weapon)
						dmg:SetDamagePosition(res.HitPos)
						dmg:SetDamageType(DMG_CLUB)
						ent:TakeDamageInfo(dmg)
						
					end
					
					if not (game.SinglePlayer() and CLIENT) and ent:IsPlayer() then
						ent:EmitSound("ambient/voices/citizen_beaten"..math.random(1,5)..".wav", 100, 100, 1, CHAN_VOICE)
						PlayTomeSounds("hurt",self)
					end

				end
				
				local vecSub = res.HitPos-self.Owner:GetShootPos()
				local vecFinal = vecSub:GetNormalized() * 5000
				local phys = ent:GetPhysicsObject()	
				
				if IsValid(phys) then
					phys:ApplyForceOffset(vecFinal,res.HitPos)
				else
					ent:SetVelocity(vecFinal)
				end

			end
			
		end
		
		self.AttemptHit = nil
		self.Owner:LagCompensation(false)
		
	end
	
	if self.Throw and self.Throw < CurTime() and IsValid(self.Owner) then
	
		self:SetThrownState(true)
		self:SetHoldType(self.ThrownHoldType)

		if not (game.SinglePlayer() and CLIENT) then
			self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 100, 60)
		end
		
		if SERVER then
		
			self.Owner:DrawViewModel(false)
			self.Owner:DrawWorldModel(false)

			local book = ents.Create("rj_book_thrown")
			
			if book then
			
				book.Owner = self.Owner
				book.Inflictor = self.Weapon
				local eyeang = self.Owner:GetAimVector():Angle()
				local right = eyeang:Right()
				local up = eyeang:Up()			
				book:SetPos(self.Owner:GetShootPos() + right * 4 - up * 2)
				book:SetAngles(self.Owner:GetAngles())
				book:Spawn()
				book:Fire("kill",1,self.TossDelay)
				
				local phys = book:GetPhysicsObject()
				
				if phys then
					phys:SetVelocity(self.Owner:GetAimVector() * 1500)
					phys:ApplyForceOffset(Vector(0,0,100), phys:GetPos() + Vector(-10,0,-10))
				end
			
			end

		end

		self.Throw = nil
		
	end
	
	if self:GetThrownState() and IsValid(self.Owner) then
		self:SetHoldType(self.ThrownHoldType)
		if SERVER then
			self.Owner:DrawViewModel(false)
			self.Owner:DrawWorldModel(false)
		end
	end

	if self:GetNextThrow() < CurTime() and self:GetThrownState() then
		self:ResetState()
	end
	
	if self.ResetAnimation and self.ResetAnimation < CurTime() then
		self:ResetState()
		self.ResetAnimation = nil
	end
	
end

function SWEP:PrimaryAttack()
	if self:GetNextSwing() < CurTime() then
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
		self:SetD20(math.random(1,20))
		self.Swing = CurTime() + 0.15
		self.AttemptHit = CurTime() + 0.3
		self.ResetAnimation = CurTime() + 0.4
		self:SetNextSwing(CurTime() + self.Primary.Delay)
		self:SetNextThrow(CurTime() + self.Primary.Delay)
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	end
end

function SWEP:SecondaryAttack()
	if self:GetNextThrow() < CurTime() and not self:GetThrownState() then
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
		self.Throw = CurTime() + 0.15
		self:SetNextSwing(CurTime() + self.TossDelay)
		self:SetNextThrow(CurTime() + self.TossDelay)
		self:SetNextPrimaryFire(CurTime() + self.TossDelay)
		PlayTomeSounds("hurt",self)
	end
end

function SWEP:Reload()
	PlayTomeSounds("chant",self)
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	-- SWEP Construction Kit code

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		
		local vm = self.Owner:GetViewModel()
		if not IsValid(vm) then return end
		
		if not self.VElements then return end
		
		self:UpdateBonePositions(vm)

		if not self.vRenderOrder then

			self.vRenderOrder = {}

			for k, v in pairs(self.VElements) do
				if v.type == "Model" then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs(self.vRenderOrder) do
		
			local v = self.VElements[name]
			
			if not v then 
				self.vRenderOrder = nil 
				break 
			end
			
			if v.hide then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if not v.bone then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if not pos then continue end
			
			if v.type == "Model" and IsValid(model) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)
				
				if v.material == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= v.material then
					model:SetMaterial(v.material)
				end
				
				if v.skin and v.skin ~= model:GetSkin() then
					model:SetSkin(v.skin)
				end
				
				if v.bodygroup then
					for k,v in pairs(v.bodygroup) do
						if model:GetBodygroup(k) ~= v then
							model:SetBodygroup(k,v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if v.surpresslightning then
					render.SuppressEngineLighting(false)
				end
				
			elseif v.type == "Sprite" and sprite then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif v.type == "Quad" and v.draw_func then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()

			end
			
		end
		
	end

	SWEP.wRenderOrder = nil
	
	function SWEP:DrawWorldModel()
		
		if self.ShowWorldModel == nil or self.ShowWorldModel then
			self:DrawModel()
		end
		
		if not self.WElements then return end
		
		if not self.wRenderOrder then

			self.wRenderOrder = {}

			for k,v in pairs(self.WElements) do
				if v.type == "Model" then
					table.insert(self.wRenderOrder, 1, k)
				elseif v.type == "Sprite" or v.type == "Quad" then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if IsValid(self.Owner) then
			bone_ent = self.Owner
		else
			bone_ent = self
		end
		
		for k,name in pairs(self.wRenderOrder) do
		
			local v = self.WElements[name]
			
			if not v then 
				self.wRenderOrder = nil 
				break
			end
			
			if v.hide then continue end
			
			local pos, ang
			
			if v.bone then
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
			else
				pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
			end
			
			if not pos then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if v.type == "Model" and IsValid(model) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix("RenderMultiply", matrix)
				
				if v.material == "" then
					model:SetMaterial("")
				elseif model:GetMaterial() ~= v.material then
					model:SetMaterial(v.material)
				end
				
				if v.skin and v.skin ~= model:GetSkin() then
					model:SetSkin(v.skin)
				end
				
				if v.bodygroup then
					for k,v in pairs(v.bodygroup) do
						if model:GetBodygroup(k) ~= v then
							model:SetBodygroup(k,v)
						end
					end
				end
				
				if v.surpresslightning then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
				render.SetBlend(v.color.a / 255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if v.surpresslightning then
					render.SuppressEngineLighting(false)
				end
				
			elseif v.type == "Sprite" and sprite then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif v.type == "Quad" and v.draw_func then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func(self)
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)
		
		local bone, pos, ang
		if (tab.rel and tab.rel ~= "") then
			
			local v = basetab[tab.rel]
			
			if not v then return end
			
			pos, ang = self:GetBoneOrientation(basetab, v, ent)
			
			if not pos then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if not bone then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if m then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if IsValid(self.Owner) and self.Owner:IsPlayer() and ent == self.Owner:GetViewModel() and self.ViewModelFlip then
				ang.r = -ang.r
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels(tab)

		if not tab then return end

		for k, v in pairs(tab) do
			if v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model and string.find(v.model,".mdl") and file.Exists(v.model,"GAME")) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if IsValid(v.modelEnt) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite) and file.Exists("materials/"..v.sprite..".vmt", "GAME") then
				
				local name = v.sprite.."-"
				local params = {["$basetexture"] = v.sprite}
				local tocheck = {"nocull", "additive", "vertexalpha", "vertexcolor", "ignorez"}
				for i, j in pairs(tocheck) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
				
			end
		end
		
	end
	
	local allbones = {}
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if not vm:GetBoneCount() then return end

			local loopthrough = self.ViewModelBoneMods
			
			if not hasGarryFixedBoneScalingYet then
			
				allbones = {}
				
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
				
			end
			
			for k,v in pairs(loopthrough) do
			
				local bone = vm:LookupBone(k)
				if not bone then continue end

				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				
				if not hasGarryFixedBoneScalingYet then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms

				if vm:GetManipulateBoneScale(bone) ~= s then
					vm:ManipulateBoneScale(bone, s)
				end
				if vm:GetManipulateBoneAngles(bone) ~= v.angle then
					vm:ManipulateBoneAngles(bone, v.angle)
				end
				if vm:GetManipulateBonePosition(bone) ~= p then
					vm:ManipulateBonePosition(bone, p)
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if not vm:GetBoneCount() then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale(i, Vector(1,1,1))
			vm:ManipulateBoneAngles(i, Angle(0,0,0))
			vm:ManipulateBonePosition(i, Vector(0,0,0))
		end
		
	end

	function table.FullCopy(tab)

		if not tab then return nil end
		
		local res = {}
		for k,v in pairs(tab) do
			if type(v) == "table" then
				res[k] = table.FullCopy(v)
			elseif type(v) == "Vector" then
				res[k] = Vector(v.x,v.y,v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p,v.y,v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end

local ENT = {}

ENT.Type = "anim"  
ENT.Base = "base_anim"
ENT.PrintName = "Blessed Book"

if CLIENT then
	function ENT:Draw()
		self:DrawModel()	
	end
end

if SERVER then

	function ENT:Initialize()

		self:SetModel("models/props_lab/binderblue.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetColor(Color(150,125,125,255))
		
		local phys = self:GetPhysicsObject()  	
		if IsValid(phys) then 
			phys:Wake()
			phys:SetMass(10)
			phys:SetBuoyancyRatio(1)
			phys:SetMaterial("paper")
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		end
		
		if IsValid(self.Owner) then
			self:SetPhysicsAttacker(self.Owner)
		end
		
		self.Hit = false
		self.Combo = false

	end
	
	function ENT:PhysicsCollide(data)
	
		if not self.Collided then

			local ent = data.HitEntity
			
			if IsValid(ent) and (ent:IsNPC() or (ent:IsPlayer() and IsValid(self.Owner) and ent ~= self.Owner)) then
			
				local dmg = DamageInfo()

				dmg:SetAttacker(self.Owner)
				
				if IsValid(self.Inflictor) then
					dmg:SetInflictor(self.Inflictor)
				else
					dmg:SetInflictor(self)
				end
				
				dmg:SetDamage(10)
				dmg:SetDamagePosition(data.HitPos)
				dmg:SetDamageForce(self:GetVelocity():GetNormalized() * 200)
				dmg:SetDamageType(DMG_CLUB)
				
				ent:TakeDamageInfo(dmg)
				
				sound.Play("physics/body/body_medium_impact_hard"..math.random(1,6)..".wav", self:GetPos(), 100, 100)
				
				if ent:IsPlayer() then
					ent:EmitSound("ambient/voices/citizen_beaten"..math.random(1,5)..".wav", 100, 100, 1, CHAN_VOICE)
				end
				
			end
			
			self.Collided = true
			
		end
		
	end
	
	function ENT:Touch(ent)
	
		if ent:IsPlayer() and self.Collided then
		
			local wep = ent:GetActiveWeapon()

			if IsValid(wep) and wep:GetClass() == ClassName and wep:GetThrownState() then
				wep:ResetState()
				self:Remove()
			end
		
		end
		
	end
	
end

scripted_ents.Register(ENT, "rj_book_thrown", true)

if CLIENT then

	local Beam = {}

	Beam.Mat1 		= Material("trails/laser")
	Beam.Mat2 		= Material("sprites/tp_beam001")
	Beam.Mat3 		= Material("trails/plasma")
	Beam.Mat4 		= Material("sprites/physbeam")
	Beam.Ring1 		= Material("effects/combinemuzzle1_nocull")
	Beam.Ring3 		= Material("effects/rollerglow")
	Beam.Refract 	= Material("effects/strider_pinch_dudv")

	function Beam:Init(data)

		self.Ent = data:GetEntity()
		
		if not self.Ent then return end
		
		self.EndPos = data:GetOrigin()

		local tr = util.TraceLine({start = self.EndPos, endpos = (self.EndPos + Vector(0,0,99999)), filter = self.Ent, mask = MASK_SHOT})
		
		self.StartPos = tr.HitPos
		self.Normal = self.Ent:GetUp():GetNormalized()
		
		if self.Normal then
			self.NormalAng = data:GetNormal():Angle() + Angle(0.01, 0.01, 0.01)
		end
		
		if not self.StartPos then return end
		
		self.Dir = self.EndPos-self.StartPos
		
		self.Width = 3
		self.Shrink = 20
		
		self:SetRenderBoundsWS(self.StartPos, self.EndPos)

		self.FadeDelay = 0.3
		self.FadeTime = CurTime() + self.FadeDelay
		self.DieTime = CurTime() + 1.5
		
		self.Alpha = 255
		self.FadeSpeed = 0.5
		
		self.Emitter = ParticleEmitter(self.StartPos)
		
		sound.Play("weapons/mortar/mortar_explode"..math.random(1,3)..".wav", self.EndPos, 100, 100)
		
		for i=1,8 do
		
			local muzz = self.Emitter:Add("effects/combinemuzzle2", self.StartPos)
			
			if muzz then
				muzz:SetColor(255, 200, 100)
				muzz:SetRoll(math.Rand(0, 360))
				muzz:SetDieTime(self.FadeDelay + self.FadeSpeed)
				muzz:SetStartSize(15)
				muzz:SetStartAlpha(255)
				muzz:SetEndSize(0)
				muzz:SetEndAlpha(100)
			end
		
		end
		
		for i=1,8 do
		
			local impact = self.Emitter:Add("effects/combinemuzzle1_nocull", self.EndPos)
			
			if impact then	
				impact:SetColor(255, 200, 100)
				impact:SetRoll(math.Rand(0, 360))
				impact:SetDieTime(self.FadeDelay + self.FadeSpeed)
				impact:SetStartSize(10)
				impact:SetStartAlpha(255)
				impact:SetEndSize(0)
				impact:SetEndAlpha(200)
				impact:SetAngles(self.NormalAng)
			end
		
		end
		
		local imp = EffectData()
		imp:SetOrigin(self.EndPos)
		util.Effect("rj_blessedbeam_impact", imp)

	end

	function Beam:Think()
	
		if self.FadeTime and CurTime() > self.FadeTime then
			self.Alpha = Lerp(13 * self.FadeSpeed * FrameTime(), self.Alpha, 0)
			self.Shrink = Lerp(2 * self.FadeSpeed * FrameTime(), self.Shrink, 0)
		end
	
		if self.DieTime and CurTime() > self.DieTime then
			return false
		end
		
		return true
		
	end

	function Beam:Render()
		if self.Width and self.Alpha then
			self.Width = math.Max(self.Width - 0.5, 0)
			local endPos = self.EndPos
			render.SetMaterial(self.Mat1)
			render.DrawBeam(endPos, self.StartPos, self.Shrink + (self.Width * 50), 1, 0, Color(255,200,255,self.Alpha))
			render.SetMaterial(self.Mat2)
			render.DrawBeam(endPos, self.StartPos, self.Shrink * 1.25 + (self.Width * 50), 1, 0, Color(255,200,100,self.Alpha))
			render.SetMaterial(self.Mat3)
			render.DrawBeam(endPos, self.StartPos, self.Shrink * 1.5 + (self.Width * 50), 1, 0, Color(255,255,100,self.Alpha))
			render.SetMaterial(self.Mat4)
			render.DrawBeam(endPos, self.StartPos, self.Shrink/7 + (self.Width * 50) , 1, 0, Color(255,200,100,self.Alpha))
			render.SetMaterial(self.Ring1)
			render.DrawQuadEasy(self:GetPos(), self.Normal, 300, 300, Color(255,255,200,self.Alpha))
			render.SetMaterial(self.Ring3)
			render.DrawQuadEasy(self:GetPos(), self.Normal, 300, 300, Color(255,200,100,self.Alpha))
		end
	end

	effects.Register(Beam, "rj_blessedbeam", true)
	
	local Impact = {}
	
	Impact.Refract = Material("effects/strider_pinch_dudv")
	
	function Impact:Init(data)
	
		self.Pos = data:GetOrigin()

		self.LerpSize = 200
		self.EndSize = 1250
		
		self.LerpRefract = 1
		
		self.DieTime = CurTime() + 0.5
		self.FadeSpeed = 5
		
		self.Emitter = ParticleEmitter(self.Pos)
		self.Emitter:SetNearClip(128,192)
		
		local vOrig = self.Pos
		
		for i=1,8 do
		
			local flash = self.Emitter:Add("effects/combinemuzzle1_nocull", vOrig)
			
			if flash then
			
				flash:SetColor(255, 255, 255)
				flash:SetVelocity(VectorRand():GetNormal() * math.random(10, 1000))
				flash:SetRoll(math.Rand(0, 360))
				flash:SetDieTime(0.10)
				flash:SetLifeTime(0)
				flash:SetStartSize(50)
				flash:SetStartAlpha(255)
				flash:SetEndSize(255)
				flash:SetEndAlpha(0)
				flash:SetGravity(Vector(0,0,0))		
				
			end
		
		end
		
	end
	
	function Impact:Think()
	
		self.LerpSize = Lerp(2 * self.FadeSpeed * FrameTime(), self.LerpSize, self.EndSize)
		self.LerpRefract = Lerp(2 * self.FadeSpeed * FrameTime(), self.LerpRefract, 0)
	
		if self.DieTime and CurTime() > self.DieTime then
			return false
		end
		
		return true
		
	end
	
	function Impact:Render()
		render.SetMaterial(self.Refract)
		render.UpdateRefractTexture()
		self.Refract:SetFloat("$refractamount", self.LerpRefract * 0.75)
		render.DrawQuadEasy(self.Pos + Vector(0,0,1), Vector(0,0,1), self.LerpSize, self.LerpSize)
		render.DrawQuadEasy(self.Pos + Vector(0,0,1), Vector(0,0,-1), self.LerpSize, self.LerpSize)
	end
	
	effects.Register(Impact,"rj_blessedbeam_impact",true)

end