---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------
local media = "Interface\\AddOns\\oUF_Ynarah\\media\\"
local statusbar = media.."dX"
local font = STANDARD_TEXT_FONT
local numbers = "Fonts\\skurri.TTF"
local fontSize = 11
local border = media.."border"

local hpHeight = 20 -- height of healthbar of player/target/tot/focus/pet and height of castbar
local ppHeight = 8 -- height of powerbar of player/target/pet
local plWidth = 325 -- width of player/target and width of castbar
local focWidth = 185 -- width of tot/focus

local _, playerClass = UnitClass("player")

---------------------------------------------------------------------
-- Stored strings and tables
---------------------------------------------------------------------
--[[	class = setmetatable({
		["DEATHKNIGHT"] = {130/255, 32/255, 49/255},
		["DRUID"] = {181/255, 86/255, 0},
		["HUNTER"] = {106/255, 140/255, 60/255},
		["MAGE"] = {33/255, 142/255, 184/255},
		["PALADIN"] = {175/255, 39/255, 101/255},
		["PRIEST"] = {223/255, 223/255, 223/255},
		["ROGUE"] = {207/255, 193/255, 24/255},
		["SHAMAN"] = {19/255, 166/255, 166/255},
		["WARLOCK"] = {118/255, 101/255, 167/255},
		["WARRIOR"] = {146/255, 103/255, 56/255}
	}, {__index = oUF.colors.class}),
	]]
	
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
-- Right click player menu
---------------------------------------------------------------------
local function menu(self)
	local unit = string.gsub(self.unit, "(.)", string.upper, 1)
	if(_G[unit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
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
		local color =  UnitIsPlayer(unit) and self.colors.class[class] or self.colors.reaction[UnitReaction(unit, "player")] or {1,1,1}
		bar.bg:SetVertexColor(color[1] * 0.4, color[2] * 0.4, color[3]* 0.4)
	end
end

---------------------------------------------------------------------
-- Hellish function (the actual style)
---------------------------------------------------------------------
local func_of_doom = function(self, unit, settings)
	self.colors = colors
	
	self.menu = menu
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	if unit == "player" or unit == "target" then
		self:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			insets = {left = -2, right = -2, top = -2, bottom = -5},
		}
		self:SetBackdropColor(0, 0, 0, .4)
	elseif unit == "focus" or unit == "focustarget" then
		self:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			insets = {left = -2, right = -2, top = -2, bottom = -6},
		}
		self:SetBackdropColor(0, 0, 0, .4)
	else
		self:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			insets = {left = -2, right = -2, top = -2, bottom = -2},
		}
		self:SetBackdropColor(0, 0, 0, .3)
	end

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetPoint("TOPRIGHT", self)
	self.Health:SetPoint("TOPLEFT", self)
	self.Health:SetStatusBarTexture(statusbar)
	self.Health:SetHeight(hpHeight)
	self.Health:SetStatusBarColor(100/255, 111/255, 101/255)
	self.Health.frequentUpdates = true
	
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER", self)
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetAlpha(.4)

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -3)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Power:SetStatusBarTexture(statusbar)
	self.Power:SetHeight(ppHeight)
	self.Power.frequentUpdates = true

	self.Power.colorClass = true
	self.Power.colorTapped = true
	self.Power.colorReaction = true
	
	self.Power.bg = self.Power:CreateTexture(nil, "BORDER", self)
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetAlpha(.4)
	
	if unit == "player" then
		self.Power.value = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self.Power.value:SetTextColor(1, 1, 1)
		self:Tag(self.Power.value, "[colorpp][curpp]|r ")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[curhp]")
	elseif unit == "target" then
		self.Info = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self.Info:SetTextColor(1, 1, 1)
		self:Tag(self.Info, "[colorpp][curpp]|r [(- )cpoints( CP)] | [curhp] ([perhp]%)")
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Name,"L[difficulty][smartlevel] [race] [raidcolor][shortname] [dead]")
	elseif unit == "focus" or unit == "focustarget" then
		self.Name = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self:Tag(self.Name, "[raidcolor][shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[curpp]|[perhp]%")
	elseif unit == "pet" then
		self.Name = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "LEFT", -5, 0)
		self:Tag(self.Name, "[raidcolor][shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[curpp]|[perhp]%")
	elseif unit == "targettarget" then
		self.Name = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "RIGHT", 5, 0)
		self:Tag(self.Name, "[raidcolor][shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self:Tag(self.Health.value, "[curpp]|[perhp]%")
	end

-----------------------------------------------------------------------
-- Castbar
-----------------------------------------------------------------------
	if unit == "player" or unit == "target" or unit == "focus" or unit == "pet" then --castbar
		self.Castbar = CreateFrame("StatusBar")
		self.Castbar:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -2, bottom = -2},
		}
		self.Castbar:SetBackdropColor(0, 0, 0, .3)

		if unit == "player" then
			self.Castbar:SetWidth(plWidth)
			self.Castbar:SetHeight(ppHeight+2)
			self.Castbar:SetParent(oUF.units.player)
			self.Castbar:SetPoint("BOTTOM", oUF.units.player, "TOP", 0, 4)
		elseif unit == "target" then
			self.Castbar:SetWidth(plWidth)
			self.Castbar:SetHeight(ppHeight+2)
			self.Castbar:SetParent(oUF.units.target)
			self.Castbar:SetPoint("BOTTOM", oUF.units.target, "TOP", 0, 4)
		elseif unit == "focus" then
			self.Castbar:SetWidth(focWidth)
			self.Castbar:SetHeight(ppHeight-1)
			self.Castbar:SetParent(oUF.units.focus)
			self.Castbar:SetPoint("TOP", oUF.units.focus, "BOTTOM", 0, -6)
		else
			self.Castbar:SetWidth(focWidth)
			self.Castbar:SetHeight(ppHeight)
			self.Castbar:SetParent(oUF.units.pet)
			self.Castbar:SetPoint("TOP", oUF.units.pet, "BOTTOM", 0, -4)
		end
		
		self.Castbar:SetStatusBarTexture(statusbar)
		self.Castbar:SetStatusBarColor(157/255, 187/255, 159/255)

		self.Castbar:SetMinMaxValues(1, 100)
		self.Castbar:SetValue(1)
		self.Castbar:Hide()

		self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.bg:SetAllPoints(self.Castbar)
