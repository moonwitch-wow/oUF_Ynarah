------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local tags = oUF.Tags.Methods or oUF.Tags
local tagevents = oUF.TagEvents or oUF.Tags.Events

------------------------------------------------------------------------
-- Util Funcs
------------------------------------------------------------------------
local function SI(value)
  if(value >= 1e6) then
    return ('%.2fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
  elseif(value >= 1e4) then
    return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
  else
    return value
  end
end

------------------------------------------------------------------------
-- Tags - Generic
------------------------------------------------------------------------
local function Status(unit)
  if(not UnitIsConnected(unit)) then
    return 'O'
  elseif(UnitIsGhost(unit)) then
    return 'G'
  elseif(UnitIsDead(unit)) then
    return 'D'
  end
end
oUF.Tags.Methods['yna:status'] = Status

oUF.Tags.Methods['yna:leader'] = function(unit)
  if(UnitIsGroupLeader(unit)) then
    return '|cffffff00L|r'
  end
end
oUF.Tags.Events['yna:leader'] = 'PARTY_LEADER_CHANGED'

oUF.Tags.Methods['yna:colorpp'] = function(unit)
  local _, str = UnitPowerType(unit)
  local coloredmana = _COLORS.power[str]
  return coloredmana and string.format('|cff%02x%02x%02x', coloredmana[1] * 255, coloredmana[2] * 255, coloredmana[3] * 255)
end

------------------------------------------------------------------------
-- Tags - Class specific
------------------------------------------------------------------------
oUF.Tags.Methods['yna:druidpower'] = function(unit)
  local min, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)
  if(UnitPowerType(unit) ~= 0 and min ~= max) then
    return ('|cff0090ff%d%%|r'):format(min / max * 100)
  end
end
oUF.Tags.Events['yna:druidpower'] = oUF.Tags.Events.missingpp
