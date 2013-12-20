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

-- Health Background Color Func
local function updateHealthBG(self, event, unit, bar, min, max)
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
    self:SetSize(unpack(playerSize))
  end,

  party = function(self)
    -- party frames
    self:SetSize(unpack(playerSize))
  end,

  boss = function(self)
    -- boss frames
    self:SetSize(unpack(playerSize))
  end,

  pet = function(self)
    -- pet frames
    self:SetSize(unpack(playerSize))
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

  -- shared setup
  -- self:SetBackdrop(backdrop)
  -- self:SetBackdropColor(unpack(backdropColor))
  -- self:SetBackdropBorderColor(unpack(backdropbordercolor))

  ----------------------------------------
  -- Powerbar
  ----------------------------------------
  local Power = CreateFrame("StatusBar", nil, self)
  Power:SetHeight(25)
  Power:SetStatusBarTexture(statusbarTexture)

  -- Add a background
  local powerBackground = Power:CreateTexture(nil, 'BACKGROUND')
  powerBackground:SetPoint('TOPLEFT', Power, -1, 1)
  powerBackground:SetPoint('BOTTOMRIGHT', Power, 1, -1)
  powerBackground:SetTexture(.1, .1, .1, .9)
  powerBackground.multiplier = .5

  Power.frequentUpdates = true
  Power.colorTapping = true
  Power.colorClass = true
  Power.colorReaction = true

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
  Health:SetStatusBarTexture(backdropTexture)
  Health:SetHeight(30)
  Health:SetStatusBarColor(.6, .6, .6)
  Health.frequentUpdates = true

  -- Add a background
  local healthBackground = Health:CreateTexture(nil, 'BACKGROUND')
  healthBackground:SetPoint('TOPLEFT', Health, -1, 1)
  healthBackground:SetPoint('BOTTOMRIGHT', Health, 1, -1)
  healthBackground:SetTexture(.1, .1, .1, .9)

  -- Make the background darker.
  healthBackground.multiplier = .5

  -- Register it with oUF
  self.Health = Health
  self.Health.bg = healthBackground
  self.PostUpdateHealth = updateHealthBG

  ----------------------------------------
  -- Info String
  ----------------------------------------
  -- Position and size
  -- local Info = Health:CreateTexture(nil, 'BACKGROUND')
  -- Info:SetHeight(30)
  -- Info:SetTexture(.1, .1, .1, .7)
  -- Info:SetPoint('TOP', Health, 'TOP', 8, 8)


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
  self:Spawn('target'):SetPoint('CENTER', 300, 0)
  self:Spawn('pet'):SetPoint('TOPRIGHT', oUF_YnarahPlayer, 'BOTTOMRIGHT', 0, -15)
  self:Spawn('focus'):SetPoint('TOPLEFT', oUF_YnarahPlayer, 0, 26)

  self:Spawn('targettarget'):SetPoint('TOPRIGHT', oUF_YnarahTarget, 0, 26)

  self:SpawnHeader(nil, nil, 'custom [group:party] show; [@raid3,exists] show; [@raid26,exists] hide; hide',
    'showParty', true, 'showRaid', true, 'showPlayer', true, 'yOffset', -6,
    'oUF-initialConfigFunction', [[
      self:SetHeight(16)
      self:SetWidth(126)
    ]]
  ):SetPoint('TOP', Minimap, 'BOTTOM', 0, -10)

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