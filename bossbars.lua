---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------
local media = 'Interface\\AddOns\\oUF_Ynarah\\media\\'
local texture = 'Interface\\TargetingFrame\\UI-StatusBar'
local font = STANDARD_TEXT_FONT
local numbers = 'Fonts\\skurri.TTF'
local fontSize = 11
--local border = media..'border.tga'
local border = media..'gloss.tga'

--I got tired of typing this all the damn time k?
local backdrop = {
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1}
		}
local backdropcolor = {.1,.1,.1,1}
local backdropbordercolor = {.6,.6,.6,1}

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
-- Colorize NOW
---------------------------------------------------------------------
local function hex(r, g, b)
	if(type(r) == 'table') then
		if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

---------------------------------------------------------------------
-- Custom tags
---------------------------------------------------------------------
oUF.Tags["[colorpp]"] = function(unit) -- from p3lim"s excellently coded layout
	local num, str = UnitPowerType(unit)
	local c = colors.power[str]
	return string.format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
end

oUF.TagEvents['yna:shortname'] = 'UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION'
oUF.Tags['yna:shortname'] = function(unit)
	local name = UnitName(unit)
	return (string.len(name) > 10) and string.gsub(name, '%s?(.)%S+%s', '%1. ') or name
end

oUF.Tags['yna:smarthp'] = function(unit)
	return UnitIsDeadOrGhost(unit) and oUF.Tags['[dead]'](unit) or (UnitHealth(unit)~=UnitHealthMax(unit)) and format('%s (%.0f%%)', letter(UnitHealth(unit)), (UnitHealth(unit)/UnitHealthMax(unit)*100) or letter(UnitHealthMax(unit)))
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

local createBossBars = function(self, unit)
	self:SetSize(200, 30)
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(.1,.1,.1,1)
	self:SetBackdropBorderColor(.6,.6,.6,1)

	-- HP FG
	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetPoint('TOPLEFT', self, 'TOPLEFT', 2, -2)
	self.Health:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -2, -2)
	self.Health:SetStatusBarTexture(texture)
	self.Health:SetHeight(20)
	self.Health:SetStatusBarColor(100/255, 111/255, 101/255)
	self.Health.frequentUpdates = true
	
	-- HP Text
	self.Health.value = SetFontString(self.Health, font, fontSize+1, 'RIGHT', self.Health, 'RIGHT', -2, 0)
	self.Health.value:SetWidth(100)
	self:Tag(self.Health.value, '[curhp] ([perhp]%)')
	
	-- HP BG
	self.Health.bg = self.Health:CreateTexture(nil, 'BACKGROUND')
	self.Health.bg:SetAllPoints(self.Health)
	self.Health.bg:SetTexture(texture)
	self.Health.bg:SetVertexColor(139/255, 70/255, 70/255)
	self.Health.bg.multiplier = .75
	
	-- PP FG
	self.Power = CreateFrame('StatusBar', nil, self)
	self.Power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2)
	self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -2)
	self.Power:SetStatusBarTexture(texture)
	self.Power:SetHeight(5)
	self.Power.frequentUpdates = true

	-- PP BG
	self.Power.bg = self.Power:CreateTexture(nil, 'BACKGROUND')
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(texture)
	self.Power.bg.multiplier = .2
	
	self.Name = SetFontString(self.Health, font, fontSize+1, 'LEFT', self.Health, 'LEFT', 2, 0)
	self:Tag(self.Name,'L[difficulty][smartlevel][yna:shortname]')
	
	-- New QuestIcon shit
	self.QuestIcon = self.Health:CreateTexture(nil, 'OVERLAY')
	self.QuestIcon:SetPoint('CENTER', self.Health, 'CENTER')
	
	self.PostUpdateHealth = updateHealthBG
	
	self.SpellRange = true
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.8,
	}
	self.MoveableFrames = true
end


-- BossBars
oUF:RegisterStyle("yna_BossBars", createBossBars)

oUF:SetActiveStyle("yna_BossBars")
local boss = {}
for i = 1, MAX_BOSS_FRAMES do
	boss[i] = oUF:Spawn("boss"..i, "oUF_YnaBoss"..i)
	if i==1 then
		boss[i]:SetPoint("LEFT", UIParent, "BOTTOMLEFT", 15, 450)
	else
		boss[i]:SetPoint("BOTTOMLEFT", boss[i-1], "TOPLEFT", 0, 5)
	end
end