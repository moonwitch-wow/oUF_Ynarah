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

-----------------------------
-- Leader func
oUF.Tags.Methods['yna:leader'] = function(unit)
  if(UnitIsGroupLeader(unit)) then
    return '|cffffff00L|r'
  end
end
oUF.Tags.Events['yna:leader'] = 'PARTY_LEADER_CHANGED'

-----------------------------
-- colorize power
oUF.Tags.Methods['yna:colorpp'] = function(unit)
  local _, str = UnitPowerType(unit)
  local coloredmana = _COLORS.power[str]
  return coloredmana and string.format('|cff%02x%02x%02x', coloredmana[1] * 255, coloredmana[2] * 255, coloredmana[3] * 255)
end

-----------------------------
-- colorize HP
oUF.Tags.Methods['yna:colorhp'] = function(unit)
  local colored = oUF.colors.health
  return colored and string.format('|cff%02x%02x%02x', colored[1] * 255, colored[2] * 255, colored[3] * 255)
end

-----------------------------
-- health func
oUF.Tags.Methods['yna:health'] = function(unit)
  if(not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then return end

  local min, max = UnitHealth(unit), UnitHealthMax(unit)
  if(min ~= 0 and min ~= max) then
    return '-' .. SI(max - min)
  else
    return SI(max)
  end
end
oUF.Tags.Events['yna:health'] = oUF.Tags.Events.missinghp
-- oUF.ColorGradient
-----------------------------
-- Shortname
oUF.Tags.Methods['yna:shortname'] = function(unit)
  local name = UnitName(unit)
  return (string.len(name) > 10) and string.gsub(name, '%s?(.)%S+%s', '%1. ') or name
end
oUF.Tags.Events['yna:shortname'] = 'UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION'

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
-----------------------------
-- ComboPoints
oUF.Tags.Methods['yna:cp'] = function(unit)
  local cp = UnitExists("vehicle") and GetComboPoints("vehicle", "target") or GetComboPoints("player", "target")
  cpcol = {"8AFF30","FFF130","FF6161"}
  if cp == 1 then            return "|cff"..cpcol[1].."_|r"
  elseif cp == 2 then        return "|cff"..cpcol[1].."_ _|r"
  elseif cp == 3 then        return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_|r"
  elseif cp == 4 then        return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_ _|r"
  elseif cp == 5 then        return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_ _|r |cff"..cpcol[3].."_|r"
  end
end
oUF.Tags.Events['yna:cp'] = 'UNIT_COMBO_POINTS'
