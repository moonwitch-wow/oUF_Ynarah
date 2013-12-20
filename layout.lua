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
local totSize = {125, 25}
local partySize = {125, 25}

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
local function PostUpdateCast(element, unit)
end

local function UpdateAura(self, elapsed)
end

local function PostCreateAura(element, button)
end

local function PostUpdateBuff(element, unit, button, index)
end

local function PostUpdateDebuff(element, unit, button, index)
end

------------------------------------------------------------------------
-- UnitSpecific setups
------------------------------------------------------------------------
local UnitSpecific = {
  player = function(self)
    -- player unique
    self:SetSize(unpack(playerSize))

    local ClassIcons = {}
    for index = 1, 5 do
      local Icon = self:CreateTexture(nil, 'BACKGROUND')

      Icon:SetSize(20, 20)
      Icon:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', index * Icon:GetWidth(), 0)

      ClassIcons[index] = Icon
    end

    self.ClassIcons = ClassIcons


  end,

  target = function(self)
    -- target unique
    self:SetSize(unpack(playerSize))
  end,

  targettarget = function(self)
    -- tot
    self:SetSize(unpack(totSize))
  end,

  party = function(self)
    -- party frames
    self:SetSize(unpack(partySize))
  end,

  boss = function(self)
    -- boss frames
    self:SetSize(unpack(playerSize))
  end,

  pet = function(self)
    -- pet frames
    self:SetSize(unpack(partySize))
  end,
}
UnitSpecific.raid = UnitSpecific.party  -- raid is equal to party

------------------------------------------------------------------------
-- Shared Setup
------------------------------------------------------------------------
local function Shared(self, unit)
  unit = unit:match('(boss)%d?$') or unit

  self:SetScript("OnEnter", UnitFrame_OnEnter)
  self:SetScript("OnLeave", UnitFrame_OnLeave)

  self:RegisterForClicks"AnyUp"

  self.colors.power.MANA = {0, 144/255, 1} -- I still find mana too bright

  -- shared setup
  -- self:SetBackdrop(backdrop)
  -- self:SetBackdropColor(unpack(backdropColor))
  -- self:SetBackdropBorderColor(unpack(backdropbordercolor))

  ----------------------------------------
  -- Powerbar
  ----------------------------------------
  local Power = CreateFrame("StatusBar", nil, self)
  if( unit == 'player' or unit == 'target' ) then
    Power:SetHeight(25)
  else
    Power:SetHeight(12)
  end
  Power:SetStatusBarTexture(statusbarTexture)

  -- Add a background
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

  -- Register it with oUF
  self.Power = Power
  self.Power.bg = powerBackground
  -- self.Power.values = PPPoints

  ----------------------------------------
  -- Healthbar
  ----------------------------------------
  -- Position and size
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

  -- Add a background
  local healthBackground = Health:CreateTexture(nil, 'BACKGROUND')
  healthBackground:SetPoint('TOPLEFT', Health, -1, 1)
  healthBackground:SetPoint('BOTTOMRIGHT', Health, 1, -1)
  healthBackground:SetTexture(statusbarTexture)
  -- healthBackground:SetVertexColor(.1, .1, .1)

  -- Make the background darker.
  healthBackground.multiplier = .3

  -- Options
  -- healthBackground.colorHealth = true
  -- healthBackground.colorSmooth = true

  -- Register it with oUF
  self.Health = Health
  self.Health.bg = healthBackground

  ----------------------------------------
  -- Info Strings
  ----------------------------------------
  local Name = SetFontString(Health, titleFont, 15, 'TOPRIGHT', Health, 'BOTTOMRIGHT', 0, -2, 'THINOUTLINE')
  self:Tag(Name, '[name]')

  if( unit == 'player' or unit == 'target' ) then
    local Level = SetFontString(Health, titleFont, 15, 'TOPLEFT', Health, 'BOTTOMLEFT', 0, -2, 'THINOUTLINE')
    self:Tag(Level, '[difficulty<][L>smartlevel<|r] [smartclass]')
  else
    local Level = SetFontString(Health, titleFont, 15, 'TOPLEFT', Health, 'BOTTOMLEFT', 0, -2, 'THINOUTLINE')
    self:Tag(Level, '[difficulty<][L>smartlevel<|r]')
  end

  local PPPoints = Health:CreateFontString(nil, 'OVERLAY')
  PPPoints:SetFont(titleFont, 15, 'THINOUTLINE')
  PPPoints:SetPoint('RIGHT', Health, 0, 0)
  PPPoints:SetShadowColor(0, 0, 0, .7)
  PPPoints:SetShadowOffset(1, -1)
  PPPoints:SetTextColor(1, 1, 1)
  self:Tag(PPPoints, '[yna:colorpp][curpp< ] [yna:druidpower]|r ')
  self.Power.values = PPPoints


  ----------------------------------------
  -- Castbar
  ----------------------------------------

  ----------------------------------------
  -- Auras
  ----------------------------------------

  ------------------------------------------------------------------------
  -- Enable Plugins
  ------------------------------------------------------------------------
  self.SpellRange = true
  self.Range = {
    insideAlpha = 1,
    outsideAlpha = 0.8,
  }
  self.MoveableFrames = true
  -- self.FadeCasting = true  -- Fade if the unit is casting or not
  -- self.FadeCombat = true  -- Fade if the player is in combat or not
  -- self.FadeTarget = true  -- Fade if unit has a target or not
  -- self.FadeHover = true  -- Fade if the unit is hovered by the mouse or not (only applies to frames)
  -- self.FadeSmooth = 0.5
  -- self.FadeMinAlpha = 0.3
  -- self.FadeMaxAlpha = 1

  -- leave this in!!
  if(UnitSpecific[unit]) then
    return UnitSpecific[unit](self)
  end
end


oUF:RegisterStyle('Ynarah', Shared)
oUF:Factory(function(self)
  self:SetActiveStyle('Ynarah')
  self:Spawn('player'):SetPoint('CENTER', -300, 0)
  self:Spawn('pet'):SetPoint('TOPRIGHT', oUF_YnarahPlayer, 'BOTTOMRIGHT', 0, -15)
  self:Spawn('target'):SetPoint('CENTER', 300, 0)
  self:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF_YnarahTarget, 'BOTTOMRIGHT', 0, -15)
  self:Spawn('focus'):SetPoint('TOPLEFT', oUF_YnarahPlayer, 0, 26)

  self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; hide',
    'showParty', true, 'showRaid', true, 'showPlayer', true, 'yOffset', -15,
    'oUF-initialConfigFunction', [[
      self:SetHeight(25)
      self:SetWidth(125)
    ]]
  ):SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', -5, -50)

  for index = 1, 5 do
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