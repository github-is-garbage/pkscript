pkscript.Menu = pkscript.Menu or {}
local Menu = pkscript.Menu

Menu.Font = "DebugOverlay" -- Default

include("pkscript/menu/base.lua")
include("pkscript/menu/frame.lua")
include("pkscript/menu/option.lua")
include("pkscript/menu/dropdown.lua")

function Menu.IsMenuKey(Key)
	local Bind = input.LookupKeyBinding(Key)
	if not Bind then return false end

	if string.find(Bind, "pkscript_menu") then
		return true
	else
		return false
	end
end

function Menu.Destroy()
	Menu.Close()

	if IsValid(Menu.Instance) then
		Menu.Instance:Remove()
		Menu.Instance = nil
	end
end

function Menu.Setup()
	Menu.Destroy()

	local Instance = vgui.Create("pkscript_Frame")

	if not IsValid(Instance) then
		return false
	end

	Instance:SetWidth(ScreenScale(100))
	Instance:SetHeight(ScreenScaleH(250))
	Instance:SetPos(10, 10)

	Menu.Instance = Instance

	Menu.Build()
	Menu.Close() -- Start hidden

	return true
end

function Menu.Open()
	if not IsValid(Menu.Instance) and not Menu.Setup() then
		error("Failed to create menu!")
		return
	end

	Menu.Instance:Show()
	Menu.Instance:MakePopup()
end

function Menu.Close()
	if not IsValid(Menu.Instance) then return end

	Menu.Instance:Hide()
end

function Menu.Toggle()
	if not IsValid(Menu.Instance) and not Menu.Setup() then
		error("Failed to create menu!")
		return
	end

	if Menu.Instance:IsVisible() then
		Menu.Close()
	else
		Menu.Open()
	end
end

function Menu.UnRegister()
	-- Unregister VGUI panel class
	local Name, Variable = debug.getupvalue(vgui.GetControlTable, 1)

	if Name == "PanelFactory" and istable(Variable) then
		for Class, _ in next, Variable do
			if string.StartsWith(Class, "pkscript_") then
				Variable[Class] = nil
			end
		end
	end

	-- Unregister baseclass class
	Name, Variable = debug.getupvalue(baseclass.Get, 1)

	if Name == "BaseClassTable" and istable(Variable) then
		for Class, _ in next, Variable do
			if string.StartsWith(Class, "pkscript_") then
				Variable[Class] = nil
			end
		end
	end
end

pkscript.Hooks.Register("PKScript:Unload", Menu.UnRegister)
pkscript.Hooks.Register("OnScreenSizeChanged", Menu.Destroy)

concommand.Add("pkscript_menu", Menu.Toggle)