--		self.Castbar.bg:SetTexture(statusbar)
		self.Castbar.bg:SetAlpha(0.4)

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,"OVERLAY")
		self.Castbar.SafeZone:SetTexture(statusbar)
		self.Castbar.SafeZone:SetVertexColor(.75,.10,.10,.6)
		self.Castbar.SafeZone:SetHeight(self.Castbar:GetHeight())
		self.Castbar.SafeZone:SetBlendMode("BLEND")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -4, 0)
		self.Castbar.Time:SetFont(font, fontSize)
		self.Castbar.Time:SetTextColor(1, 1, 1)
		self.Castbar.Time:SetShadowOffset(1, -1)

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetPoint("LEFT", self.Castbar, 2, 0)
		self.Castbar.Text:SetWidth(oUF.units.player:GetWidth())
		self.Castbar.Text:SetFont(font, fontSize)
		self.Castbar.Text:SetTextColor(1, 1, 1)
		self.Castbar.Text:SetJustifyH"LEFT"
		self.Castbar.Text:SetShadowOffset(1, -1)
	end

	if unit == "player" then
		if(IsAddOnLoaded("oUF_Swing")) then
			self.Swing = CreateFrame("StatusBar", nil, self)
			self.Swing:SetPoint("BOTTOM", self.Health, "TOP", 0, 2)
			self.Swing:SetStatusBarTexture(statusbar)
			self.Swing:SetStatusBarColor(1, 0.7, 0)
			self.Swing:SetHeight(2)
			self.Swing:SetWidth(plWidth)
		end
	end

