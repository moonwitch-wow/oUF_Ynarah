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
local border = media.."border.tga"

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
oUF.TagEvents["yna:AFKDND"] = "PLAYER_FLAGS_CHANGED"
oUF.Tags["yna:AFKDND"] = function(unit)
	return UnitIsAFK(unit) and "|cffff0000A|r" or UnitIsDND(unit) and "|cffff00ffD|r" or Unit
end

oUF.Tags["yna:colorpp"] = function(unit)
	local _, str = UnitPowerType(unit)
	local coloredmana = _COLORS.power[str]
	return coloredmana and string.format("|cff%02x%02x%02x", coloredmana[1] * 255, coloredmana[2] * 255, coloredmana[3] * 255)
end

oUF.Tags["yna:shortpp"] = function(unit)
	return letter(UnitPower(unit))
end

oUF.TagEvents["[yna:shortname]"] = "UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION"
oUF.Tags["yna:shortname"] = function(unit)
	local name = UnitName(unit)
	return (string.len(name) > 10) and string.gsub(name, "%s?(.)%S+%s", "%1. ") or name
end

oUF.Tags["yna:smarthp"] = function(unit)
	return UnitIsDeadOrGhost(unit) and oUF.Tags["[dead]"](unit) or (UnitHealth(unit)~=UnitHealthMax(unit)) and format("%s (%.0f%%)", letter(UnitHealth(unit)), (UnitHealth(unit)/UnitHealthMax(unit)*100) or letter(UnitHealthMax(unit)))
end

oUF.Tags["yna:druidpower"] = function(unit)
	local min, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)
	if(UnitPowerType(unit) ~= 0 and min ~= max) then
		return ('|cff0090ff%d%%|r'):format(min / max * 100)
	end
