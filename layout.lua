--[[

  Kelly Crabbé grants anyone the right to use this work for any purpose,
  without any conditions, unless such conditions are required by law.

--]]

---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------
local media = "Interface\\AddOns\\oUF_Ynarah\\media\\"
local texture = "Interface\\TargetingFrame\\UI-StatusBar"
local font = STANDARD_TEXT_FONT
local numbers = "Fonts\\skurri.TTF"
local fontSize = 11
local border = media.."gloss.tga"
local backdrop = {
	bgFile = texture, insets = {top = -1, bottom = -1, left = -1, right = -1}
}

local hpHeight = 20 -- height of healthbar of player/target/tot/focus/pet and height of castbar
local ppHeight = 8 -- height of powerbar of player/target/pet
local plWidth = 325 -- width of player/target and width of castbar
local focWidth = 185 -- width of tot/focus

---------------------------------------------------------------------
-- Converts 1000000 into 1M
---------------------------------------------------------------------
local letter = function(value) -- to shorten HP/MP strings at full
	if value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end

---------------------------------------------------------------------
-- Colorize NOW
---------------------------------------------------------------------
local function hex(r, g, b)
	if(type(r) == "table") then
		if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
end


---------------------------------------------------------------------
-- Custom tags
---------------------------------------------------------------------
oUF.TagEvents["[yna:AFKDND]"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags["[yna:AFKDND]"] = function(unit)
	return UnitIsAFK(unit) and "|cffff0000A|r" or UnitIsDND(unit) and "|cffff00ffD|r" 
end

-- Because we like COLOR
oUF.TagEvents["[yna:colorpp]"] = "UNIT_MANA"
oUF.Tags["[yna:colorpp]"] = function(unit)
	local _, str = UnitPowerType(unit)
	local coloredmana = colors.power[str]
	return coloredmana and string.format("|cff%02x%02x%02x", coloredmana[1] * 255, coloredmana[2] * 255, coloredmana[3] * 255)
end

-- The Shortened Tags :P
oUF.TagEvents["[yna:shortpp]"] = "UNIT_MANA"
oUF.Tags["[yna:shortpp]"] = function(unit)
	return letter(UnitPower(unit))
end

oUF.TagEvents["[yna:shortname]"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags["[yna:shortname]"] = function(u)
	local name = UnitName(u)
	return (string.len(name) > 10) and string.gsub(name, "%s?(.)%S+%s", "%1. ") or name
end

oUF.Tags["[yna:smarthp]"] = function(u)
	return UnitIsDeadOrGhost(u) and oUF.Tags["[dead]"](u) or (UnitHealth(u)~=UnitHealthMax(u)) and format("%s (%.0f%%)", letter(UnitHealth(u)), (UnitHealth(u)/UnitHealthMax(u)*100) or letter(UnitHealthMax(u)))
end

oUF.TagEvents["[yna:druidpower]"] = "UNIT_MANA UPDATE_SHAPESHIFT_FORM"
oUF.Tags["[yna:druidpower]"] = function(unit)
	local min, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)
	return unit == "player" and UnitPowerType(unit) ~= 0 and min ~= max and ("|cff0090ff%d%%|r"):format(min / max * 100)
end

---------------------------------------------------------------------
-- Aura Skinning
---------------------------------------------------------------------
local PostCreateAura = function(element, button)
	icons.showType = true
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 2)
	button.overlay:SetTexture(border)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
	button.icon:SetTexCoord(.07, .93, .07, .93)
end

