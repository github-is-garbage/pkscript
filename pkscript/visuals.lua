pkscript.Visuals = pkscript.Visuals or {}
local Visuals = pkscript.Visuals

Visuals.EntityCache = {} -- Force empty these
Visuals.EntityCacheKeys = {}

Visuals.EntityClasses = Visuals.EntityClasses or {
	["player"] = true,
	["prop_physics"] = true,
	["prop_dynamic"] = true
}

Visuals.Config = Visuals.Config or {}
local Config = Visuals.Config

Config.Fonts = Config.Fonts or {} -- TODO: No idea how to do this in a menu controlled by arrow keys
Config.Fonts.NameTags = pkscript.Util.ConfigDefault(Config.Fonts.NameTags, "TargetID")
Config.Fonts.Weapons = pkscript.Util.ConfigDefault(Config.Fonts.Weapons, "DefaultFixed")

Config.Materials = Config.Materials or {}
Config.Materials.Flat = Material("models/debug/debugwhite")
Config.Materials.Shiny = Material("models/shiny")
Config.Materials.Glow = CreateMaterial("pkscript_Glow", "VertexLitGeneric", {
	["$basetexture"] = "vgui/white_additive",
	["$bumpmap"] = "vgui/white_additive",

	["$ignorez"] = 0,

	["$selfillum"] = 1,
	["$selfillumFresnel"] = 1,
	["$selfillumFresnelMinMaxExp"] = "[0 1 1]",
	["$selfillumtint"] = "[0 0 0]"
})

-- Players
Config.PlayerESP = Config.PlayerESP or {}
Config.PlayerESP.Enabled = pkscript.Util.ConfigDefault(Config.PlayerESP.Enabled, true)
Config.PlayerESP.NameTags = pkscript.Util.ConfigDefault(Config.PlayerESP.NameTags, true)
Config.PlayerESP.Weapons = pkscript.Util.ConfigDefault(Config.PlayerESP.Weapons, true)
Config.PlayerESP.Health = pkscript.Util.ConfigDefault(Config.PlayerESP.Health, false)
Config.PlayerESP.Bounds = pkscript.Util.ConfigDefault(Config.PlayerESP.Bounds, false)

Config.PlayerESP.ColoredModels = Config.PlayerESP.ColoredModels or {}
Config.PlayerESP.ColoredModels.Material = pkscript.Util.ConfigDefault(Config.PlayerESP.ColoredModels.Material, "Flat")
Config.PlayerESP.ColoredModels.Color = pkscript.Util.ConfigDefault(Config.PlayerESP.ColoredModels.Color, "White")
Config.PlayerESP.ColoredModels.Enabled = pkscript.Util.ConfigDefault(Config.PlayerESP.ColoredModels.Enabled, false)
Config.PlayerESP.ColoredModels.IgnoreZ = pkscript.Util.ConfigDefault(Config.PlayerESP.ColoredModels.IgnoreZ, false)

-- Props
Config.PropESP = Config.PropESP or {}
Config.PropESP.Enabled = pkscript.Util.ConfigDefault(Config.PropESP.Enabled, true)
Config.PropESP.Bounds = pkscript.Util.ConfigDefault(Config.PropESP.Bounds, true) -- Actually hitboxes because props are dumb

Config.PropESP.ColoredModels = Config.PropESP.ColoredModels or {}
Config.PropESP.ColoredModels.Material = pkscript.Util.ConfigDefault(Config.PropESP.ColoredModels.Material, "Flat")
Config.PropESP.ColoredModels.Color = pkscript.Util.ConfigDefault(Config.PropESP.ColoredModels.Color, "White")
Config.PropESP.ColoredModels.Enabled = pkscript.Util.ConfigDefault(Config.PropESP.ColoredModels.Enabled, true)
Config.PropESP.ColoredModels.IgnoreZ = pkscript.Util.ConfigDefault(Config.PropESP.ColoredModels.IgnoreZ, false)

-- Viewmodel
Config.Viewmodel = Config.Viewmodel or {}
Config.Viewmodel.Enabled = pkscript.Util.ConfigDefault(Config.Viewmodel.Enabled, false)

Config.Viewmodel.Hands = Config.Viewmodel.Hands or {}
Config.Viewmodel.Hands.Material = pkscript.Util.ConfigDefault(Config.Viewmodel.Hands.Material, "Flat")
Config.Viewmodel.Hands.Color = pkscript.Util.ConfigDefault(Config.Viewmodel.Hands.Color, "White")
Config.Viewmodel.Hands.Enabled = pkscript.Util.ConfigDefault(Config.Viewmodel.Hands.Enabled, false)

