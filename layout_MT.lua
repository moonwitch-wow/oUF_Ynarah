---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------
local media = "Interface\\AddOns\\oUF_Ynarah\\media\\"
local statusbar = media.."dP"
local font = STANDARD_TEXT_FONT
local numbers = "Fonts\\skurri.TTF"
local fontSize = 11
local border = media.."border"

local ptyWidth = 135
local ptyHeight = 15
local ptyMPH = 3

---------------------------------------------------------------------
-- Stored strings and tables
---------------------------------------------------------------------

	
local colors = setmetatable({
	power = setmetatable({
		MANA = {0, 144/255, 1}
	}, {__index = oUF.colors.power}),
	reaction = setmetatable({
		[2] = {1, 0, 0},
		[4] = {1, 1, 0},
		[5] = {0, 1, 0}
	}, {__index = oUF.colors.reaction}),
	runes = setmetatable({
		[1] = {0.8, 0, 0},
		[3] = {0, 0.4, 0.7},
		[4] = {0.8, 0.8, 0.8}
	}, {__index = oUF.colors.runes})
}, {__index = oUF.colors})

---------------------------------------------------------------------
-- Converts 1000000 into 1M
---------------------------------------------------------------------
local letter = function(value) -- to shorten HP/MP strings at full
	if(value >= 1e6) then
		return gsub(format("%.2fm", value / 1e6), "%.?0+([km])$", "%1")
	elseif(value >= 1e4) then
		return gsub(format("%.1fk", value / 1e3), "%.?0+([km])$", "%1")
	else
		return value
	end
end

---------------------------------------------------------------------
-- Custom tags
---------------------------------------------------------------------
oUF.Tags["[AFK]"] = function(unit) return UnitIsAFK(unit) and "|cffff0000A|r" end
oUF.Tags["[DND]"] = function(unit) return UnitIsDND(unit) and "|cffff00ffD|r" end

oUF.Tags["[colorpp]"] = function(unit) -- from p3lim"s excellently coded layout
	local num, str = UnitPowerType(unit)
	local c = colors.power[str]
	return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
end

oUF.Tags["[shortname]"] = function(u)
	local name = UnitName(u)
	return (string.len(name) > 10) and string.gsub(name, "%s?(.)%S+%s", "%1. ") or name
end

oUF.TagEvents["[AFK]"] = "PLAYER_FLAGS_CHANGED"
oUF.TagEvents["[DND]"] = "PLAYER_FLAGS_CHANGED"
oUF.TagEvents["[Rest]"] = "PLAYER_UPDATE_RESTING"
oUF.TagEvents["[shortname]"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags["[assisticon]"] = function(u) local i = GetRaidTargetIndex(u.."target") return i and ICON_LIST[i]..'22|t' end
oUF.Tags["[assistname]"] = function(u) return UnitName(u.."target") end


---------------------------------------------------------------------
-- Aura Skinning
---------------------------------------------------------------------
local auraIcon = function(self, button, icons, index, debuff)
	icons.showType = true
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 2)
	button.overlay:SetTexture(border)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
	button.icon:SetTexCoord(.07, .93, .07, .93)
end

---------------------------------------------------------------------
-- Custom fontcreation
---------------------------------------------------------------------
local SetFontString = function(parent, fontName, fontHeight, point, anchor, rPoint, xoffset, yoffset)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight)
	fs:SetPoint(point, anchor, rPoint, xoffset, yoffset)
	fs:SetShadowColor(0, 0, 0, .7)
	fs:SetShadowOffset(1, -1)
	return fs
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
local func_of_party = function(self, unit, settings)
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
	self:Tag(self.Name, "[raidcolor][shortname( )] [offline( )] [AFK( )]|cff00ffff[( - )assistname( )][assisticon]")
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

	self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
	self.Leader:SetHeight(14)
	self.Leader:SetWidth(14)
	self.Leader:SetPoint("CENTER", self.Health, "TOPLEFT", 16, 0)
	self.Leader:SetTexture(media.."leader.tga")
	self.Leader:SetVertexColor(188/255, 152/255, 126/255)

	self.MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
	self.MasterLooter:SetHeight(14)
	self.MasterLooter:SetWidth(14)
	self.MasterLooter:SetPoint("CENTER", self.Leader, 16, -16)
	self.MasterLooter:SetTexture(media.."looter.tga")
	self.MasterLooter:SetVertexColor(188/255, 152/255, 126/255)
end

oUF:RegisterStyle("Ynarah_party", func_of_party)
oUF:SetActiveStyle("Ynarah_party")
--[[
local party = oUF:Spawn("header", "oUF_Party")
party:SetManyAttributes("showParty", true, "yOffset", 40, "point", "BOTTOM")
party:SetPoint("LEFT", oUF.units.target, "RIGHT", 150, -150)
party:Show()
]]
local tank = oUF:Spawn('header', 'oUF_MainTank')
tank:SetManyAttributes('showRaid', true, 'groupFilter', 'MAINTANK', 'yOffset', -15)
tank:SetPoint('TOP', UIParent, 0, -30)
tank:Show()
--[[
local assist = oUF:Spawn('header', 'oUF_MainAssist')
assist:SetManyAttributes('showRaid', true, 'groupFilter', 'MAINASSIST', 'yOffset', -15)
assist:SetPoint('TOP', oUF_MainTank, 0, -30)
assist:Show()
]]