local PostUpdateDebuff = function(element, unit, button, index)
	if(UnitIsFriend('player', unit) or button.isPlayer) then
		local _, _, _, _, type = UnitAura(unit, index, button.filter)
		local color = DebuffTypeColor[type] or DebuffTypeColor.none

		button:SetBackdropColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
		button.icon:SetDesaturated(false)
	else
		button:SetBackdropColor(0, 0, 0)
		button.icon:SetDesaturated(true)
	end
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
-- Right click player menu -- taken from p3lim's excellently coded layout
---------------------------------------------------------------------
local function SpawnMenu(self)
	ToggleDropDownMenu(1, nil, _G[string.gsub(self.unit, '^.', string.upper)..'FrameDropDown'], 'cursor')
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
-- Hellish functions UnitSpecific and Shared... new shit :(
---------------------------------------------------------------------
local UnitSpecific = {
	player = function(self)	
		self:SetAttribute("initial-height", hpHeight+ppHeight)
		self:SetAttribute("initial-width", plWidth)
		self.Power:SetHeight(ppHeight)
		
		self.Power.value = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self.Power.value:SetTextColor(1, 1, 1)
		self:Tag(self.Power.value, "[yna:colorpp][curpp] [( )yna:druidpower]|r ")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[curhp]")
		
		if(IsAddOnLoaded("oUF_Swing")) then
			self.Swing = CreateFrame("StatusBar", nil, self)
			self.Swing:SetPoint("BOTTOM", self.Health, "TOP", 0, 2)
			self.Swing:SetStatusBarTexture(statusbar)
			self.Swing:SetStatusBarColor(1, 0.7, 0)
			self.Swing:SetHeight(2)
			self.Swing:SetWidth(plWidth)
		end
		
		self.Resting = SetFontString(self.Health, font, fontSize, "CENTER", self.Health, "CENTER", 0, 2)
		self.Resting:SetText("[R]")
		self.Resting:SetTextColor(1, .6, .13)

		self.Spark = self.Power:CreateTexture(nil, "OVERLAY")
		self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		self.Spark:SetVertexColor(1, 1, 1, 1)
		self.Spark:SetBlendMode("ADD")
		self.Spark:SetHeight(self.Power:GetHeight()*4.5)
		self.Spark:SetWidth(4)
		
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("RIGHT", self.Health, "LEFT", -10, -4)
		self.Debuffs:SetHeight(hpHeight+ppHeight+8)
		self.Debuffs:SetWidth(plWidth)
		self.Debuffs.size = hpHeight+ppHeight+8
		self.Debuffs.spacing = 2
		self.Debuffs.initialAnchor = "TOPRIGHT"
		self.Debuffs["growth-x"] = "LEFT"
		self.Debuffs["growth-y"] = "DOWN"
		
		-- Runes
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
	
		-- Totembar
		if(IsAddOnLoaded("oUF_TotemBar") and (unit == "player" and select(2, UnitClass("player")) == "SHAMAN")) then
			self.TotemBar = {}
			for i = 1, 4 do
				self.TotemBar[i] = CreateFrame("StatusBar", nil, self)
				self.TotemBar[i]:SetHeight(7)
				self.TotemBar[i]:SetWidth(plWidth/4 - 0.85)
				if (i == 1) then
					self.TotemBar[i]:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
				else
					self.TotemBar[i]:SetPoint("TOPLEFT", self.TotemBar[i-1], "TOPRIGHT", 1, 0)
				end
				self.TotemBar[i]:SetStatusBarTexture(statusbar)
				self.TotemBar[i]:SetBackdrop{
					bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
					insets = {left = -2, right = -2, top = -2, bottom = -2},
				}
				self.TotemBar[i]:SetBackdropColor(0, 0, 0, .3)
				self.TotemBar[i]:SetMinMaxValues(0, 1)
				self.TotemBar[i].destroy = true
							
				self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
				self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
				self.TotemBar[i].bg:SetTexture(statusbar)
				self.TotemBar[i].bg.multiplier = 0.25
			end
		end
	end,
	
	target = function(self)
		self:SetAttribute("initial-height", hpHeight+ppHeight)
		self:SetAttribute("initial-width", plWidth)
		self.Power:SetHeight(ppHeight)
		
		self.Info = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self.Info:SetTextColor(1, 1, 1)
		self:Tag(self.Info, "[yna:colorpp][yna:shortpp]|r [(- )cpoints( CP)] | [perhp]%")
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Name,"L[difficulty][smartlevel] [race] [raidcolor][yna:shortname] [dead]")
		
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
		
		self.CPoints = self:CreateFontString(nil, "OVERLAY", "SubZoneTextFont")
		self.CPoints:SetPoint("RIGHT", self, "LEFT", -9, 0)
		self.CPoints:SetTextColor(1, 1, 1)
		self.CPoints:SetJustifyH("RIGHT")
		self.CPoints.unit = PlayerFrame.unit
	
	end,
	
	targettarget = function(self)
		self:SetAttribute("initial-height", hpHeight)
		self:SetAttribute("initial-width", focWidth)
		self.Power:Hide()
		self.Health:SetHeight(hpHeight)
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "RIGHT", 5, 0)
		self:Tag(self.Name, "[raidcolor][yna:shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self:Tag(self.Health.value, "[yna:colorpp][perpp]%|r | [perhp]%")

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
	end,
	
	pet = function(self)
		self:SetAttribute("initial-height", hpHeight)
		self:SetAttribute("initial-width", focWidth)
		self.Power:Hide()
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "LEFT", -5, 0)
		self:Tag(self.Name, "[raidcolor][yna:shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[yna:colorpp][perpp]%|r|[perhp]%")
	end,
	
	focus = function(self)
		self:SetAttribute("initial-height", 15)
		self:SetAttribute("initial-width", 185)
		self.Power:Hide()
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self:Tag(self.Name, "[raidcolor][yna:shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[yna:colorpp][perpp]%|r | [perhp]%")
		
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
		self.Buffs:SetHeight(hpHeight-1)
		self.Buffs:SetWidth(focWidth)
		self.Buffs.num = 10
		self.Buffs.size = hpHeight-1
		self.Buffs.spacing = 1
		self.Buffs.initialAnchor = "TOPLEFT"
	end,
	
	focustarget = function(self)
		self:SetAttribute("initial-height", 15)
		self:SetAttribute("initial-width", 185)
		self.Power:Hide()
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self:Tag(self.Name, "[raidcolor][yna:shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[yna:colorpp][perpp]%|r | [perhp]%")
	end,
}

