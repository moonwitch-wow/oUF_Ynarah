--[[

  Kelly Crabbe grants anyone the right to use this work for any purpose,
  without any conditions, unless such conditions are required by law.

--]]

---------------------------------------------------------------------
-- Namespacing teh shit out of this
---------------------------------------------------------------------
local _, oUFYna = ...

---------------------------------------------------------------------
-- Aura Skinning
---------------------------------------------------------------------
oUFYna.PostCreateAura = function(element, button)
	button.showType = true
	button.count:ClearAllPoints()
	button.count:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -1, 2)
	button.overlay:SetTexture(border)
	button.overlay:SetTexCoord(0, 1, 0, 1)
	button.overlay.Hide = function(self) self:SetVertexColor(0.25, 0.25, 0.25) end
	button.icon:SetTexCoord(.07, .93, .07, .93)
end

---------------------------------------------------------------------
-- HP BG Updater
---------------------------------------------------------------------
oUFYna.updateHealthBG = function(self, event, unit, bar, min, max)
	element.__owner.HealPrediction:ForceUpdate()
	if (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) or not UnitIsConnected(unit)) then
		local color = self.colors.tapped
		bar.bg:SetVertexColor(color[1] * 0.4, color[2] * 0.4, color[3]* 0.4)
	else
		local _, class = UnitClass(unit)
		local color =  UnitIsPlayer(unit) and self.colors.class[class] or self.colors.reaction[UnitReaction(unit, 'player')] or {1,1,1}
		bar.bg:SetVertexColor(color[1] * 0.4, color[2] * 0.4, color[3]* 0.4)
	end
end