Config.Viewmodel.Weapon = Config.Viewmodel.Weapon or {}
Config.Viewmodel.Weapon.Material = pkscript.Util.ConfigDefault(Config.Viewmodel.Weapon.Material, "Flat")
Config.Viewmodel.Weapon.Color = pkscript.Util.ConfigDefault(Config.Viewmodel.Weapon.Color, "White")
Config.Viewmodel.Weapon.Enabled = pkscript.Util.ConfigDefault(Config.Viewmodel.Weapon.Enabled, false)

function Visuals.SortEntities(A, B)
	return A:GetPos():DistToSqr(Visuals.LocalPlayerPos) > B:GetPos():DistToSqr(Visuals.LocalPlayerPos)
end

do
	local floor = math.floor
	local inf = math.huge
	local nan = 0 / 0
	local Vector = Vector

	function Visuals.GetCorners(Entity)
		local Mins, Maxs = Entity:GetCollisionBounds()
		Mins:Add(Entity:GetPos())
		Maxs:Add(Entity:GetPos())

		local Coords = {
			Mins,
			Vector(Mins.x, Maxs.y, Mins.z),
			Vector(Maxs.x, Maxs.y, Mins.z),
			Vector(Maxs.x, Mins.y, Mins.z),
			Maxs,
			Vector(Mins.x, Maxs.y, Maxs.z),
			Vector(Mins.x, Mins.y, Maxs.z),
			Vector(Maxs.x, Mins.y, Maxs.z)
		}

		local Left, Right, Top, Bottom = inf, -inf, inf, -inf

		for i = 1, #Coords do
			local Screen = Coords[i]:ToScreen()

			if not Screen.visible then
				return nan, nan, nan, nan
			end

			if Left > Screen.x then Left = Screen.x end
			if Right < Screen.x then Right = Screen.x end
			if Top > Screen.y then Top = Screen.y end
			if Bottom < Screen.y then Bottom = Screen.y end
		end

		return floor(Left), floor(Right), floor(Top), floor(Bottom)
	end
end

-- TODO: Localize stuff for ESP drawing