end

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
		button.icon:SetDesaturated(false)
		button.overlay:SetTexture(border)
		button.overlay:SetTexCoord(0, 1, 0, 1)
		button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
		button.icon:SetTexCoord(.07, .93, .07, .93)
	else
		button:SetBackdropColor(0, 0, 0)
		button.icon:SetDesaturated(true)
		button.overlay:SetTexture(border)
		button.overlay:SetTexCoord(0, 1, 0, 1)
		button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
		button.icon:SetTexCoord(.07, .93, .07, .93)
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
	element.__owner.HealPrediction:ForceUpdate()
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
		self:SetHeight(hpHeight+ppHeight)
		self:SetWidth(plWidth)
		self.Power:SetHeight(ppHeight)
		
		self.Power.value = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self.Power.value:SetTextColor(1, 1, 1)
		self:Tag(self.Power.value, "[yna:colorpp][curpp< ] [yna:druidpower]|r ")
		self.Power.value.colorPower = true
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[curhp]")
		
		if(IsAddOnLoaded("oUF_Swing")) then
			self.Swing = CreateFrame("StatusBar", nil, self)
			self.Swing:SetPoint("BOTTOM", self.Health, "TOP", 0, 2)
			self.Swing:SetStatusBarTexture(texture)
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
		self.Debuffs.PostCreateIcon = PostCreateAura
		RuneFrame:Hide()
		
		-- Runes
		if select(2, UnitClass("player")) == "DEATHKNIGHT" then
			RuneFrame:Hide()
			self.Runes = CreateFrame("Frame", nil, self)
			self.Runes:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
			self.Runes:SetSize(plWidth, 5)
			self.Runes:SetBackdrop{
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
				insets = {left = -2, right = -2, top = -1, bottom = -1},
				}
			self.Runes:SetBackdropColor(0, 0, 0, .8)
			
			oUF.colors.runes = {
				[1] = {176/255,23/255,31/255},		-- Blood
				[2] = {61/255,145/255,64/255},		-- Unholy
				[3] = {79/255,148/255,205/255},		-- Frost
				[4] = {.8,.6,.8}					-- Death
			}

			for i = 1, 6 do
				self.Runes[i] = CreateFrame("StatusBar", nil, self.Runes)
				self.Runes[i]:SetStatusBarTexture(texture)
				self.Runes[i]:SetHeight(3)
				self.Runes[i].growth = "RIGHT"
				self.Runes[i]:SetWidth((plWidth-5)/6)
				
				if (i == 1) then
					self.Runes[i]:SetPoint("TOPLEFT", self.Runes, "TOPLEFT", 0, -1)
				else
					self.Runes[i]:SetPoint("LEFT", self.Runes[i-1], "RIGHT", 1, 0)
				end
				
				self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, "BACKGROUND")
				self.Runes[i].bg:SetAllPoints(self.Runes[i])
				self.Runes[i].bg:SetTexture(0.3, 0.3, 0.3)
				self.Runes[i].bg.multiplier = .8
			end
		end
	
		-- Totembar
		if(IsAddOnLoaded("oUF_TotemBar") and select(2, UnitClass("player")) == "SHAMAN") then
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
				self.TotemBar[i]:SetStatusBarTexture(texture)
				self.TotemBar[i]:SetBackdrop{
					bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
					insets = {left = -2, right = -2, top = -2, bottom = -2},
				}
				self.TotemBar[i]:SetBackdropColor(0, 0, 0, .3)
				self.TotemBar[i]:SetMinMaxValues(0, 1)
				self.TotemBar[i].destroy = true
							
				self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
				self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
				self.TotemBar[i].bg:SetTexture(texture)
				self.TotemBar[i].bg.multiplier = 0.25
			end
		end
		
		-- Eclipsebar
		if select(2, UnitClass("player")) == "DRUID" then
			self.EclipseBar = CreateFrame("StatusBar", nil, self)
			self.EclipseBar:SetHeight(7)
			--self.EclipseBar_OnLoad(EclipseBarFrame)
			self.EclipseBar:ClearAllPoints()
			self.EclipseBar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
			self.EclipseBar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -1)
			self.EclipseBar:SetFrameStrata("HIGH")
			self.EclipseBar:SetBackdrop{
					bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					insets = {left = -2, right = -2, top = -2, bottom = -2},
				}
			self.EclipseBar:SetBackdropColor(0, 0, 0, .3)
		end
		
		-- HolyPower
		if select(2, UnitClass("player")) ==  "PALADIN" then
			self.HolyPower = CreateFrame("Frame", nil, self)
			self.HolyPower:SetSize(plWidth, 5)
			self.HolyPower:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -2)
			self.HolyPower:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -2)
			self.HolyPower:SetBackdrop{
					bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
					insets = {left = -2, right = -2, top = 0, bottom = -2},
				}
			self.HolyPower:SetBackdropColor(0, 0, 0, .8)
			
			for i = 1, MAX_HOLY_POWER do
				self.HolyPower[i] = self.HolyPower:CreateTexture(nil, 'OVERLAY')
				self.HolyPower[i]:SetSize((plWidth-2)/MAX_HOLY_POWER, 5)
				self.HolyPower[i]:SetTexture(texture)
				self.HolyPower[i]:SetVertexColor(255/255, 234/255, 0)
				
				if (i == 1) then
					self.HolyPower[i]:SetPoint("TOPLEFT", self.HolyPower, "TOPLEFT", 0, -1)
				else
					self.HolyPower[i]:SetPoint("TOPLEFT", self.HolyPower[i-1], "TOPRIGHT", 1, 0)
				end
				
				-- so we have a bar when it's depleted
				self.HolyPower[i].bg = self.HolyPower:CreateTexture(nil, "BACKGROUND")
				self.HolyPower[i].bg:SetAllPoints(self.HolyPower[i])
				self.HolyPower[i].bg:SetTexture(0.3, 0.3, 0.3)
				self.HolyPower[i].bg.multiplier = .8
			end
			self.HolyPower:SetBackdrop{
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				insets = {left = -2, right = -2, top = 0, bottom = -2},
			}
			self.HolyPower:SetBackdropColor(0, 0, 0, .8)
		end

		
		-- SoulShards
		if select(2, UnitClass("player")) ==  "WARLOCK" then
			self.SoulShards = CreateFrame("Frame", nil, self)
			self.SoulShards:SetSize(plWidth, 7)
			self.SoulShards:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -2)
			self.SoulShards:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -2)

			for i = 1, SHARD_BAR_NUM_SHARDS do
				self.SoulShards[i] = self.SoulShards:CreateTexture(nil, 'OVERLAY')
				self.SoulShards[i]:SetSize((plWidth-2)/SHARD_BAR_NUM_SHARDS, 5)
				self.SoulShards[i]:SetTexture(texture)
				self.SoulShards[i]:SetVertexColor(0, 144/255, 1)
				
				if (i == 1) then
					self.SoulShards[i]:SetPoint("TOPLEFT", self.SoulShards, "TOPLEFT", 0, -1)
				else
					self.SoulShards[i]:SetPoint("TOPLEFT", self.SoulShards[i-1], "TOPRIGHT", 1, 0)
				end
				
				-- so we have a bar when it's depleted
				self.SoulShards[i].bg = self.SoulShards:CreateTexture(nil, "BACKGROUND")
				self.SoulShards[i].bg:SetAllPoints(self.SoulShards[i])
				self.SoulShards[i].bg:SetTexture(texture)
				self.SoulShards[i].bg.multiplier = .4
			end
			self.SoulShards:SetBackdrop{
				bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				insets = {left = -2, right = -2, top = 0, bottom = -2},
			}
			self.SoulShards:SetBackdropColor(0, 0, 0, .8)
		end
	end,
	
	target = function(self)
		self:SetHeight(hpHeight+ppHeight)
		self:SetWidth(plWidth)
		self.Power:SetHeight(ppHeight)
		
		self.Info = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self.Info:SetTextColor(1, 1, 1)
		self:Tag(self.Info, "[yna:colorpp][yna:shortpp]|r | [perhp]%")
		
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
		self.Buffs.PostCreateIcon = PostCreateAura

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPRIGHT", 10, -3)
		self.Debuffs:SetHeight(hpHeight+ppHeight)
		self.Debuffs:SetWidth(plWidth)
		self.Debuffs.size = hpHeight+ppHeight
		self.Debuffs.spacing = 2
		self.Debuffs.onlyShowPlayer = true
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-y"] = "DOWN"
		self.Debuffs.PostCreateIcon = PostCreateAura
		
		self.cPoints = self:CreateFontString(nil, "OVERLAY", "SubZoneTextFont")
		self.cPoints:SetPoint("RIGHT", self, "LEFT", -9, 0)
		self.cPoints:SetTextColor(1, 1, 1)
		self.cPoints:SetJustifyH("RIGHT")
		self.cPoints.unit = PlayerFrame.unit
		self:Tag(self.cPoints, '|cffffffff[cpoints]|r')
		
	
	end,
	
	targettarget = function(self)
		self:SetHeight(hpHeight)
		self:SetWidth(focWidth)
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
		self.Debuffs.PostCreateIcon = PostCreateAura
	end,
	
	pet = function(self)
		self:SetHeight(hpHeight)
		self:SetWidth(focWidth)
		--self.Power:Hide()
		
		self.Power:SetHeight(3)
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "LEFT", -5, 0)
		self:Tag(self.Name, "[raidcolor][yna:shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[yna:colorpp][perpp]%|r|[perhp]%")
	end,
	
	focus = function(self)
		self:SetHeight(15)
		self:SetWidth(185)
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
		self.Buffs.PostCreateIcon = PostCreateAura
	end,
	
	focustarget = function(self)
		self:SetHeight(15)
		self:SetWidth(185)
		self.Power:Hide()
		
		self.Name = SetFontString(self.Health, font, fontSize+1, "LEFT", self.Health, "LEFT", 2, 0)
		self:Tag(self.Name, "[raidcolor][yna:shortname] [dead]")
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, "RIGHT", self.Health, "RIGHT", -2, 0)
		self:Tag(self.Health.value, "[yna:colorpp][perpp]%|r | [perhp]%")
	end,
}

