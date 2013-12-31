------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF or oUF

------------------------------------------------------------------------
-- Config
------------------------------------------------------------------------
local titleFont = [[Interface\AddOns\oUF_Ynarah\media\big_noodle_titling.ttf]]
local normalFont = STANDARD_TEXT_FONT
local blockFont = [[Interface\AddOns\oUF_Ynarah\media\squares.ttf]]
local dotFont = [[Interface\AddOns\oUF_Ynarah\media\PIZZADUDEBULLETS.ttf]]

local backdropTexture = [[Interface\ChatFrame\ChatFrameBackground]]
local backdrop = {
  bgFile = backdropTexture,
  edgeFile = backdropTexture,
  edgeSize = 1,
  insets = { left = -1, right = -1, top = -1, bottom = -1}
  }
local backdropColor = { .1, .1, .1, .5 }
local backdropbordercolor = { .6, .6 , .6, .5 }

-- local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\statusbar]]
-- local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\Neal.blp]]
local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\Striped.tga]]

local playerSize = {250, 50}
local totSize = {125, 26}
local partySize = {125, 26}

------------------------------------------------------------------------
-- Custom functions
------------------------------------------------------------------------
local function PostCreateAura(element, button)
  -- button.cd.noCooldownCount = true
  button:SetBackdrop(backdrop)
  button:SetBackdropColor(0, 0, 0)
  button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  button.icon:SetDrawLayer('ARTWORK')
end

local function PostUpdateDebuff(element, unit, button, index)
  local _, _, _, _, type, _, _, owner = UnitAura(unit, index, button.filter)
  local color = DebuffTypeColor[type or 'none']
  button:SetBackdropColor(color.r * 3/5, color.g * 3/5, color.b * 3/5)
end