-----------------------------------------------------------------------
-- Naming conventions and ze buffage
-----------------------------------------------------------------------
	self.CPoints = self:CreateFontString(nil, "OVERLAY", "SubZoneTextFont")
	self.CPoints:SetPoint("RIGHT", self, "LEFT", -9, 0)
	self.CPoints:SetTextColor(1, 1, 1)
	self.CPoints:SetJustifyH("RIGHT")
	self.CPoints.unit = "player"

	if unit == "target" then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Health, "BOTTOMRIGHT", 10, 0)
		self.Buffs:SetHeight(hpHeight+ppHeight)
		self.Buffs:SetWidth(plWidth)
		self.Buffs.num = 18
		self.Buffs.size = hpHeight+ppHeight
		self.Buffs.spacing = 2
		self.Buffs.initialAnchor = "TOPLEFT"

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPRIGHT", 10, -3)
		self.Debuffs:SetHeight(hpHeight+ppHeight)
		self.Debuffs:SetWidth(plWidth)
		self.Debuffs.size = hpHeight+ppHeight
		self.Debuffs.spacing = 2
		self.Debuffs.onlyShowPlayer = true
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-y"] = "DOWN"
	elseif unit == "targettarget" then
		self.Power:Hide()
		self.Health:SetHeight(hpHeight)

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -1, -3)
		self.Debuffs:SetHeight(hpHeight)
		self.Debuffs:SetWidth(focWidth)
		self.Debuffs.num = 2
		self.Debuffs.size = hpHeight
		self.Debuffs.spacing = 2
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "DOWN"
	elseif unit == "focus" then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
		self.Buffs:SetHeight(hpHeight-1)
		self.Buffs:SetWidth(focWidth)
		self.Buffs.num = 10
		self.Buffs.size = hpHeight-1
		self.Buffs.spacing = 1
		self.Buffs.initialAnchor = "TOPLEFT"
	elseif unit == "player" then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("RIGHT", self.Health, "LEFT", -10, -4)
		self.Debuffs:SetHeight(hpHeight+ppHeight+8)
		self.Debuffs:SetWidth(plWidth)
		self.Debuffs.size = hpHeight+ppHeight+8
		self.Debuffs.spacing = 2
		self.Debuffs.initialAnchor = "TOPRIGHT"
		self.Debuffs["growth-x"] = "LEFT"
		self.Debuffs["growth-y"] = "DOWN"
	end

	self.PVP = SetFontString(self.Health, font, 13, "CENTER", self.Health, "TOP", 0, 0)
	self.PVP:SetTextColor(1, 0, 0)
	self:Tag(self.PVP, "[pvp]")

	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetHeight(14)
	self.RaidIcon:SetWidth(14)
	self.RaidIcon:SetPoint("CENTER", self, "CENTER")
--[[
	if(IsAddOnLoaded"oUF_Reputation" and unit == "player" and UnitLevel("player") == MAX_PLAYER_LEVEL) then
		self.Reputation = CreateFrame("StatusBar", nil, self)
		self.Reputation:SetHeight(5)
		self.Reputation:SetStatusBarTexture(statusbar)
		self.Reputation:SetStatusBarColor(unpack(colors.health))
		self.Reputation:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
		self.Reputation:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -1)
--		self.Reputation:SetAlpha(0)

		self.Reputation:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -1, bottom = -1},
			}
		self.Reputation:SetBackdropColor(0, 0, 0, .3)
		self.Reputation.Tooltip = true

		self.Reputation.Text = self.Reputation:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		self.Reputation.Text:SetPoint("CENTER", self.Reputation, "CENTER")
		
		self.Reputation:HookScript('OnEnter', function(self) self.Reputation:SetAlpha(1) end)
		self.Reputation:HookScript('OnLeave', function(self) self.Reputation:SetAlpha(0) end)
	end
