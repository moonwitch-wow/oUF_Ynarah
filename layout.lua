------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF or oUF

------------------------------------------------------------------------
-- Config
------------------------------------------------------------------------
local titleFont = [=[Interface\AddOns\oUF_Ynarah\media\big_noodle_tilting.ttf]=]
local normalFont = STANDARD_TEXT_FONT

local backdropTexture = [=[Interface\ChatFrame\ChatFrameBackground]=]
local backdrop = {
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 1,
  insets = { left = -1, right = -1, top = -1, bottom = -1}
  }
local backdropColor = { r = .1, g = .1, b = .1, a = 1 }
local backdropbordercolor = { r = .6, g = .6, b = .6, a = 1 }

local statusbarTexture = [=[Interface\AddOns\oUF_Ynarah\media\statusbar]=]

local playerSize = {250, 50}
local totSize = {200, 15}
local partySize = {200, 10}

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
  self:SetBackdrop(backdrop)
  self:SetBackdropColor(unpack(backdropColor))
  self:SetBackdropBorderColor(unpack(backdropbordercolor))

  ----------------------------------------
  -- Healthbar
  ----------------------------------------
  -- Position and size
  local Health = CreateFrame("StatusBar", nil, self)
  Health:SetHeight(25)
  Health:SetPoint('TOP')
  Health:SetPoint('LEFT')
  Health:SetPoint('RIGHT')

  -- Add a background
  local Background = Health:CreateTexture(nil, 'BACKGROUND')
  Background:SetAllPoints(Health)
  Background:SetTexture(1, 1, 1, .5)

  -- Options
  Health.frequentUpdates = true
  Health.colorTapping = true
  Health.colorDisconnected = true
  Health.colorClass = true
  Health.colorReaction = true
  Health.colorHealth = true

  -- Make the background darker.
  Background.multiplier = .5

  -- Register it with oUF
  self.Health = Health
  self.Health.bg = Background

  ----------------------------------------
  -- Powerbar
  ----------------------------------------
  self.Power = CreateFrame("StatusBar", nil, self)
  self.Power:SetHeight(5)
  self.Power:SetStatusBarTexture(statusbarTexture)

  self.Power.frequentUpdates = true
  self.Power.colorTapping = true
  self.Power.colorClass = true
  self.Power.colorReaction = true

  self.Power:SetPoint"LEFT"
  self.Power:SetPoint"RIGHT"
  self.Power:SetPoint("TOP", self.Health, "BOTTOM")

  -- Register it with oUF
  self.Power = Power
  self.Power.bg = powerBackground
  self.Power.values = PPPoints

  ----------------------------------------
  -- Castbar
  ----------------------------------------

  ----------------------------------------
  -- Auras
  ----------------------------------------

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