function Visuals.PlayerESP2D(Player)
	if not Config.PlayerESP.Enabled then return end
	if Player == pkscript.LocalPlayer then return end -- TODO: LocalPlayer options ?

	if not Player:Alive() then return end

	local Left, Right, Top, Bottom = Visuals.GetCorners(Player)
	if Left ~= Left then return end

	local Text, TextWidth, TextHeight

	if Config.PlayerESP.NameTags then
		surface.SetFont(Config.Fonts.NameTags)

		Text = Player:GetName()
		TextWidth, TextHeight = surface.GetTextSize(Text)

		local CenterX = ((Left + Right) * 0.5) - (TextWidth * 0.5)

		surface.SetTextPos(CenterX, Top - TextHeight)
		surface.DrawText(Text)
	end

	if Config.PlayerESP.Weapons then
		local Weapon = Player:GetActiveWeapon()

		if IsValid(Weapon) and Weapon:IsWeapon() then -- Some addons are retarded :/
			surface.SetFont(Config.Fonts.Weapons)

			Text = Weapon:GetPrintName()
			TextWidth, TextHeight = surface.GetTextSize(Text)

			local CenterX = ((Left + Right) * 0.5) - (TextWidth * 0.5)

			-- draw because this font has no outline :(
			-- TODO: "Custom" fonts
			draw.SimpleTextOutlined(Text, Config.Fonts.Weapons, CenterX, Bottom + TextHeight, nil, nil, nil, 1, color_black)

			-- surface.SetTextPos(CenterX, Bottom + TextHeight)
			-- surface.DrawText(Text)
		end
	end

	if Config.PlayerESP.Health then
		local MinHealth = Player:Health()
		local MaxHealth = Player:GetMaxHealth()

		local Percent = math.Clamp(MinHealth / MaxHealth, 0, 1)

		local HealthColor = pkscript.Colors.Red:Lerp(pkscript.Colors.Green, Percent)
		local HealthHeight = (Bottom - Top) * Percent

		surface.SetDrawColor(24, 24, 24, 255)
		surface.DrawRect(Left - 8, Top, 4, Bottom - Top)

		surface.SetDrawColor(HealthColor)
		surface.DrawRect(Left - 8, Bottom - HealthHeight, 4, HealthHeight)

		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawOutlinedRect(Left - 8, Top, 4, Bottom - Top)
	end
end

function Visuals.PropESP2D(Prop)
	-- TODO: ?
end

function Visuals.ESP2D()
	if #Visuals.CurrentEntities < 1 then return end -- Nothing!

	cam.Start2D() -- Fix PostDrawHUD sucking
	do
		surface.SetTextColor(255, 255, 255, 255)

		for i = 1, #Visuals.CurrentEntities do
			local Entity = Visuals.CurrentEntities[i]

			if Entity:IsPlayer() then -- TODO: This will need expanded if/when entity classes are expanded
				Visuals.PlayerESP2D(Entity)
			else
				Visuals.PropESP2D(Entity)
			end
		end
	end
	cam.End2D()
end

function Visuals.PlayerRenderOverride(Player, Flags) -- Always runs if Colored Models are enabled, no need to check it here
	if bit.band(Flags, STUDIO_RENDER) ~= STUDIO_RENDER then return end

	if not Config.PlayerESP.Enabled then -- In case ESP was disabled but Colored Models werent
		Player:DrawModel()
		return
	end

	if Config.PlayerESP.ColoredModels.IgnoreZ then
		cam.IgnoreZ(true)
	end

	local Material = Config.Materials[Config.PlayerESP.ColoredModels.Material]

	if Material == Config.Materials.Glow then
		render.SuppressEngineLighting(true)
	end

	render.MaterialOverride(Material)

	local Color = pkscript.Colors[Config.PlayerESP.ColoredModels.Color]
	render.SetColorModulation(Color.r / 255, Color.g / 255, Color.b / 255)

	Player:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride(nil)
	render.SuppressEngineLighting(false)

	cam.IgnoreZ(false)
end

function Visuals.PlayerESP3D(Player)
	if not Config.PlayerESP.Enabled then return end
	if Player == pkscript.LocalPlayer then return end -- TODO: LocalPlayer options ?

	if not Player:Alive() then return end

	if Config.PlayerESP.Bounds then
		local Mins, Maxs = Player:GetCollisionBounds()

		render.DrawWireframeBox(Player:GetPos(), angle_zero, Mins, Maxs, color_white, false)
	end

	if Config.PlayerESP.ColoredModels.Enabled then
		Player.RenderOverride = Visuals.PlayerRenderOverride
	else
		-- TODO: This has the possibility to break some things
		Player.RenderOverride = nil
	end
end

function Visuals.PropRenderOverride(Prop, Flags)
	if bit.band(Flags, STUDIO_RENDER) ~= STUDIO_RENDER then return end

	if not Config.PropESP.Enabled then
		Prop:DrawModel()
		return
	end

	if Config.PropESP.ColoredModels.IgnoreZ then
		cam.IgnoreZ(true)
	end

	local Material = Config.Materials[Config.PropESP.ColoredModels.Material]

	if Material == Config.Materials.Glow then
		render.SuppressEngineLighting(true)
	end

	render.MaterialOverride(Material)

	local Color = pkscript.Colors[Config.PropESP.ColoredModels.Color]
	render.SetColorModulation(Color.r / 255, Color.g / 255, Color.b / 255)

	Prop:DrawModel()

	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride(nil)
	render.SuppressEngineLighting(false)

	cam.IgnoreZ(false)
end

function Visuals.PropESP3D(Prop)
	if not Config.PropESP.Enabled then return end

	if Config.PropESP.Bounds then
		local DrewHitboxes = false
		local HitboxSets = Prop:GetHitboxSetCount()

		for Set = 0, HitboxSets - 1 do
			local Hitboxes = Prop:GetHitBoxCount(Set)

			for Hitbox = 0, Hitboxes - 1 do
				local Bone = Prop:GetHitBoxBone(Hitbox, Set)

				if Bone then
					local Origin, Angles
					local Matrix = Prop:GetBoneMatrix(Bone)

					if Matrix then
						Origin = Matrix:GetTranslation()
						Angles = Matrix:GetAngles()
					else
						Origin, Angles = Prop:GetBonePosition(Bone)
					end

					local Mins, Maxs = Prop:GetHitBoxBounds(Hitbox, Set)

					if Mins and Maxs then
						DrewHitboxes = true

						render.DrawWireframeBox(Origin, Angles, Mins, Maxs, color_white, false)
					end
				end
			end
		end

		if not DrewHitboxes then -- Fallback to regular bounds if it has no hitboxes
			local Mins, Maxs = Prop:GetCollisionBounds()

			render.DrawWireframeBox(Prop:GetPos(), Prop:GetAngles(), Mins, Maxs, color_white, false)
		end
	end

	if Config.PropESP.ColoredModels.Enabled then
		Prop.RenderOverride = Visuals.PropRenderOverride
	else
		-- TODO: This has the possibility to break some things
		Prop.RenderOverride = nil
	end
end

function Visuals.ESP3D()
	for i = 1, #Visuals.CurrentEntities do
		local Entity = Visuals.CurrentEntities[i]

		if Entity:IsPlayer() then
			Visuals.PlayerESP3D(Entity)
		else
			Visuals.PropESP3D(Entity)
		end
	end
end

function Visuals.PreDrawViewModel()
	if not Config.Viewmodel.Enabled then return end

	if not Config.Viewmodel.Weapon.Enabled then
		render.MaterialOverride(nil)
		render.SetColorModulation(1, 1, 1)

		return
	end

	local Material = Config.Materials[Config.Viewmodel.Weapon.Material]

	if Material == Config.Materials.Glow then
		render.SuppressEngineLighting(true)
	end

	render.MaterialOverride(Material)

	local Color = pkscript.Colors[Config.Viewmodel.Weapon.Color]
	render.SetColorModulation(Color.r / 255, Color.g / 255, Color.b / 255)
end

function Visuals.PostDrawViewModel()
	if not Config.Viewmodel.Enabled then return end

	if not Config.Viewmodel.Weapon.Enabled then
		return
	end

	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride(nil)
	render.SuppressEngineLighting(false)
end

function Visuals.PreDrawPlayerHands()
	if not Config.Viewmodel.Enabled then return end

	if not Config.Viewmodel.Hands.Enabled then
		render.MaterialOverride(nil)
		render.SetColorModulation(1, 1, 1)

		return
	end

	local Material = Config.Materials[Config.Viewmodel.Hands.Material]

	if Material == Config.Materials.Glow then
		render.SuppressEngineLighting(true)
	end

	render.MaterialOverride(Material)

	local Color = pkscript.Colors[Config.Viewmodel.Hands.Color]
	render.SetColorModulation(Color.r / 255, Color.g / 255, Color.b / 255)
end

function Visuals.PostDrawPlayerHands()
	if not Config.Viewmodel.Enabled then return end

	if not Config.Viewmodel.Hands.Enabled then
		return
	end

	render.SetColorModulation(1, 1, 1)
	render.MaterialOverride(nil)
	render.SuppressEngineLighting(false)
end

function Visuals.PrepareEntityCache()
	Visuals.CurrentEntities = {}

	for i = 1, #Visuals.EntityCache do -- Copy that can be sorted
		Visuals.CurrentEntities[#Visuals.CurrentEntities + 1] = Visuals.EntityCache[i]
	end

	Visuals.LocalPlayerPos = pkscript.LocalPlayer:GetPos()
	table.sort(Visuals.CurrentEntities, Visuals.SortEntities)
end

function Visuals.UpdateCacheIndices()
	for i = 1, #Visuals.EntityCache do
		Visuals.EntityCacheKeys[Visuals.EntityCache[i]] = i
	end
end

function Visuals.CacheEntity(Entity)
	if Visuals.EntityCacheKeys[Entity] then return end

	if Visuals.EntityClasses[Entity:GetClass()] then
		Visuals.EntityCacheKeys[Entity] = table.insert(Visuals.EntityCache, Entity)
	end
end

function Visuals.UnCacheEntity(Entity)
	if not Visuals.EntityCacheKeys[Entity] then return end

	Entity.RenderOverride = nil -- TODO: This has the possibility to break some things

	table.remove(Visuals.EntityCache, Visuals.EntityCacheKeys[Entity])
	Visuals.EntityCacheKeys[Entity] = nil

	-- table.remove shifts the indices
	Visuals.UpdateCacheIndices()
end

function Visuals.WipeEntityCache()
	for Entity, _ in next, Visuals.EntityCacheKeys do
		Visuals.UnCacheEntity(Entity)
	end
end

pkscript.Hooks.Register("PreRender", Visuals.PrepareEntityCache)
pkscript.Hooks.Register("PostDrawHUD", Visuals.ESP2D)
pkscript.Hooks.Register("PreDrawEffects", Visuals.ESP3D)
pkscript.Hooks.Register("PreDrawViewModel", Visuals.PreDrawViewModel)
pkscript.Hooks.Register("PostDrawViewModel", Visuals.PostDrawViewModel)
pkscript.Hooks.Register("PreDrawPlayerHands", Visuals.PreDrawPlayerHands)
pkscript.Hooks.Register("PostDrawPlayerHands", Visuals.PostDrawPlayerHands)
pkscript.Hooks.Register("OnEntityCreated", Visuals.CacheEntity)
pkscript.Hooks.Register("NetworkEntityCreated", Visuals.CacheEntity) -- Should be unnecessary, but doesn't hurt
pkscript.Hooks.Register("EntityRemoved", Visuals.UnCacheEntity)
pkscript.Hooks.Register("PKScript:Unload", Visuals.WipeEntityCache)

-- Initial cache
do
	for _, Entity in ents.Iterator() do
		Visuals.CacheEntity(Entity)
	end
end