---------------------------------------------------------------------
-- Hellish functions UnitSpecific and Shared... new shit :(
---------------------------------------------------------------------
local UnitSpecific = {
	player = function(self)	
		self:SetWidth(plWidth+4)
		self:SetHeight(hpHeight+ppHeight+6)
		self.Power:SetHeight(ppHeight)
		
		self:SetBackdrop(backdrop)
		self:SetBackdropColor(.1,.1,.1,1)
		self:SetBackdropBorderColor(.6,.6,.6,1)
	
		self.Power.value = SetFontString(self.Health, font, fontSize+1, 'LEFT', self.Health, 'LEFT', 2, 0)
		self.Power.value:SetTextColor(1, 1, 1)
		self:Tag(self.Power.value, '[yna:colorpp][curpp< ] [yna:druidpower]|r ')
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, 'RIGHT', self.Health, 'RIGHT', -2, 0)
		self:Tag(self.Health.value, '[curhp]')

		if(IsAddOnLoaded('oUF_Swing')) then
			self.Swing = CreateFrame('StatusBar', nil, self)
			self.Swing:SetBackdrop(backdrop)
			self.Swing:SetBackdropColor(.1,.1,.1,1)
			self.Swing:SetBackdropBorderColor(.6,.6,.6,1)
			
			self.Swing:SetPoint('TOP', self.Health, 'BOTTOM', 0, 0)
			--self.Swing:SetStatusBarTexture(texture)
			--self.Swing.textureBG = texture
			--self.Swing:SetStatusBarColor(1, 0.7, 0)
			self.Swing.texture = texture
			self.Swing.color = {1, 0.7, 0, 0.8}
			self.Swing:SetHeight(1)
			self.Swing:SetWidth(plWidth)
			
			self.Swing.hideOoc = true
		end

		self.Resting = SetFontString(self.Health, font, fontSize, 'CENTER', self.Health, 'CENTER', 0, 2)
		self.Resting:SetText('[R]')
		self.Resting:SetTextColor(1, .6, .13)

		self.Spark = self.Power:CreateTexture(nil, 'OVERLAY')
		self.Spark:SetTexture('Interface\\CastingBar\\UI-CastingBar-Spark')
		self.Spark:SetVertexColor(1, 1, 1, 1)
		self.Spark:SetBlendMode('ADD')
		self.Spark:SetHeight(self.Power:GetHeight()*4.5)
		self.Spark:SetWidth(4)
		
		self.Debuffs = CreateFrame('Frame', nil, self)
		self.Debuffs:SetPoint('RIGHT', self.Health, 'LEFT', -10, -4)
		self.Debuffs:SetHeight(hpHeight+ppHeight+8)
		self.Debuffs:SetWidth(plWidth)
		self.Debuffs.size = hpHeight+ppHeight+8
		self.Debuffs.spacing = 2
		self.Debuffs.initialAnchor = 'TOPRIGHT'
		self.Debuffs['growth-x'] = 'LEFT'
		self.Debuffs['growth-y'] = 'DOWN'
		self.Debuffs.showDebuffType = true
		self.Debuffs.PostCreateIcon = PostCreateAura
		RuneFrame:Hide()
		
		if select(2, UnitClass('player')) == 'PRIEST' then
			self.Priestly = SetFontString(self.Health, font, 25, 'BOTTOMLEFT', self.Health, 'TOPRIGHT', 25, 15)
			self:Tag(self.Priestly, '|cff68228b[yna:ShadowOrbs]|r|cffeedd82[yna:Evangelism]|r')
		end
		
		-- Runes
		if select(2, UnitClass('player')) == 'DEATHKNIGHT' then
			RuneFrame:Hide()
			self.Runes = CreateFrame('Frame', nil, self)
			self.Runes:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -1)
			self.Runes:SetSize(plWidth, 5)
			self.Runes:SetBackdrop{
				bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = true, tileSize = 16,
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
				self.Runes[i] = CreateFrame('StatusBar', nil, self.Runes)
				self.Runes[i]:SetStatusBarTexture(texture)
				self.Runes[i]:SetHeight(3)
				self.Runes[i].growth = 'RIGHT'
				self.Runes[i]:SetWidth((plWidth-5)/6)
				
				if (i == 1) then
					self.Runes[i]:SetPoint('TOPLEFT', self.Runes, 'TOPLEFT', 0, -1)
				else
					self.Runes[i]:SetPoint('LEFT', self.Runes[i-1], 'RIGHT', 1, 0)
				end
				
				self.Runes[i].bg = self.Runes[i]:CreateTexture(nil, 'BACKGROUND')
				self.Runes[i].bg:SetAllPoints(self.Runes[i])
				self.Runes[i].bg:SetTexture(0.3, 0.3, 0.3)
				self.Runes[i].bg.multiplier = .8
			end
		end
	
		-- Totems
		if (select(2, UnitClass('player')) == 'SHAMAN') then
			self.Totems = CreateFrame('Frame', nil, self)
			
			for i = 1, 4 do
				self.Totems[i] = CreateFrame('StatusBar', nil, self.Totems)
				self.Totems[i]:SetSize(plWidth/5 - .85, 10)
				self.Totems[i]:SetStatusBarTexture(texture)
				
				if (i == 1) then
					self.Totems[1]:SetPoint('RIGHT', self, 'TOPRIGHT', -2, 0)
				else
					self.Totems[i]:SetPoint('TOPRIGHT', self.Totems[i-1], 'TOPLEFT', -1, 0)
				end
				
				self.Totems[i].bg = self.Totems[i]:CreateTexture(nil, 'BACKGROUND')
				self.Totems[i].bg:SetAllPoints(self.Totems[i])
				self.Totems[i].bg:SetTexture(texture)
				self.Totems[i].bg.multiplier = 0.25
			end
			
			self.Totems[1]:SetStatusBarColor(unpack(self.colors.totems[FIRE_TOTEM_SLOT]))
			self.Totems[2]:SetStatusBarColor(unpack(self.colors.totems[EARTH_TOTEM_SLOT]))
			self.Totems[3]:SetStatusBarColor(unpack(self.colors.totems[WATER_TOTEM_SLOT]))
			self.Totems[4]:SetStatusBarColor(unpack(self.colors.totems[AIR_TOTEM_SLOT]))
		end
		
		--[[ Totembar
		if(IsAddOnLoaded('oUF_boring_TotemBar') and select(2, UnitClass('player')) == 'SHAMAN') then
			self.TotemBar = {
				AbbreviateNames = true,
				Destroy = true,
				UpdateColors = true,
			}
					
		for i = 1, 4 do
			self.TotemBar[i] = CreateFrame('Frame', nil, self)
			self.TotemBar[i]:SetHeight(7)
			self.TotemBar[i]:SetWidth(plWidth/4 - 0.85)
			
			if (i == 1) then
				self.TotemBar[i]:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -4)
			else
				self.TotemBar[i]:SetPoint('TOPLEFT', self.TotemBar[i-1], 'TOPRIGHT', 1, 0)
			end

			self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, 'BACKGROUND')
			self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
			self.TotemBar[i].bg:SetTexture(texture)
			self.TotemBar[i].bg.multiplier = 0.25
			
			self.TotemBar[i].StatusBar = CreateFrame('StatusBar', nil)
			self.TotemBar[i].StatusBar:SetStatusBarTexture(texture)
			self.TotemBar[i].StatusBar:SetBackdrop{
				bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
				insets = {left = -2, right = -2, top = -2, bottom = -2},
			}
			self.TotemBar[i].StatusBar:SetHeight(7)
			self.TotemBar[i].StatusBar:SetWidth(plWidth/4 - 0.85)
			
			--self.TotemBar[i]:SetBackdropColor(0, 0, 0, .3)
			--self.TotemBar[i]:SetMinMaxValues(0, 1)
			
			self.TotemBar[i].Time = self.TotemBar:SetFontString(self.TotemBar[i], font, fontSize, 'RIGHT', self.TotemBar[i], 'RIGHT', 0, 2)
			
			self.TotemBar[i].Text = self.TotemBar:SetFontString(self.TotemBar[i], font, fontSize, 'LEFT', self.TotemBar[i], 'LEFT', 0, 2)
			end
		end
		--]]

		-- Eclipsebar
		if select(2, UnitClass('player')) == 'DRUID' then
			self.EclipseBar = CreateFrame('Frame', nil, self)
			self.EclipseBar:SetSize(plWidth, 4)
			self.EclipseBar:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -2)
			self.EclipseBar:SetPoint('TOPRIGHT', self.Power, 'BOTTOMRIGHT', 0, -2)
			self.EclipseBar:SetBackdrop(backdrop)
			self.EclipseBar:SetBackdropColor(.1,.1,.1,1)
			self.EclipseBar:SetBackdropBorderColor(.6,.6,.6,1)
			
			self.EclipseBar.LunarBar = CreateFrame('StatusBar', nil, self.EclipseBar)
			self.EclipseBar.LunarBar:SetPoint('LEFT', self.EclipseBar, 'LEFT', 0, 0)
			self.EclipseBar.LunarBar:SetSize(plWidth, 4)
			self.EclipseBar.LunarBar:SetStatusBarTexture(texture)
			self.EclipseBar.LunarBar:SetStatusBarColor(0, 144/255, 1)
			
			self.EclipseBar.SolarBar = CreateFrame('StatusBar', nil, self.EclipseBar)
			self.EclipseBar.SolarBar:SetPoint('LEFT', self.EclipseBar.LunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
			self.EclipseBar.SolarBar:SetSize(plWidth, 4)
			self.EclipseBar.SolarBar:SetStatusBarTexture(texture)
			self.EclipseBar.SolarBar:SetStatusBarColor(0.95, 0.73, 0.15)
		end
		
		-- HolyPower
		if select(2, UnitClass('player')) ==  'PALADIN' then
			self.HolyPower = CreateFrame('Frame', nil, self)
			self.HolyPower:SetSize(plWidth, 5)
			self.HolyPower:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -2)
			self.HolyPower:SetPoint('TOPRIGHT', self.Power, 'BOTTOMRIGHT', 0, -2)
			self.HolyPower:SetBackdrop(backdrop)
			self.HolyPower:SetBackdropColor(.1,.1,.1,1)
			self.HolyPower:SetBackdropBorderColor(.6,.6,.6,1)
			
			for i = 1, MAX_HOLY_POWER do
				self.HolyPower[i] = self.HolyPower:CreateTexture(nil, 'OVERLAY')
				self.HolyPower[i]:SetSize((plWidth-2)/MAX_HOLY_POWER, 5)
				self.HolyPower[i]:SetTexture(texture)
				self.HolyPower[i]:SetVertexColor(255/255, 234/255, 0)
				
				if (i == 1) then
					self.HolyPower[i]:SetPoint('TOPLEFT', self.HolyPower, 'TOPLEFT', 0, -1)
				else
					self.HolyPower[i]:SetPoint('TOPLEFT', self.HolyPower[i-1], 'TOPRIGHT', 1, 0)
				end
				
				-- so we have a bar when it's depleted
				self.HolyPower[i].bg = self.HolyPower:CreateTexture(nil, 'BACKGROUND')
				self.HolyPower[i].bg:SetAllPoints(self.HolyPower[i])
				self.HolyPower[i].bg:SetTexture(0.3, 0.3, 0.3)
				self.HolyPower[i].bg.multiplier = .8
			end
			self.HolyPower:SetBackdrop{
				bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
				insets = {left = -2, right = -2, top = 0, bottom = -2},
			}
			self.HolyPower:SetBackdropColor(0, 0, 0, .8)
		end

		-- SoulShards
		if select(2, UnitClass('player')) ==  'WARLOCK' then
			self.SoulShards = CreateFrame('Frame', nil, self.Health)
			self.SoulShards:SetSize(self.Health:GetHeight()*3-4, self.Health:GetHeight()-4)
			self.SoulShards:SetPoint('CENTER', self.Health, 'CENTER', 0, 0)
			self.SoulShards:SetBackdrop(backdrop)
			self.SoulShards:SetBackdropColor(.1,.1,.1,1)
			self.SoulShards:SetBackdropBorderColor(.6,.6,.6,1)
			
			for i = 1, SHARD_BAR_NUM_SHARDS do
				self.SoulShards[i] = self.SoulShards:CreateTexture(nil, 'OVERLAY')
				self.SoulShards[i]:SetSize(self.SoulShards:GetHeight(), self.SoulShards:GetHeight()-4)
				self.SoulShards[i]:SetTexture(texture)
				self.SoulShards[i]:SetVertexColor(117/255, 82/255, 221/255)
				
				if (i == 1) then
					self.SoulShards[i]:SetPoint('TOPLEFT', self.SoulShards, 'TOPLEFT', 2, -2)
				else
					self.SoulShards[i]:SetPoint('TOPLEFT', self.SoulShards[i-1], 'TOPRIGHT', 2, 0)
				end
				
				-- so we have a bar when it's depleted
				self.SoulShards[i].bg = self.SoulShards:CreateTexture(nil, 'BACKGROUND')
				self.SoulShards[i].bg:SetAllPoints(self.SoulShards[i])
				self.SoulShards[i].bg:SetTexture(texture)
				self.SoulShards[i].bg.multiplier = .4
			end
		end
		
		-- yay player specs
		self.specPower = SetFontString(self.Health, font, 30, 'CENTER', self.Health, 'CENTER', 0, 3, 'MONOCHROMEOUTLINE')

		if select(2, UnitClass('player')) == "DRUID" then
			self:Tag(self.specPower, '[yna:wm1][yna:wm2][yna:wm3]')
		elseif select(2, UnitClass('player')) == "PRIEST" then
			self:Tag(self.specPower, '[yna:orbs]')
		elseif select(2, UnitClass('player')) == "PALADIN" or select(2, UnitClass('player')) == "WARLOCK" then
			self:Tag(self.specPower, '[yna:sp]')
		elseif select(2, UnitClass('player')) == "SHAMAN" then
			self:Tag(self.specPower, '[yna:ws][yna:ls]')
		end
	end,
	
	target = function(self)
		self:SetWidth(plWidth+4)
		self:SetHeight(hpHeight+ppHeight+6)
		self.Power:SetHeight(ppHeight)
		
		self:SetBackdrop(backdrop)
		self:SetBackdropColor(.1,.1,.1,1)
		self:SetBackdropBorderColor(.6,.6,.6,1)
		
		self.Info = SetFontString(self.Health, font, fontSize+1, 'LEFT', self.Health, 'LEFT', 2, 0)
		self.Info:SetTextColor(1, 1, 1)
		self:Tag(self.Info, '[yna:pp] [perhp]%')
		
		self.Name = SetFontString(self.Health, font, fontSize+1, 'RIGHT', self.Health, 'RIGHT', -2, 0)
		self:Tag(self.Name,'L[difficulty][smartlevel] [race] [raidcolor][yna:shortname] [dead]')
		
		self.Buffs = CreateFrame('Frame', nil, self)
		self.Buffs:SetPoint('TOPLEFT', self.Health, 'BOTTOMRIGHT', 10, 0)
		self.Buffs:SetHeight(hpHeight+ppHeight)
		self.Buffs:SetWidth(plWidth)
		self.Buffs.num = 18
		self.Buffs.size = hpHeight+ppHeight
		self.Buffs.spacing = 2
		self.Buffs.initialAnchor = 'TOPLEFT'
		--self.Buffs.showBuffType = true
		self.Buffs.onlyShowPlayer = true
		self.Buffs.PostCreateIcon = PostCreateAura

		self.Debuffs = CreateFrame('Frame', nil, self)
		self.Debuffs:SetPoint('BOTTOMLEFT', self.Health, 'TOPRIGHT', 10, -3)
		self.Debuffs:SetHeight(hpHeight+ppHeight)
		self.Debuffs:SetWidth(plWidth)
		self.Debuffs.size = hpHeight+ppHeight
		self.Debuffs.spacing = 2
		self.Debuffs.onlyShowPlayer = true
		self.Debuffs.initialAnchor = 'TOPLEFT'
		self.Debuffs['growth-y'] = 'DOWN'
		self.Debuffs.showDebuffType = true
		self.Debuffs.PostCreateIcon = PostCreateAura
		
		self.cPoints = self:CreateFontString(nil, 'OVERLAY', 'SubZoneTextFont')
		self.cPoints:SetPoint('RIGHT', self, 'LEFT', -9, 0)
		self.cPoints:SetTextColor(1, 1, 1)
		self.cPoints:SetJustifyH('RIGHT')
		self.cPoints.unit = PlayerFrame.unit
		self:Tag(self.cPoints, '|cffffffff[cpoints]|r')
		
	
	end,
	
	targettarget = function(self)
		self.Power:Hide()
		self.Health:SetHeight(hpHeight)
		
		self:SetWidth(focWidth+4)
		self:SetHeight(hpHeight+4)
		
		self:SetBackdrop(backdrop)
		self:SetBackdropColor(.1,.1,.1,1)
		self:SetBackdropBorderColor(.6,.6,.6,1)
		
		self.Name = SetFontString(self.Health, font, fontSize+1, 'LEFT', self.Health, 'RIGHT', 5, 0)
		self:Tag(self.Name, '[raidcolor][yna:shortname] [dead]')
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, 'LEFT', self.Health, 'LEFT', 2, 0)
		self:Tag(self.Health.value, '[yna:colorpp][perpp]%|r | [perhp]%')

		self.Debuffs = CreateFrame('Frame', nil, self)
		self.Debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', -1, -3)
		self.Debuffs:SetHeight(hpHeight)
		self.Debuffs:SetWidth(focWidth)
		self.Debuffs.num = 2
		self.Debuffs.size = hpHeight
		self.Debuffs.spacing = 2
		self.Debuffs.initialAnchor = 'TOPLEFT'
		self.Debuffs['growth-x'] = 'RIGHT'
		self.Debuffs['growth-y'] = 'DOWN'
		self.Debuffs.PostCreateIcon = PostCreateAura
	end,
	
	pet = function(self)
		self.Health:SetHeight(hpHeight)
		self.Power:SetHeight(2)
				
		self:SetWidth(focWidth+4)
		self:SetHeight(hpHeight+8)
		
		self:SetBackdrop(backdrop)
		self:SetBackdropColor(.1,.1,.1,1)
		self:SetBackdropBorderColor(.6,.6,.6,1)
		
		self.Name = SetFontString(self.Health, font, fontSize+1, 'RIGHT', self.Health, 'LEFT', -5, 0)
		self:Tag(self.Name, '[raidcolor][yna:shortname] [dead]')
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, 'RIGHT', self.Health, 'RIGHT', -2, 0)
		self:Tag(self.Health.value, '[yna:colorpp][perpp]%|r|[perhp]%')
	end,
	
	focus = function(self)
		self.Power:Hide()
				
		self:SetWidth(189)
		self:SetHeight(24)
		
		self:SetBackdrop(backdrop)
		self:SetBackdropColor(.1,.1,.1,1)
		self:SetBackdropBorderColor(.6,.6,.6,1)
		
		self.Name = SetFontString(self.Health, font, fontSize+1, 'LEFT', self.Health, 'LEFT', 2, 0)
		self:Tag(self.Name, '[raidcolor][yna:shortname] [dead]')
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, 'RIGHT', self.Health, 'RIGHT', -2, 0)
		self:Tag(self.Health.value, '[yna:colorpp][perpp]%|r | [perhp]%')
		--[[
		self.Buffs = CreateFrame('Frame', nil, self)
		self.Buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 5)
		self.Buffs:SetHeight(hpHeight-1)
		self.Buffs:SetWidth(focWidth)
		self.Buffs.num = 10
		self.Buffs.size = hpHeight-1
		self.Buffs.spacing = 1
		self.Buffs.initialAnchor = 'TOPLEFT'
		self.Buffs.PostCreateIcon = PostCreateAura
		--]]
	end,
	
	focustarget = function(self)
		self.Power:Hide()
				
		self:SetWidth(189)
		self:SetHeight(24)
		
		self:SetBackdrop(backdrop)
		self:SetBackdropColor(.1,.1,.1,1)
		self:SetBackdropBorderColor(.6,.6,.6,1)
		
		self.Name = SetFontString(self.Health, font, fontSize+1, 'LEFT', self.Health, 'LEFT', 2, 0)
		self:Tag(self.Name, '[raidcolor][yna:shortname] [dead]')
		
		self.Health.value = SetFontString(self.Health, font, fontSize+1, 'RIGHT', self.Health, 'RIGHT', -2, 0)
		self:Tag(self.Health.value, '[yna:colorpp][perpp]%|r | [perhp]%')
	end,
}

