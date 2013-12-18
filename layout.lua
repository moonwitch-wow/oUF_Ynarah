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
  bgFile = backdropTexture, insets = {top = -1, bottom = -1, left = -1, right = -1}
}
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
  self:SetScript("OnEnter", UnitFrame_OnEnter)
  self:SetScript("OnLeave", UnitFrame_OnLeave)

  self:RegisterForClicks"AnyUp"

  -- shared functions

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