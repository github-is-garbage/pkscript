local PANEL = {}

AccessorFunc(PANEL, "m_iBarHeight", "BarHeight", FORCE_NUMBER)
AccessorFunc(PANEL, "m_strFont", "Font", FORCE_STRING)
AccessorFunc(PANEL, "m_colText", "TextColor", FORCE_COLOR)
AccessorFunc(PANEL, "m_strText", "Text", FORCE_STRING)

PANEL.GradientUp = Material("gui/gradient_up")

function PANEL:Init()
	self:SetBarHeight(24)

	self:SetFont(pkscript.Menu.Font)
	self:SetTextColor(color_white)
	self:SetText("PK Script")
end

function PANEL:SetBarHeight(Height)
	self.m_iBarHeight = tonumber(Height) or 24

	self:DockPadding(1, self:GetBarHeight(), 1, 1)
end

function PANEL:SetupChild(Child)
	if isfunction(Child.SetFont) then
		Child:SetFont(self:GetFont())
	end
end

function PANEL:PaintBackground(Width, Height)
	local BarHeight = self:GetBarHeight() - 1 -- Offset for border

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(0, 0, Width, Height)
	surface.DrawLine(0, BarHeight, Width, BarHeight)

	surface.SetDrawColor(24, 24, 24, 255)
	surface.DrawRect(1, 1, Width - 2, BarHeight - 1)

	surface.SetMaterial(self.GradientUp)
	surface.SetDrawColor(self:GetAccentColor())
	surface.DrawTexturedRect(1, BarHeight * 0.25, Width - 2, (BarHeight * 0.75) + 1)
end

function PANEL:PaintForeground(Width, Height)
	local BarHeight = self:GetBarHeight()

	surface.SetFont(self:GetFont())
	surface.SetTextColor(self:GetTextColor())

	local Text = self:GetText()
	local TextWidth, TextHeight = surface.GetTextSize(Text)

	surface.SetTextPos((Width * 0.5) - (TextWidth * 0.5), (BarHeight * 0.5) - (TextHeight * 0.5))
	surface.DrawText(Text)
end

function PANEL:AddOption(Label, Table, Key, Type)
	local Option = vgui.Create("pkscript_Option")

	if not IsValid(Option) then
		error("Failed to create option!")
		return nil
	end

	Option:SetParent(self)
	Option:Dock(TOP)

	Option:SetFont(self:GetFont())
	Option:SetText(Label)

	Option:SetVarTable(Table)
	Option:SetVarKey(Key)
	Option:SetVarType(Type)

	return Option
end

function PANEL:FocusOption()
	local Option = self:GetChildren()[1]

	if IsValid(Option) then
		Option:RequestFocus()
	end
end

function PANEL:OnKeyCodePressed(Key)
	if Key == KEY_UP then
		print("frame up")
	elseif Key == KEY_DOWN then
		print("frame down")
	end

	self:FocusOption()
end

function PANEL:Show()
	self:SetVisible(true)

	self:FocusOption()
end

vgui.Register("pkscript_Frame", PANEL, "pkscript_Base")