local function Shared(self, unit)
	self.colors.power.MANA = {0, 144/255, 1}
	
	self:RegisterForClicks('AnyDown')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	self.menu = SpawnMenu
	
	-- HP FG
	self.Health = CreateFrame('StatusBar', nil, self)
	self.Health:SetPoint('TOPLEFT', self, 'TOPLEFT', 2, -2)
	self.Health:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -2, -2)
	self.Health:SetStatusBarTexture(texture)
	self.Health:SetHeight(hpHeight)
	self.Health:SetStatusBarColor(100/255, 111/255, 101/255)
	self.Health.frequentUpdates = true
	
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
	self.Power:SetHeight(ppHeight)
	self.Power.frequentUpdates = true
	
	self.Power.colorClass = true
	self.Power.colorTapped = true
	self.Power.colorReaction = true
	
	-- PP BG
	self.Power.bg = self.Power:CreateTexture(nil, 'BACKGROUND')
	self.Power.bg:SetAllPoints(self.Power)
	self.Power.bg:SetTexture(texture)
	self.Power.bg.multiplier = .2
	
	-- Castbar
	if unit == 'player' or unit == 'target' or unit == 'focus' or unit == 'pet' then
		self.Castbar = CreateFrame('StatusBar')
		
		self.Castbar2 = CreateFrame('StatusBar', nil, self.Castbar)
		self.Castbar2:SetPoint('BOTTOMRIGHT', self.Castbar, 'BOTTOMRIGHT', 2, -2)
		self.Castbar2:SetPoint('TOPLEFT', self.Castbar, 'TOPLEFT', -2, 2)
		self.Castbar2:SetWidth(plWidth+4)
		self.Castbar2:SetHeight(ppHeight+4)
		self.Castbar2:SetFrameLevel(0)
		
		self.Castbar2:SetBackdrop(backdrop)
		self.Castbar2:SetBackdropColor(.1,.1,.1,1)
		self.Castbar2:SetBackdropBorderColor(.6,.6,.6,1)

		if unit == 'player' then
			self.Castbar:SetWidth(plWidth)
			self.Castbar:SetHeight(ppHeight+5)
			self.Castbar:SetParent(oUF.units.player)
			self.Castbar:SetPoint('BOTTOM', oUF.units.player, 'TOP', 0, 4)
		elseif unit == 'target' then
			self.Castbar:SetWidth(plWidth)
			self.Castbar:SetHeight(ppHeight+5)
			self.Castbar:SetParent(oUF.units.target)
			self.Castbar:SetPoint('BOTTOM', oUF.units.target, 'TOP', 0, 4)
		elseif unit == 'focus' then
			self.Castbar:SetWidth(focWidth)
			self.Castbar:SetHeight(ppHeight-1)
			self.Castbar:SetParent(oUF.units.focus)
			self.Castbar:SetPoint('TOP', oUF.units.focus, 'BOTTOM', 0, -4)
		else
			self.Castbar:SetWidth(focWidth)
			self.Castbar:SetHeight(ppHeight)
			self.Castbar:SetParent(oUF.units.pet)
			self.Castbar:SetPoint('TOP', oUF.units.pet, 'BOTTOM', 0, -4)
		end
		
		self.Castbar:SetStatusBarTexture(texture)
		self.Castbar:SetStatusBarColor(65/255, 45/255, 140/255)

		self.Castbar:SetMinMaxValues(1, 100)
		self.Castbar:SetValue(1)
		self.Castbar:Hide()

		self.Castbar.bg = self.Castbar:CreateTexture(nil, 'BORDER')
		self.Castbar.bg:SetAllPoints(self.Castbar)
		self.Castbar.bg:SetAlpha(0.4)

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil,'OVERLAY')
		self.Castbar.SafeZone:SetTexture(texture)
		self.Castbar.SafeZone:SetVertexColor(140/255, 45/255, 65/255,1)
		self.Castbar.SafeZone:SetHeight(self.Castbar:GetHeight())
		self.Castbar.SafeZone:SetBlendMode('DISABLE')

		self.Castbar.Time = self.Castbar:CreateFontString(nil, 'OVERLAY')
		self.Castbar.Time:SetPoint('RIGHT', self.Castbar, 'RIGHT', -4, 0)
		self.Castbar.Time:SetFont(font, fontSize)
		self.Castbar.Time:SetTextColor(1, 1, 1)
		self.Castbar.Time:SetShadowOffset(1, -1)

		self.Castbar.Text = self.Castbar:CreateFontString(nil, 'OVERLAY')
		self.Castbar.Text:SetPoint('LEFT', self.Castbar, 2, 0)
		self.Castbar.Text:SetWidth(oUF.units.player:GetWidth())
		self.Castbar.Text:SetFont(font, fontSize)
		self.Castbar.Text:SetTextColor(1, 1, 1)
		self.Castbar.Text:SetJustifyH'LEFT'
		self.Castbar.Text:SetShadowOffset(1, -1)

		self.Castbar.Icon = self.Castbar:CreateTexture(nil, 'BACKGROUND')
		self.Castbar.Icon:SetHeight(35)
		self.Castbar.Icon:SetWidth(35)
		self.Castbar.Icon:SetTexCoord(.07, .93, .07, .93)
		
		self.Castbar.Icon.overlay = self.Castbar:CreateTexture(nil, 'OVERLAY')
		self.Castbar.Icon.overlay:SetAllPoints(self.Castbar.Icon)
		self.Castbar.Icon.overlay:SetTexture(border)
		
		self.Castbar.Spark = self.Castbar:CreateTexture(nil,'OVERLAY')
		self.Castbar.Spark:SetBlendMode('ADD')
		self.Castbar.Spark:SetHeight(self.Castbar:GetHeight()*2)
		self.Castbar.Spark:SetWidth(10)
		self.Castbar.Spark:SetVertexColor(1,1,1)
		
		self.Castbar.CustomDelayText = function(self, duration)
			self.Time:SetFormattedText('[|cffff0000-%.1f|r] %.1f/%.1f', self.delay, duration, self.max)
		end

		self.Castbar.CustomTimeText = function(self, duration)
			self.Time:SetFormattedText('%.1f / %.1f', self.channeling and duration or (self.max - duration), self.max)
		end
		
		if(unit == 'player') then
			self.Castbar.Icon:SetPoint('TOPLEFT', self.Castbar, 'TOPRIGHT', 12, 0)
		elseif (unit == 'target') then
			self.Castbar.Icon:SetPoint('TOPRIGHT', self.Castbar, 'TOPLEFT', -12, 0)
		end
	end
	
	-- Tags	
	self.PVP = SetFontString(self.Health, font, 13, 'CENTER', self.Health, 'TOP', 0, 0)
	self.PVP:SetTextColor(1, 0, 0)
	self:Tag(self.PVP, '[pvp]')

	self.Leader = SetFontString(self.Health, font, 13, 'CENTER', self.Health, 'TOPLEFT', 0, 0)
	self.Leader:SetTextColor(1, 1, 1)
	self:Tag(self.Leader, '[leader]')

	self.MasterLooter = SetFontString(self.Health, font, 13, 'LEFT', self.Health, 'RIGHT', 0, 0)
	self.MasterLooter:SetTextColor(1, 1, 1)
	self.Tag(self.MasterLooter, '[masterlooter]')

	self.RaidIcon = self.Health:CreateTexture(nil, 'OVERLAY')
	self.RaidIcon:SetHeight(14)
	self.RaidIcon:SetWidth(14)
	self.RaidIcon:SetPoint('CENTER', self.Health, 'TOP')
	
	self.LFDRole = self.Health:CreateTexture(nil, 'OVERLAY')
	self.LFDRole:SetHeight(15)
	self.LFDRole:SetWidth(15)
	self.LFDRole:SetPoint('CENTER', -1, 4)

	self.AFKDND = SetFontString(self.Health, font, 13, 'CENTER', self.Health, 'TOPRIGHT', 0, 0)
	self.AFKDND:SetTextColor(1, 0, 0)
	self:Tag(self.AFKDND, '[yna:AFKDND]')
	
	-- New QuestIcon shit
	self.QuestIcon = self.Health:CreateTexture(nil, 'OVERLAY')
	self.QuestIcon:SetPoint('CENTER', self.Health, 'CENTER')
	
	-- HealPrediction
	local mhpb = CreateFrame('StatusBar',nil,self.Health)
	mhpb:SetStatusBarTexture(texture)
	mhpb:SetStatusBarColor(0.25,1,0,.5)
	mhpb:SetWidth(self:GetWidth())
	mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
	mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
	mhpb:SetFrameLevel(1)
	
	-- Alt Power
	self.AltPowerBar = CreateFrame("StatusBar", nil, self)
	self.AltPowerBar:SetStatusBarTexture(texture)
	self.AltPowerBar:SetHeight(20)
	self.AltPowerBar:SetStatusBarColor(1, 1, 1)
	self.AltPowerBar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT")
	self.AltPowerBar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT")

	self.AltPowerBar.text  = SetFontString(self.Health, font, 13, 'CENTER', self.AltPowerBar, 'TOPRIGHT', 0, 0)	

	-- HealPrediction
	local ohpb = CreateFrame('StatusBar',nil,self.Health)
	ohpb:SetStatusBarTexture(texture)
	ohpb:SetStatusBarColor(0.25,1,0,.5)
	ohpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
	ohpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
	ohpb:SetWidth(self:GetWidth())
	ohpb:SetFrameLevel(1)
	self.HealPrediction = {
		myBar = mhpb,
		otherBar = ohpb,
		maxOverflow = allowOverflow and 1.25 or 1,
		}
		
	-- CombatFeedback (And heals)
	if(IsAddOnLoaded('oUF_CombatFeedback')) then
		self.CombatFeedbackText = SetFontString(self.Health, font, fontSize+1, 'CENTER', self.Health, 'CENTER', 0, 0)
		--self.CombatFeedbackText.ignoreHeal = true -- ignore heals 
		self.CombatFeedbackText:SetShadowOffset(1, -1)
		self.CombatFeedbackText:SetShadowColor(0, 0, 0)
	end
	
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	self.DebuffHighlightAlpha = .5
	
	self.PostUpdateHealth = updateHealthBG
	
	self.SpellRange = true
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.8,
	}
	self.MoveableFrames = true
	self.Health.BarFade = true
	self.Power.BarFade = true
	
	if(UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

oUF.colors.power.MANA = {0, 144/255, 1}

oUF:RegisterStyle('Ynarah', Shared)

oUF:Factory(function(self)
	oUF:SetActiveStyle('Ynarah')
	
	oUF:Spawn('player'):SetPoint('CENTER', -305, -92)
	oUF:Spawn('target'):SetPoint('CENTER', 305, -92)
	oUF:Spawn('targettarget'):SetPoint('TOPLEFT', oUF.units.target, 'BOTTOMLEFT', 0, -15)
	oUF:Spawn('pet'):SetPoint('TOPRIGHT', oUF.units.player, 'BOTTOMRIGHT', 0, -15)
	oUF:Spawn('focus'):SetPoint('TOPLEFT', oUF.units.targettarget, 'BOTTOMLEFT', 0, -5)
	oUF:Spawn('focustarget'):SetPoint('LEFT', oUF.units.focus, 'RIGHT', 10, 0)
end)