local function Shared(self, unit)
	self:RegisterForClicks('AnyUp')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.colors.power.MANA = {0, 144/255, 1}
	
	-- backdrop
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, .8)
	
	-- HP FG
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetPoint("TOPRIGHT", self)
	self.Health:SetPoint("TOPLEFT", self)
	self.Health:SetStatusBarTexture(statusbar)
	self.Health:SetHeight(hpHeight)
	self.Health:SetStatusBarColor(100/255, 111/255, 101/255)
	self.Health.frequentUpdates = true
	
	-- HP BG
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER", self)
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetAlpha(.4)

	-- PP FG
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -3)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Power:SetStatusBarTexture(statusbar)
	self.Power:SetHeight(ppHeight)
	self.Power.frequentUpdates = true

	self.Power.colorClass = true
	self.Power.colorTapped = true
	self.Power.colorReaction = true
	
	-- PP BG
	self.Power.bg = self.Power:CreateTexture(nil, "BORDER", self)
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetAlpha(.4)
	
	-- Castbar
	if unit == "player" or unit == "target" or unit == "focus" or unit == "pet" then
		self.Castbar = CreateFrame("StatusBar")
		self.Castbar:SetBackdrop{
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -2, bottom = -2},
		}
		self.Castbar:SetBackdropColor(0, 0, 0, .8)

		if unit == "player" then
			self.Castbar:SetWidth(plWidth)
			self.Castbar:SetHeight(ppHeight+5)
			self.Castbar:SetParent(oUF.units.player)
			self.Castbar:SetPoint("BOTTOM", oUF.units.player, "TOP", 0, 4)
		elseif unit == "target" then
			self.Castbar:SetWidth(plWidth)
			self.Castbar:SetHeight(ppHeight+5)
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
		self.Castbar:SetStatusBarColor(65/255, 45/255, 140/255)

		self.Castbar:SetMinMaxValues(1, 100)
		self.Castbar:SetValue(1)
		self.Castbar:Hide()

		self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.bg:SetAllPoints(self.Castbar)
		self.Castbar.bg:SetAlpha(0.4)

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,"OVERLAY")
		self.Castbar.SafeZone:SetTexture(statusbar)
		self.Castbar.SafeZone:SetVertexColor(140/255, 45/255, 65/255,1)
		self.Castbar.SafeZone:SetHeight(self.Castbar:GetHeight())
		self.Castbar.SafeZone:SetBlendMode("DISABLE")

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

		self.Castbar.Icon = self.Castbar:CreateTexture(nil, "BACKGROUND")
		self.Castbar.Icon:SetHeight(35)
		self.Castbar.Icon:SetWidth(35)
		self.Castbar.Icon:SetTexCoord(.07, .93, .07, .93)
		
		self.Castbar.Icon.overlay = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Icon.overlay:SetAllPoints(self.Castbar.Icon)
		self.Castbar.Icon.overlay:SetTexture(border)
		
		if(unit == "player") then
			self.Castbar.Icon:SetPoint("TOPLEFT", self.Castbar, "TOPRIGHT", 12, 0)
		elseif (unit == "target") then
			self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar, "TOPLEFT", -12, 0)
		end
	end
	
	-- Tags	
	self.PVP = SetFontString(self.Health, font, 13, "CENTER", self.Health, "TOP", 0, 0)
	self.PVP:SetTextColor(1, 0, 0)
	self:Tag(self.PVP, "[pvp]")

	self.Leader = SetFontString(self.Health, font, 13, "CENTER", self.Health, "TOPLEFT", 0, 0)
	self.Leader:SetTextColor(1, 1, 1)
	self:Tag(self.Leader, "[leader]")

	self.MasterLooter = SetFontString(self.Health, font, 13, "LEFT", self.Health, "RIGHT", 0, 0)
	self.MasterLooter:SetTextColor(1, 1, 1)
	self.Tag(self.MasterLooter, "[masterlooter]")

	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetHeight(14)
	self.RaidIcon:SetWidth(14)
	self.RaidIcon:SetPoint("CENTER", self, "CENTER")

	--[[
	self.AFKDND = SetFontString(self.Health, font, 13, "CENTER", self.Health, "CENTER", 0, 0)
	self.AFKDND:SetTextColor(1, 0, 0)
	self:Tag(self.AFKDND, "[yna:AFKDND]")
	--]]
	
	-- CombatFeedback (And heals)
	if(IsAddOnLoaded("oUF_CombatFeedback")) then
		self.CombatFeedbackText = SetFontString(self.Health, font, fontSize+1, "CENTER", self.Health, "CENTER", 0, 0)
		--self.CombatFeedbackText.ignoreHeal = true -- ignore heals 
		self.CombatFeedbackText:SetShadowOffset(1, -1)
		self.CombatFeedbackText:SetShadowColor(0, 0, 0)
	end
	
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	self.DebuffHighlightAlpha = .5
	
	self.PostUpdateHealth = updateHealthBG
	self.PostCreateAuraIcon = PostCreateAura
	
	if(not unit) then 
		self.SpellRange = true
		self.Range = true
		self.inRangeAlpha = 1.0
		self.outsideRangeAlpha = 0.4
		self.MoveableFrames = true
		self.Health.BarFade = true
		self.Power.BarFade = true
	end

	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

oUF:RegisterStyle("Ynarah", Shared)

oUF:Factory(function(self)
	oUF:SetActiveStyle("Ynarah")
	
	oUF:Spawn("player"):SetPoint("TOPRIGHT", UIParent, "CENTER", -50, -200)
	oUF:Spawn("pet"):SetPoint("TOPRIGHT", oUF.units.player, "BOTTOMRIGHT", 0, -7)
	oUF:Spawn("target"):SetPoint("TOPLEFT", UIParent, "CENTER", 50, -200)
	oUF:Spawn("focus"):SetPoint("BOTTOMLEFT", oUF.units.target, "TOPLEFT", 0, 35)
	oUF:Spawn("focustarget"):SetPoint("LEFT", oUF.units.focus, "RIGHT", 10, 0)
	oUF:Spawn("targettarget"):SetPoint("TOPLEFT", oUF.units.target, "BOTTOMLEFT", 0, -7)
end)