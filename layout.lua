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

local statusbarTexture = [[Interface\TARGETINGFRAME\UI-StatusBar.blp]]
-- local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\pHishTex.tga]]
-- local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\pHishTex6.tga]]
-- local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\pHishTex9.tga]]
-- local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\statusbar]]
-- local statusbarTexture = [[Interface\AddOns\oUF_Ynarah\media\Striped.tga]]

local playerSize = {250, 50}
local totSize = {125, 26}

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
    self.Health.values = ns.SetFontString(self.Health, titleFont, 15, 'LEFT', self.Health, 'LEFT', 5, 0)
    self:Tag(self.Health.values, '[yna:health] [(>perhp<%)]')

    self.Power.values = ns.SetFontString(self.Health, titleFont, 15, 'RIGHT', self.Health, 'RIGHT', 0, 0)
    self:Tag(self.Power.values, '[powercolor][perpp<%] [yna:druidpower]|r ')

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
    self.Resting = ns.SetFontString(self.Health, blockFont, 16, 'BOTTOMRIGHT', self.Health, 'BOTTOMLEFT', 1, -3)
    self.Resting:SetText('|cffffcc33z|r')

    -----------------------------
    -- Combat
    self.Combat = ns.SetFontString(self.Health, blockFont, 16, 'RIGHT', self.Health, 'LEFT', 1, 0)
    self.Combat:SetText('|cffc41f3bc|r')

    -----------------------------
    -- Threat
    self.Threat = ns.SetFontString(self.Health, titleFont, 50, 'CENTER', self.Health, 'CENTER', 1, 0)
    self:Tag(self.Threat, '[threatcolor][threat<|r]')

    -----------------------------
    -- Auras
    self.Buffs = CreateFrame('Frame', nil, self)
    self.Buffs:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -5)
    self.Buffs:SetSize(unpack(playerSize))
    self.Buffs.size = 30
    self.Buffs['spacing-x'] = 5
    self.Buffs['spacing-y'] = 4
    self.Buffs.initialAnchor = 'TOPLEFT'
    self.Buffs['growth-y'] = 'DOWN'
    self.Buffs.PostCreateIcon = PostCreateAura
    self.Buffs.CustomFilter = ns.FilterPlayerBuffs

    self.Debuffs = CreateFrame('Frame', nil, self)
    self.Debuffs:SetPoint('BOTTOMLEFT', self.Power, 'TOPLEFT', 8, -12)
    self.Debuffs:SetSize(unpack(playerSize))
    self.Debuffs.size = 30
    self.Debuffs['spacing-x'] = 5
    self.Debuffs.initialAnchor = 'TOPLEFT'
    self.Debuffs['growth-y'] = 'UP'
    self.Debuffs.PostCreateIcon = PostCreateAura
    self.Debuffs.PostUpdateIcon = PostUpdateDebuff
  end,

  target = function(self)
    self:SetSize(unpack(playerSize))

    -----------------------------
    -- HP and PP values
    self.Health.values = ns.SetFontString(self.Health, titleFont, 15, 'LEFT', self.Health, 'LEFT', 5, 0, nil)
    self:Tag(self.Health.values, '[|cffc41f3b>dead<|r][|cff999999>offline<|r][unitcolor][yna:health<|r] [(>perhp<%)]')

    self.Power.values = ns.SetFontString(self.Health, titleFont, 15, 'RIGHT', self.Health, 'RIGHT', 0, 0, nil)
    self:Tag(self.Power.values, '[powercolor][perpp<%]|r')

    -----------------------------
    -- Auras
    self.Buffs = CreateFrame("frame", nil, self)
    self.Buffs:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', -8, -20)
    self.Buffs:SetSize(unpack(playerSize))
    self.Buffs.size = 27
    self.Buffs['spacing-x'] = 5
    self.Buffs.initialAnchor = 'TOPLEFT'
    self.Buffs['growth-y'] = 'DOWN'
    self.Buffs.onlyShowPlayer = true
    self.Buffs.CustomFilter = ns.FilterTargetBuffs
    self.Buffs.PostCreateIcon = PostCreateAura

    self.Debuffs = CreateFrame('Frame', nil, self)
    self.Debuffs:SetPoint('BOTTOMLEFT', self.Power, 'TOPLEFT', 8, -12)
    self.Debuffs:SetSize(unpack(playerSize))
    self.Debuffs.size = 30
    self.Debuffs['spacing-x'] = 5
    self.Debuffs.initialAnchor = 'TOPLEFT'
    self.Debuffs['growth-y'] = 'UP'
    self.Debuffs.onlyShowPlayer = true
    self.Debuffs.PostCreateIcon = PostCreateAura
    self.Debuffs.PostUpdateIcon = PostUpdateDebuff

    local Name = ns.SetFontString(self.Health, titleFont, 15, 'TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2, nil)
    self:Tag(Name, '[yna:shortname]')

    local Level = ns.SetFontString(self.Health, titleFont, 15, 'TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -2, nil)
    self:Tag(Level, '[difficulty<][L>smartlevel<|r] [smartclass]')
  end,

  targettarget = function(self)
    self:SetSize(unpack(totSize))

    local Name = ns.SetFontString(self.Health, titleFont, 13, 'LEFT', self.Health, 'LEFT', 1, 0, nil)
    self:Tag(Name, '[yna:shortname]')

    -----------------------------
    -- HP and PP values
    self.Health.values = ns.SetFontString(self.Health, titleFont, 13, 'RIGHT', self.Health, 'RIGHT', -1, 0, nil)
    self:Tag(self.Health.values, '[|cffc41f3b>dead<|r][|cff999999>offline<|r][perhp<%]')
  end,

  party = function(self, ...)
    local Name = ns.SetFontString(self.Health, titleFont, 13, 'LEFT', self.Health, 'LEFT', 1, 0, nil)
    self:Tag(Name, '[yna:shortname]')

    -----------------------------
    -- HP and PP values
    self.Health.values = ns.SetFontString(self.Health, titleFont, 13, 'RIGHT', self.Health, 'RIGHT', -1, 0, nil)
    self:Tag(self.Health.values, '[perhp<%]')

    -----------------------------
    -- Debuffies
    local debuffies = ns.SetFontString(self.Health, titleFont, 20, 'LEFT', self.Health, 'LEFT', -1, 0, nil)
    self:Tag(debuffies,'[disease][magic][curse][poison]')

  end,

  boss = function(self)
    self:SetSize(unpack(playerSize))

    local Name = ns.SetFontString(self.Health, titleFont, 15, 'TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -2)
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
  -- turn "boss2" into "boss" for example
  unit = gsub(unit, "%d", "")

  self:SetScript('OnEnter', UnitFrame_OnEnter)
  self:SetScript('OnLeave', UnitFrame_OnLeave)

  self:RegisterForClicks'AnyUp'

  self.colors.power.MANA = {0, 144/255, 1} -- I still find mana too bright

  -- shared setup
  -- self:SetBackdrop(backdrop)
  -- self:SetBackdropColor(unpack(backdropColor))
  -- self:SetBackdropBorderColor(unpack(backdropbordercolor))

  ----------------------------------------
  -- Healthbar
  local Health = CreateFrame('StatusBar', nil, self)
  Health:SetStatusBarTexture(statusbarTexture)
  if( unit == 'player' or unit == 'target' ) then
    Health:SetHeight(25)
  else
    Health:SetHeight(12)
  end
  Health:SetPoint('TOP')
  Health:SetPoint('LEFT')
  Health:SetPoint('RIGHT')

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
  -- Powerbar
  if( unit == 'player' or unit == 'target' ) then
    local Power = CreateFrame('StatusBar', nil, self)
    Power:SetFrameLevel(Health:GetFrameLevel()-1)
    Power:SetPoint('TOPLEFT', Health, 'TOPLEFT', -8, 8)
    Power:SetPoint('TOPRIGHT', Health, 'TOPRIGHT', -8, 8)

    Power:SetHeight(25)
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

    self.Power = Power
    self.Power.bg = powerBackground
  end

  -----------------------------
  -- PvP
  local PvP = ns.SetFontString(self.Health, titleFont, 16, 'CENTER', self.Health, 'CENTER', 0, 0)
  self:Tag(PvP, '[yna:pvp]')

  ----------------------------------------
  -- Castbar

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

  self:SpawnHeader('oUF_YnarahParty', nil,
    'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; show',
    'showParty', true,
    'showPlayer', true,
    'showSolo', true,
    'yOffset', -15,
    'oUF-initialConfigFunction', [[
      self:SetHeight(25)
      self:SetWidth(125)
    ]]
  ):SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', -5, -50)

  for index = 1, MAX_BOSS_FRAMES do
    local boss = self:Spawn('Boss' .. index)

    if(index == 1) then
      boss:SetPoint('TOPRIGHT', oUF_YnarahRaid or BOTTOMRIGHT, 'BOTTOM', -5, -50)
    else
      boss:SetPoint('TOP', _G['oUF_YnarahBoss' .. index - 1], 'BOTTOM', 0, -6)
    end

    local blizzardFrames = _G['Boss' .. index .. 'TargetFrame']
    blizzardFrames:UnregisterAllEvents()
    blizzardFrames:Hide()
  end

    -- Remove irrelevant rightclick menu entries
  for _, menu in pairs(UnitPopupMenus) do
    for i = #menu, 1, -1 do
      local name = menu[i]
      if name == "SET_FOCUS" or name == "CLEAR_FOCUS" or name:match("^LOCK_%u+_FRAME$") or name:match("^UNLOCK_%u+_FRAME$") or name:match("^MOVE_%u+_FRAME$") or name:match("^RESET_%u+_FRAME_POSITION") then
        tremove(menu, i)
      end
    end
  end
end)