local function Shared(self, unit)
	self.colors.power.MANA = {0, 144/255, 1}
	
	self:RegisterForClicks('AnyDown')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	self.menu = SpawnMenu
	
	-- HP FG
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetPoint("TOPRIGHT", self)
	self.Health:SetPoint("TOPLEFT", self)
	self.Health:SetStatusBarTexture(texture)
	self.Health:SetHeight(hpHeight)
	self.Health:SetStatusBarColor(100/255, 111/255, 101/255)
	self.Health.frequentUpdates = true
	
	-- HP Backdrop, because I am fed up with the math of it all.
	self.Health:SetBackdrop{
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			insets = {left = -2, right = -2, top = -2, bottom = -2},
		}
	self.Health:SetBackdropColor(0, 0, 0, .8)
	
	-- HP BG
	self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(texture)
	self.Health.bg.multiplier = .4

	-- PP FG
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -2)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
	self.Power:SetStatusBarTexture(texture)
	self.Power:SetHeight(ppHeight)
	self.Power.frequentUpdates = true
	
	-- HP Backdrop, because I am fed up with the math of it all.
	self.Power:SetBackdrop{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		insets = {left = -2, right = -2, top = 0, bottom = -2},
		}
	self.Power:SetBackdropColor(0, 0, 0, .8)

	self.Power.colorClass = true
	self.Power.colorTapped = true
	self.Power.colorReaction = true
	
	-- PP BG
	self.Power.bg = self.Power:CreateTexture(nil, "BACKGROUND")
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(texture)
	self.Power.bg.multiplier = .4
	
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
		
		self.Castbar:SetStatusBarTexture(texture)
		self.Castbar:SetStatusBarColor(65/255, 45/255, 140/255)

		self.Castbar:SetMinMaxValues(1, 100)
		self.Castbar:SetValue(1)
		self.Castbar:Hide()

		self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
		self.Castbar.bg:SetAllPoints(self.Castbar)
		self.Castbar.bg:SetAlpha(0.4)

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,"OVERLAY")
		self.Castbar.SafeZone:SetTexture(texture)
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
	
	self.LFDRole = self.Health:CreateTexture(nil, "OVERLAY")
	self.LFDRole:SetHeight(15)
	self.LFDRole:SetWidth(15)
	self.LFDRole:SetPoint("BOTTOMLEFT", -1, -4)

	self.AFKDND = SetFontString(self.Health, font, 13, "CENTER", self.Health, "CENTER", 0, 0)
	self.AFKDND:SetTextColor(1, 0, 0)
	self:Tag(self.AFKDND, "[yna:AFKDND]")
	
	-- New QuestIcon shit
	self.QuestIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.QuestIcon:SetPoint("CENTER", self.Health, "CENTER")
	
	-- HealPrediction
	self.HealPrediction = CreateFrame("StatusBar",nil,self.Health)
	self.HealPrediction:SetMinMaxValues(0,1)
	self.HealPrediction:SetStatusBarTexture(texture)
	self.HealPrediction:SetStatusBarColor(0.25,1,0,.5)
	self.HealPrediction:SetPoint("TOPLEFT", self.Health, "TOPLEFT")
	self.HealPrediction:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT")
	self.HealPrediction:SetOrientation("HORIZONTAL")
		
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
	
	if(not unit) then 
		self.SpellRange = true
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = 0.8,
		}
		self.MoveableFrames = true
		self.Health.BarFade = true
		self.Power.BarFade = true
	end

	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

oUF.colors.power.MANA = {0, 144/255, 1}

oUF:RegisterStyle("Ynarah", Shared)

oUF:Factory(function(self)
	oUF:SetActiveStyle("Ynarah")
	
	oUF:Spawn("player"):SetPoint("TOPRIGHT", UIParent, "CENTER", -50, -200)
	oUF:Spawn("pet"):SetPoint("TOPRIGHT", oUF.units.player, "BOTTOMRIGHT", 0, -15)
	oUF:Spawn("target"):SetPoint("TOPLEFT", UIParent, "CENTER", 50, -200)
	oUF:Spawn("focus"):SetPoint("BOTTOMLEFT", oUF.units.target, "TOPLEFT", 0, 35)
	oUF:Spawn("focustarget"):SetPoint("LEFT", oUF.units.focus, "RIGHT", 10, 0)
	oUF:Spawn("targettarget"):SetPoint("TOPLEFT", oUF.units.target, "BOTTOMLEFT", 0, -15)
end)