--]]
	if(IsAddOnLoaded("oUF_Experience") and (unit == "pet" or unit == "player") and UnitLevel("player") < MAX_PLAYER_LEVEL) then
		self.Experience = CreateFrame("StatusBar", nil, self)
		self.Experience:SetStatusBarTexture(statusbar)
		self.Experience:SetHeight(5)
		self.Experience:SetStatusBarColor(unpack(colors.health))
		self.Experience:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
		self.Experience:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -1)
		self.Experience:SetAlpha(0)
		self.Experience:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -1, bottom = -1},
			}
		self.Experience:SetBackdropColor(0, 0, 0, .3)

		self.Experience.Rested = CreateFrame('StatusBar', nil, self)
		self.Experience.Rested:SetAllPoints(self.Experience)
		self.Experience.Rested:SetStatusBarTexture(statusbar)
		self.Experience.Rested:SetStatusBarColor(0, 0.4, 1, 0.6)
		self.Experience.Rested:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -1, bottom = -1},
			}
		self.Experience.Rested:SetBackdropColor(0, 0, 0, .3)
		self.Experience.Rested:SetAlpha(0)

		self.Experience.Text = self.Experience:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		self.Experience.Text:SetPoint("CENTER", self.Experience, "CENTER")
		self.Experience:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
		self.Experience:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
		self.Experience.Rested:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
		self.Experience.Rested:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
		
		self.Experience.Tooltip = true
	end

	if(IsAddOnLoaded("oUF_CombatFeedback")) then
		self.CombatFeedbackText = SetFontString(self.Health, font, fontSize+1, "CENTER", self.Health, "CENTER", 0, 0)
		self.CombatFeedbackText:SetShadowOffset(1, -1)
		self.CombatFeedbackText:SetShadowColor(0, 0, 0)
	end

	if(unit == "player" and select(2, UnitClass("player")) == "DEATHKNIGHT") then
		self.Runes = CreateFrame("Frame", nil, self)
		self.Runes:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -1)
		self.Runes:SetHeight(3)
		self.Runes:SetWidth(plWidth)
		self.Runes:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -1, bottom = -1},
			}
		self.Runes:SetBackdropColor(0, 0, 0, .3)
		self.Runes.height = 3
		self.Runes.anchor = "TOPLEFT"
		self.Runes.growth = "RIGHT"
		self.Runes.width = plWidth / 6 - 0.85

		for index = 1, 6 do
			self.Runes[index] = CreateFrame("StatusBar", nil, self.Runes)
			self.Runes[index]:SetStatusBarTexture(statusbar)

			self.Runes[index].bg = self.Runes[index]:CreateTexture(nil, "BACKGROUND")
			self.Runes[index].bg:SetAllPoints(self.Runes[index])
			self.Runes[index].bg:SetTexture(0.3, 0.3, 0.3)
		end
	end

	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	self.DebuffHighlightAlpha = .5

	self.PostUpdateHealth = updateHealthBG
	self.PostCreateAuraIcon = auraIcon

	if(not unit) then 
		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .6
	end

	-- Attributing width and height to shit
	if(unit == "player") then
		self:SetAttribute("initial-height", hpHeight+ppHeight)
		self:SetAttribute("initial-width", plWidth)
		self.Power:SetHeight(ppHeight)

		self.Resting = self.Health:CreateTexture(nil, 'OVERLAY')
		self.Resting:SetHeight(14)
		self.Resting:SetWidth(14)
		self.Resting:SetPoint("CENTER", self.Health, -16, 0)
		self.Resting:SetTexture(media.."rest.tga")
		self.Resting:SetVertexColor(1, .6, .13)

		self.Spark = self.Power:CreateTexture(nil, "OVERLAY")
		self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		self.Spark:SetVertexColor(1, 1, 1, 1)
		self.Spark:SetBlendMode("ADD")
		self.Spark:SetHeight(self.Power:GetHeight()*4.5)
		self.Spark:SetWidth(4)

	elseif unit == "pet" or unit == "targettarget" then
		self:SetAttribute("initial-height", hpHeight)
		self:SetAttribute("initial-width", focWidth)
		self.Power:Hide()
	elseif unit == "target" then
		self:SetAttribute("initial-height", hpHeight+ppHeight)
		self:SetAttribute("initial-width", plWidth)
		self.Power:SetHeight(ppHeight)
	elseif unit == "focus" or unit == "focustarget" then
		self:SetAttribute("initial-height", 15)
		self:SetAttribute("initial-width", 185)
		self.Power:Hide()
	end

	self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
	self.Leader:SetHeight(14)
	self.Leader:SetWidth(14)
	self.Leader:SetPoint("CENTER", self.Health, "TOP", 0, 0)
	self.Leader:SetTexture(media.."leader.tga")
	self.Leader:SetVertexColor(188/255, 152/255, 126/255)

	self.MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
	self.MasterLooter:SetHeight(14)
	self.MasterLooter:SetWidth(14)
	self.MasterLooter:SetPoint("CENTER", self.Leader, 16, -16)
	self.MasterLooter:SetTexture(media.."looter.tga")
	self.MasterLooter:SetVertexColor(188/255, 152/255, 126/255)
end

-- Setup -- :Spawn(unit, frame_name, isPet) --isPet is only used on headers.
oUF:RegisterStyle("Ynarah", func_of_doom)
oUF:SetActiveStyle("Ynarah")

oUF:Spawn("player"):SetPoint("TOPRIGHT", UIParent, "CENTER", -50, -200)
oUF:Spawn("pet"):SetPoint("TOPRIGHT", oUF.units.player, "BOTTOMRIGHT", 0, -10)
oUF:Spawn("target"):SetPoint("TOPLEFT", UIParent, "CENTER", 50, -200)
oUF:Spawn("focus"):SetPoint("BOTTOMLEFT", oUF.units.target, "TOPLEFT", 0, 35)
oUF:Spawn("focustarget"):SetPoint("LEFT", oUF.units.focus, "RIGHT", 10, 0)
oUF:Spawn("targettarget"):SetPoint("TOPLEFT", oUF.units.target, "BOTTOMLEFT", 0, -10)