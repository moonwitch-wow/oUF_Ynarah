------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF or oUF

------------------------------------------------------------------------
-- Config
------------------------------------------------------------------------
local titleFont = [=[Interface\AddOns\oUF_Ynarah\media\big_noodle_titling.ttf]=]
local normalFont = STANDARD_TEXT_FONT

local backdropTexture = [=[Interface\ChatFrame\ChatFrameBackground]=]
local backdrop = {
  bgFile = backdropTexture,
  edgeFile = backdropTexture,
  edgeSize = 1,
  insets = { left = -1, right = -1, top = -1, bottom = -1}
  }
local backdropColor = { .1, .1, .1, .5 }
local backdropbordercolor = { .6, .6 , .6, .5 }

local statusbarTexture = [=[Interface\AddOns\oUF_Ynarah\media\statusbar]=]

local playerSize = {250, 50}
local totSize = {125, 26}
local partySize = {125, 26}

------------------------------------------------------------------------
-- Util Funcs
------------------------------------------------------------------------
local function SetFontString(parent, fontName, fontHeight, point, anchor, rPoint, xoffset, yoffset, outline)
  local fs = parent:CreateFontString(nil, 'OVERLAY')
  fs:SetFont(fontName, fontHeight, outline)
  fs:SetPoint(point, anchor, rPoint, xoffset, yoffset)
  fs:SetShadowColor(0, 0, 0, .7)
  fs:SetShadowOffset(1, -1)
  return fs
end

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
-- Buff Filters and Debuff filters
------------------------------------------------------------------------
local FilterPlayerBuffs
do
  local spells = {
    -- Priest
    [60062] = true, -- Essence of Life
    [77487] = true, -- Shadow Bollocks
    [124430] = true, -- Divine Insight
    [95740] = true, -- Shadow Orbs
    [104510] = true, -- Windsong Mastery
    [104509] = true, -- Windsong Crit
    [104423] = true, -- Windsong Haste
    [122309] = true, -- Mark of the catacombs
    -- Druid
    [5217] = true, -- Tiger's Fury
    [52610] = true, -- Savage Roar
    [106951] = true, -- Berserk
    [127538] = true, -- Savage Roar (glyphed)
    [124974] = true, -- Nature's Vigil
    [132158] = true, -- Nature's Swiftness
    [132402] = true, -- Savage Defense

    -- Shared
    [32182] = true, -- Heroism
    [57933] = true, -- Tricks of the Trade
    [80353] = true, -- Time Warp
  }

  function FilterPlayerBuffs(...)
    local _, _, _, _, _, _, _, _, _, _, _, _, _, id = ...
      return spells[id]
    end
end

local FilterTargetDebuffs
do
  local show = {
    [1490] = true, -- Curse of Elements (Magic Vulnerability)
    [58410] = true, -- Master Poisoner (Magic Vulnerability)
    [81326] = true, -- Physical Vulnerability (Shared)
    [113746] = true, -- Weakened Armor (Shared)
    [770] = true, -- Faerie Fire
    [58180] = true, -- Infected Wounds
    [115798] = true, -- Weakened Blows
  }

  function FilterTargetDebuffs(...)
    local _, unit, _, _, _, _, _, _, _, _, owner, _, _, id = ...

    if(owner == 'player' and hide[id]) then
      return false
    elseif(owner == 'player' or owner == 'vehicle' or UnitIsFriend('player', unit) or show[id] or not owner) then
      return true
    end
  end
end