------------------------------------------------------------------------
-- UnitSpecific setups
------------------------------------------------------------------------
local UnitSpecific = {
  player = function(self)
    -- player unique
    self:SetSize(unpack(playerSize))

    -----------------------------
    -- HP and PP values
    local HPPoints = ns.SetFontString(self.Health, titleFont, 15, 'LEFT', self.Health, 'LEFT', 5, 0)
    self:Tag(HPPoints, '[yna:health] [(>perhp<%)]')
    self.Health.values = HPPoints

    local PPPoints = ns.SetFontString(self.Health, titleFont, 15, 'RIGHT', self.Health, 'RIGHT', 0, 0)
    self:Tag(PPPoints, '[powercolor][perpp<%] [yna:druidpower]|r ')
    self.Power.values = PPPoints

    -----------------------------
    -- Totems
    local Totems = {}
      for index = 1, MAX_TOTEMS do
        -- Position and size of the totem indicator
        local Totem = CreateFrame('Button', nil, self)
        Totem:SetSize(40, 40)
        Totem:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Totem:GetWidth(), 0)

        local Icon = Totem:CreateTexture(nil, 'OVERLAY')
        Icon:SetAllPoints()

        local Cooldown = CreateFrame('Cooldown', nil, Totem)
        Cooldown:SetAllPoints()

        Totem.Icon = Icon
        Totem.Cooldown = Cooldown

        Totems[index] = Totem
      end
    self.Totems = Totems

    -----------------------------
    -- SpecPower/ComboPoints -- since you know you can only have one :P
    self.stacker = ns.SetFontString(self.Health, titleFont, 40, 'BOTTOM', self.Health, 'TOPRIGHT', 0, -1)
    self:Tag(self.stacker, '[raidcolor][cpoints][shadoworbs][soulshards][holypower][chi]|r')

    -----------------------------
    -- Resting
    local Resting = ns.SetFontString(self.Health, blockFont, 16, 'BOTTOMRIGHT', self.Health, 'BOTTOMLEFT', 1, -3)
    Resting:SetText('|cffffcc33z|r')
    self.Resting = Resting

    -----------------------------
    -- Combat
    local Combat = ns.SetFontString(self.Health, blockFont, 16, 'RIGHT', self.Health, 'LEFT', 1, 0)
    Combat:SetText('|cffc41f3bc|r')
    self.Combat = Combat

    -----------------------------
    -- PvP
    local pvp = ns.SetFontString(self.Health, blockFont, 16, 'TOPRIGHT', self.Health, 'TOPLEFT', 1, 3)
    pvp:SetText('|cffccff00p|r')
    self.PvP = pvp

    -----------------------------
    -- Threat
    local Threat = ns.SetFontString(self.Health, titleFont, 30, 'CENTER', self.Health, 'CENTER', 1, 0)
    self:Tag(Threat, '[threatcolor][threat<|r]')
    self.Threat = Threat

    -----------------------------
    -- Auras
    self.Buffs.PostCreateIcon = PostCreateAura
    self.Buffs.CustomFilter = ns.FilterPlayerBuffs

    self.Debuffs.PostCreateIcon = PostCreateAura
    self.Debuffs.PostUpdateIcon = PostUpdateDebuff
  end,

  target = function(self)
    self:SetSize(unpack(playerSize))

    -----------------------------
    -- HP and PP values
    local HPPoints = ns.SetFontString(self.Health, titleFont, 15, 'LEFT', self.Health, 'LEFT', 5, 0, nil)
    self:Tag(HPPoints, '[|cffc41f3b>dead<|r][|cff999999>offline<|r][unitcolor][yna:health<|r] [(>perhp<%)]')
    self.Health.values = HPPoints

    local PPPoints = ns.SetFontString(self.Health, titleFont, 15, 'RIGHT', self.Health, 'RIGHT', 0, 0, nil)
    self:Tag(PPPoints, '[powercolor][perpp<%]|r')
    self.Power.values = PPPoints

    -----------------------------
    -- Auras
    self.Debuffs.onlyShowPlayer = true
    self.Debuffs.PostCreateIcon = PostCreateAura
    self.Debuffs.PostUpdateIcon = PostUpdateDebuff

    local Name = ns.SetFontString(self.Health, titleFont, 15, 'TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2, nil)
    self:Tag(Name, '[yna:shortname]')

    local Level = ns.SetFontString(self.Health, titleFont, 15, 'TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -2, nil)
    self:Tag(Level, '[difficulty<][L>smartlevel<|r] [smartclass]')
  end,

  targettarget = function(self)
    self:SetSize(unpack(partySize))

    local Name = ns.SetFontString(self.Health, titleFont, 13, 'LEFT', self.Health, 'LEFT', 1, 0, nil)
    self:Tag(Name, '[yna:shortname]')

    -----------------------------
    -- HP and PP values
    local HPPoints = ns.SetFontString(self.Health, titleFont, 13, 'RIGHT', self.Health, 'RIGHT', -1, 0, nil)
    self:Tag(HPPoints, '[|cffc41f3b>dead<|r][|cff999999>offline<|r][perhp<%]')
    self.Health.values = HPPoints
  end,

  party = function(self)
    -- self:SetSize(unpack(partySize))

    -- local Name = ns.SetFontString(self.Health, titleFont, 13, 'LEFT', self.Health, 'LEFT', 1, 0, nil)
    -- self:Tag(Name, '[name]')
    local name = self.Health:CreateFontString(nil, "OVERLAY")
        name:SetPoint('LEFT', self.Health, 'LEFT', 1, 0)
        name:SetFontObject(GameFontNormalSmall)
        name:SetTextColor(1, 1, 1)

        self.Name = name

    -- -----------------------------
    -- -- HP and PP values
    -- local HPPoints = ns.SetFontString(self.Health, titleFont, 13, 'RIGHT', self.Health, 'RIGHT', -1, 0, nil)
    -- self:Tag(HPPoints, '[|cffc41f3b>dead<|r][|cff999999>offline<|r][perhp<%]')
    -- self.Health.values = HPPoints

    -- -----------------------------
    -- -- Debuffies
    -- local debuffies = ns.SetFontString(self.Health, titleFont, 13, 'RIGHT', self.Health, 'RIGHT', -1, 0, nil)
    -- self:Tag(debuffies,'[disease][magic][curse][poison]')

  end,

  boss = function(self)
    self:SetSize(unpack(playerSize))

    local Name = ns.SetFontString(self.Health, titleFont, 15, 'TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2, nil)
    self:Tag(Name, '[yna:shortname]')
  end,
}
-- UnitSpecific.raid = UnitSpecific.party  -- raid is equal to party
UnitSpecific.focus = UnitSpecific.targettarget
UnitSpecific.focustarget = UnitSpecific.targettarget
UnitSpecific.pet = UnitSpecific.targettarget

------------------------------------------------------------------------
-- Shared Setup
------------------------------------------------------------------------
local function Shared(self, unit, isSingle)
  self:SetScript('OnEnter', UnitFrame_OnEnter)
  self:SetScript('OnLeave', UnitFrame_OnLeave)

  self:RegisterForClicks'AnyUp'

  self.colors.power.MANA = {0, 144/255, 1} -- I still find mana too bright

  -- shared setup
  -- self:SetBackdrop(backdrop)
  -- self:SetBackdropColor(unpack(backdropColor))
  -- self:SetBackdropBorderColor(unpack(backdropbordercolor))

  ----------------------------------------
  -- Powerbar
  local Power = CreateFrame('StatusBar', nil, self)
  if( unit == 'player' or unit == 'target' ) then
    Power:SetHeight(25)
  else
    Power:SetHeight(12)
  end
  Power:SetStatusBarTexture(statusbarTexture)

  local powerBackground = Power:CreateTexture(nil, 'BACKGROUND')
  powerBackground:SetPoint('TOPLEFT', Power, -1, 1)
  powerBackground:SetPoint('BOTTOMRIGHT', Power, 1, -1)
  powerBackground:SetTexture(statusbarTexture)
  powerBackground.multiplier = .3

  Power.frequentUpdates = true
  Power.colorPower = true
  Power.colorClassNPC = true
  Power.colorClassPet = true

  Power:SetPoint('TOP')
  Power:SetPoint('LEFT')
  Power:SetPoint('RIGHT')

  self.Power = Power
  self.Power.bg = powerBackground

  ----------------------------------------
  -- Healthbar
  local Health = CreateFrame('StatusBar', nil, Power or self)
  Health:SetPoint('TOPLEFT', Power, 'TOPLEFT', 8, -8)
  Health:SetPoint('TOPRIGHT', Power, 'TOPRIGHT', 8, -8)
  Health:SetStatusBarTexture(statusbarTexture)
  if( unit == 'player' or unit == 'target' ) then
    Health:SetHeight(25)
  else
    Health:SetHeight(12)
  end
  Health:SetStatusBarColor(.9, .9, .9)
  Health.frequentUpdates = true

  Health.colorTapping = true
  Health.colorDisconnected = true
  Health.colorClass = true
  Health.colorClassPet = true
  Health.colorReaction = true
  Health.colorSmooth = true
  Health.colorHealth = true

  local healthBackground = Health:CreateTexture(nil, 'BACKGROUND')
  healthBackground:SetPoint('TOPLEFT', Health, -1, 1)
  healthBackground:SetPoint('BOTTOMRIGHT', Health, 1, -1)
  healthBackground:SetTexture(statusbarTexture)
  -- healthBackground:SetVertexColor(.1, .1, .1)

  -- Make the background darker.
  healthBackground.multiplier = .3

  self.Health = Health
  self.Health.bg = healthBackground

  ----------------------------------------
  -- Castbar

  ----------------------------------------
  -- Auras
  if (unit == 'player' or unit == 'target') then
    local Buffs = CreateFrame('Frame', nil, self)
    Buffs:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -5)
    Buffs:SetSize(unpack(playerSize))
    Buffs.size = 30
    Buffs['spacing-x'] = 5
    Buffs['spacing-y'] = 4
    Buffs.initialAnchor = 'TOPLEFT'
    Buffs['growth-y'] = 'DOWN'
    self.Buffs = Buffs

    local Debuffs = CreateFrame('Frame', nil, self)
    Debuffs:SetPoint('BOTTOMLEFT', self.Power, 'TOPLEFT', 8, -12)
    Debuffs:SetSize(unpack(playerSize))
    Debuffs.size = 30
    Debuffs['spacing-x'] = 5
    Debuffs.initialAnchor = 'TOPLEFT'
    Debuffs['growth-y'] = 'UP'
    self.Debuffs = Debuffs -- Register with oUF
  end

  ----------------------------------------
  -- Enable Plugins
  self.Range = {
    insideAlpha = 1,
    outsideAlpha = 0.5,
  }
  self.MoveableFrames = true

  -- leave this in!!
  if(UnitSpecific[unit]) then
    return UnitSpecific[unit](self)
  end
end

------------------------------------------------------------------------
-- oUF Factory
------------------------------------------------------------------------
oUF:RegisterStyle('Ynarah', Shared)
oUF:Factory(function(self)
  self:SetActiveStyle('Ynarah')
  self:Spawn('player'):SetPoint('CENTER', -300, -75)
  self:Spawn('pet'):SetPoint('TOPRIGHT', oUF_YnarahPlayer, 'BOTTOMRIGHT', 0, -15)
  self:Spawn('target'):SetPoint('CENTER', 300, -75)
  self:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF_YnarahTarget, 'BOTTOMRIGHT', 0, -25)
  self:Spawn('focus'):SetPoint('CENTER', -325, -10)
  self:Spawn('focustarget'):SetPoint('LEFT', oUF_YnarahFocus, 'RIGHT', 15, 0)

  self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; hide',
    'showParty', true, 'showRaid', true, 'showPlayer', true, 'yOffset', -15,
    'oUF-initialConfigFunction', [[
      self:SetHeight(25)
      self:SetWidth(125)
    ]]
  ):SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', -5, -50)

  for index = 1, MAX_BOSS_FRAMES do
    local boss = self:Spawn('boss' .. index)

    if(index == 1) then
      boss:SetPoint('TOP', oUF_YnarahRaid or Minimap, 'BOTTOM', 0, -20)
    else
      boss:SetPoint('TOP', _G['oUF_YnarahBoss' .. index - 1], 'BOTTOM', 0, -6)
    end

    local blizzardFrames = _G['Boss' .. index .. 'TargetFrame']
    blizzardFrames:UnregisterAllEvents()
    blizzardFrames:Hide()
  end
end)