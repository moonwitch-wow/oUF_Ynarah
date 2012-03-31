---------------------------------------------------------------------
-- Namespacing teh shit out of this
---------------------------------------------------------------------
local _, oUFYna = ...

---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------
local media = "Interface\\AddOns\\oUF_Ynarah\\media\\"
local statusbar = "Interface\\TargetingFrame\\UI-StatusBar"
local font = STANDARD_TEXT_FONT
local numbers = "Fonts\\skurri.TTF"
local fontSize = 11
--local border = media..'border.tga'
local border = media..'gloss.tga'

local ptyWidth = 135
local ptyHeight = 15
local ptyMPH = 3

local bossWidth = 175
local bossHeight = 20

---------------------------------------------------------------------
-- Aura Skinning
---------------------------------------------------------------------
local PostCreateAura = function(element, button)
	button.showType = true
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 2)
	button.overlay:SetTexture(border)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
	button.icon:SetTexCoord(.07, .93, .07, .93)
end

local PostUpdateDebuff = function(element, unit, button, index)
	if(UnitIsFriend("player", unit) or button.isPlayer) then
		local _, _, _, _, type = UnitAura(unit, index, button.filter)
		local color = DebuffTypeColor[type] or DebuffTypeColor.none

		button:SetBackdropColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
		--button.icon:SetDesaturated(false)
		button.overlay:SetTexture(border)
		button.overlay:SetTexCoord(0, 1, 0, 1)
		button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
		button.icon:SetTexCoord(.07, .93, .07, .93)
	else
		button:SetBackdropColor(0, 0, 0)
		--button.icon:SetDesaturated(true)
		button.overlay:SetTexture(border)
		button.overlay:SetTexCoord(0, 1, 0, 1)
		button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
		button.icon:SetTexCoord(.07, .93, .07, .93)
	end
end

---------------------------------------------------------------------
-- HP BG Updater
---------------------------------------------------------------------
local updateHealthBG = function(self, event, unit, bar, min, max)
	if (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
		local color = self.colors.tapped
		bar.bg:SetVertexColor(color[1] * 0.4, color[2] * 0.4, color[3]* 0.4)
	else
		local _, class = UnitClass(unit)
		local color =  UnitIsPlayer(unit) and self.colors.class[class] or {1,1,1}
		bar.bg:SetVertexColor(color[1] * 0.4, color[2] * 0.4, color[3]* 0.4)
	end
end

---------------------------------------------------------------------
-- Func of doom
---------------------------------------------------------------------
local func_of_raid = function(self, unit, settings)
	self.colors = colors
	
	self.menu = menu
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	self:SetBackdrop{
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		insets = {left = -2, right = -2, top = -2, bottom = -5},
	}
	self:SetBackdropColor(0, 0, 0, .4)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetPoint("TOPRIGHT", self)
	self.Health:SetPoint("TOPLEFT", self)
	self.Health:SetStatusBarTexture(statusbar)
	self.Health:SetHeight(ptyHeight)
	self.Health:SetStatusBarColor(100/255, 111/255, 101/255)
	self.Health.frequentUpdates = true
	self.Health.Smooth = true
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER", self)
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetAlpha(.4)

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -3)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Power:SetStatusBarTexture(statusbar)
	self.Power:SetHeight(ptyMPH)
	self.Power.frequentUpdates = true
	self.Power.Smooth = true
	self.Power.colorClass = true
	self.Power.bg = self.Power:CreateTexture(nil, "BORDER", self)
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetAlpha(.4)

	self.Name = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "RIGHT", 2, 0)
	self:Tag(self.Name, "[raidcolor][yna:shortname] [offline<)] [yna:AFKDND<]")
	self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
	self:Tag(self.Health.value, "[curhp] ([perhp]%)")
	self.Power.value = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
	self.Tag(self.Power.value, "[colorpp]")

	self.Castbar = CreateFrame("StatusBar")
	self.Castbar:SetBackdrop{
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
		insets = {left = -2, right = -2, top = -2, bottom = -2},
	}
	self.Castbar:SetBackdropColor(0, 0, 0, .3)

	self.Castbar:SetWidth(ptyWidth)
	self.Castbar:SetHeight(ptyMPH)
	self.Castbar:SetParent(self.Health)
	self.Castbar:SetPoint("TOP", self.Power, "BOTTOM", 0, -4)
	self.Castbar:SetStatusBarTexture(statusbar)
	self.Castbar:SetStatusBarColor(45/255, 21/255, 53/255)

	self.Castbar:SetMinMaxValues(1, 100)
	self.Castbar:SetValue(1)
	self.Castbar:Hide()

	self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.bg:SetAllPoints(self.Castbar)
	self.Castbar.bg:SetAlpha(0.4)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetPoint("LEFT", self.Castbar, 2, 0)
	self.Castbar.Text:SetWidth(ptyWidth)
	self.Castbar.Text:SetFont(font, fontSize)
	self.Castbar.Text:SetTextColor(1, 1, 1)
	self.Castbar.Text:SetJustifyH"LEFT"
	self.Castbar.Text:SetShadowOffset(1, -1)

	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "BACKGROUND")
	self.Castbar.Icon:SetHeight(ptyHeight)
	self.Castbar.Icon:SetWidth(ptyHeight)
	self.Castbar.Icon:SetTexCoord(.07, .93, .07, .93)
	self.Castbar.Icon:SetPoint("RIGHT", self.Health, "LEFT", -5, -2)
		
	self.Castbar.Icon.overlay = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon.overlay:SetAllPoints(self.Castbar.Icon)
	self.Castbar.Icon.overlay:SetTexture(border)

	self.PVP = SetFontString(self.Health, font, 13, "RIGHT", self.Health, "LEFT", 0, 0)
	self.PVP:SetTextColor(1, 0, 0)
	self:Tag(self.PVP, "[pvp]")

	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetHeight(14)
	self.RaidIcon:SetWidth(14)
	self.RaidIcon:SetPoint("RIGHT", self, "LEFT")

	if(IsAddOnLoaded("oUF_CombatFeedback")) then
		self.CombatFeedbackText = SetFontString(self.Health, font, fontSize+1, "CENTER", self.Health, "CENTER", 0, 0)
		self.CombatFeedbackText:SetShadowOffset(1, -1)
		self.CombatFeedbackText:SetShadowColor(0, 0, 0)
	end

	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	self.DebuffHighlightAlpha = .5

	self.PostUpdateHealth = updateHealthBG
	
	if(not unit) then 
		self.SpellRange = true
		self.Range = true
		self.inRangeAlpha = 1.0
		self.outsideRangeAlpha = 0.4
		self.Power.Smooth = true
		self.Health.Smooth = true
		self.MoveableFrames = true
	end

	-- Attributing width and height to shit
	self:SetAttribute("initial-height", ptyHeight+ptyMPH)
	self:SetAttribute("initial-width", ptyWidth)
	self.Power:SetHeight(ptyMPH)
end