------------------------------------------------------------------------
-- UnitSpecific setups
------------------------------------------------------------------------
local UnitSpecific = {
  player = function(self)
    -- player unique
    self:SetSize(unpack(playerSize))

    -----------------------------
    -- ClassIcons
    local ClassIcons = {}
    for index = 1, 5 do
      local Icon = self.Health:CreateTexture(nil, 'OVERLAY')

      Icon:SetSize(20, 20)
      Icon:SetPoint('LEFT', self.Health, 'CENTER', index * Icon:GetWidth(), 0)

      ClassIcons[index] = Icon
    end
    self.ClassIcons = ClassIcons

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
    -- Combopoints
    self.cPoints = SetFontString(self.Health, titleFont, 30, 'CENTER', self.Health, 'CENTER', 0, 0, 'THINOUTLINE')
    self:Tag(self.cPoints, '[yna:cp]')

    -----------------------------
    -- Resting
    local Resting = SetFontString(self.Health, titleFont, 15, 'CENTER', self.Health, 'CENTER', 0, 2)
    Resting:SetText('[R]')
    Resting:SetTextColor(1, .6, .13)
    self.Resting = Resting

    -----------------------------
    -- Auras
    self.Buffs.PostCreateIcon = PostCreateAura
    self.Buffs.CustomFilter = FilterPlayerBuffs

    self.Debuffs.PostCreateIcon = PostCreateAura
    self.Debuffs.PostUpdateIcon = PostUpdateDebuff
  end,

  target = function(self)
    self:SetSize(unpack(playerSize))
    -----------------------------
    -- Auras
    self.Debuffs.onlyShowPlayer = true
    self.Debuffs.PostCreateIcon = PostCreateAura
    self.Debuffs.PostUpdateIcon = PostUpdateDebuff

  end,

  targettarget = function(self)
    self:SetSize(unpack(totSize))
  end,

  party = function(self)
    self:SetSize(unpack(partySize))
  end,

  boss = function(self)
    self:SetSize(unpack(playerSize))
  end,

  pet = function(self)
    self:SetSize(unpack(partySize))
  end,
}
-- UnitSpecific.raid = UnitSpecific.party  -- raid is equal to party
UnitSpecific.focus = UnitSpecific.targettarget
UnitSpecific.focustarget = UnitSpecific.targettarget

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
  -- Info Strings
  -- Name
  if (unit ~= 'player') then -- I know my own name!
    local Name = SetFontString(Health, titleFont, 15, 'TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -2, 'THINOUTLINE')
    self:Tag(Name, '[yna:shortname]')
  end

  if( unit == 'target' ) then -- I also know my own class
    local Level = SetFontString(Health, titleFont, 15, 'TOPLEFT', Health, 'BOTTOMLEFT', 0, -2, 'THINOUTLINE')
    self:Tag(Level, '[difficulty<][L>smartlevel<|r] [smartclass]')
  end

  local PPPoints = SetFontString(Health, titleFont, 15, 'RIGHT', Health, 'RIGHT', 0, 0, 'THINOUTLINE')
  local HPPoints = SetFontString(Health, titleFont, 15, 'LEFT', Health, 'LEFT', 5, 0, 'THINOUTLINE')
  if unit == 'player' then
    self:Tag(HPPoints, '[yna:health] [(>perhp<%)]')
    self:Tag(PPPoints, '[yna:colorpp][perpp<%] [yna:druidpower]|r ')
  else
    self:Tag(HPPoints, '[|cffc41f3b>dead<|r][|cff999999>offline<|r][yna:colorhp][yna:health<|r] [(>perhp<%)]')
    self:Tag(PPPoints, '[yna:colorpp][perpp<%]|r')
  end
  self.Health.values = HPPoints
  self.Power.values = PPPoints

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
    Buffs.initialAnchor = 'TOPLEFT'
    Buffs['growth-y'] = 'UP'
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

  -- if(unit ~= 'party' and unit ~= 'raid' and unit ~= 'boss') then
  --   local Debuffs = CreateFrame('Frame', nil, self)
  --   Debuffs.spacing = 4
  --   Debuffs.initialAnchor = 'TOPLEFT'
  --   Debuffs.PostCreateIcon = PostCreateAura
  --   self.Debuffs = Debuffs

  --   if(unit == 'focus') then
  --     Debuffs:SetPoint('TOPLEFT', self, 'TOPRIGHT', 4, 0)
  --     Debuffs.onlyShowPlayer = true
  --   elseif(unit ~= 'target') then
  --     Debuffs:SetPoint('TOPRIGHT', self, 'TOPLEFT', -4, 0)
  --     Debuffs.initialAnchor = 'TOPRIGHT'
  --     Debuffs['growth-x'] = 'LEFT'
  --   end

  --   if(unit == 'focus' or unit == 'targettarget') then
  --     Debuffs.num = 3
  --     Debuffs.size = 19
  --     Debuffs:SetSize(230, 19)

  --     Health:SetAllPoints()
  --     self:SetSize(161, 19)
  --   end
  -- end

  ----------------------------------------
  -- Enable Plugins
  self.Range = {
    insideAlpha = 1,
    outsideAlpha = 0.8,
  }
  self.MoveableFrames = true

  -- leave this in!!
  if(UnitSpecific[unit]) then
    return UnitSpecific[unit](self)
  end
end

oUF:RegisterStyle('Ynarah', Shared)
oUF:Factory(function(self)
  self:SetActiveStyle('Ynarah')
  self:Spawn('player'):SetPoint('CENTER', -300, -75)
  self:Spawn('pet'):SetPoint('TOPRIGHT', oUF_YnarahPlayer, 'BOTTOMRIGHT', 0, -15)
  self:Spawn('target'):SetPoint('CENTER', 300, -75)
  self:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF_YnarahTarget, 'BOTTOMRIGHT', 0, -15)
  self:Spawn('focus'):SetPoint('CENTER', -300, -25)

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