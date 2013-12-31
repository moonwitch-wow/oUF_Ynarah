------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local _, ns = ...
local tags = oUF.Tags.Methods or oUF.Tags
local tagevents = oUF.TagEvents or oUF.Tags.Events

------------------------------------------------------------------------
-- Tags - Generic
------------------------------------------------------------------------
-----------------------------
-- Leader func
oUF.Tags.Methods['leader'] = function(unit)
  if(UnitIsGroupLeader(unit)) then
    return '|cffffff00L|r'
  end
end
oUF.Tags.Events['leader'] = 'PARTY_LEADER_CHANGED'

-----------------------------
-- colorize power
oUF.Tags.Events['powercolor'] = 'UNIT_DISPLAYPOWER'
oUF.Tags.Methods['powercolor'] = function(unit)
  local _, type = UnitPowerType(unit)
  local color = oUF.colors.power[type] or oUF.colors.power.FUEL
  return format('|cff%02x%02x%02x', color[1] * 255, color[2] * 255, color[3] * 255)
end

-----------------------------
-- colorize HP
oUF.Tags.Events['unitcolor'] = 'UNIT_HEALTH UNIT_CLASSIFICATION UNIT_REACTION'
oUF.Tags.Methods['unitcolor'] = function(unit)
  local color
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
    color = oUF.colors.disconnected
  elseif UnitIsPlayer(unit) then
    local _, class = UnitClass(unit)
    color = oUF.colors.class[class]
  elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
    color = oUF.colors.tapped
  elseif UnitIsEnemy(unit, 'player') then
    color = oUF.colors.reaction[1]
  else
    color = oUF.colors.reaction[UnitReaction(unit, 'player') or 5]
  end
  return color and ('|cff%02x%02x%02x'):format(color[1] * 255, color[2] * 255, color[3] * 255) or '|cffffffff'
end

-----------------------------
-- health func
oUF.Tags.Methods['yna:health'] = function(unit)
  if(not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then return end

  local min, max = UnitHealth(unit), UnitHealthMax(unit)
  if(min ~= 0 and min ~= max) then
    return '-' .. ns.SI(max - min)
  else
    return ns.SI(max)
  end
end
oUF.Tags.Events['yna:health'] = oUF.Tags.Events.missinghp

-----------------------------
-- Shortname
oUF.Tags.Methods['yna:shortname'] = function(unit)
  local name = UnitName(unit)
  return (string.len(name) > 10) and string.gsub(name, '%s?(.)%S+%s', '%1. ') or name
end
oUF.Tags.Events['yna:shortname'] = 'UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION'

-----------------------------
-- Debuff tags - thanks to Tekkub
local function HasDebuffType(unit, t)
  for i=1,40 do
    local name, _, _, _, debuffType = UnitDebuff(unit, i)
    if not name then return
    elseif debuffType == t then return true end
  end
end

oUF.Tags.Methods["disease"] = function(u) return HasDebuffType(u, "Disease") and "|cff996600Di|r" end
oUF.Tags.Methods["magic"]   = function(u) return HasDebuffType(u, "Magic")   and "|cff3399FFMa|r" end
oUF.Tags.Methods["curse"]   = function(u) return HasDebuffType(u, "Curse")   and "|cff9900FFCu|r" end
oUF.Tags.Methods["poison"]  = function(u) return HasDebuffType(u, "Poison")  and "|cff009900Po|r" end
oUF.Tags.Events["disease"] = "UNIT_AURA"
oUF.Tags.Events["magic"]   = "UNIT_AURA"
oUF.Tags.Events["curse"]   = "UNIT_AURA"
oUF.Tags.Events["poison"]  = "UNIT_AURA"

------------------------------------------------------------------------
-- Tags - Class specific
------------------------------------------------------------------------
-----------------------------
-- Druid Power - show mana when not full

oUF.Tags.Methods['yna:druidpower'] = function(unit)
  local min, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)
  if(UnitPowerType(unit) ~= 0 and min ~= max) then
    return ('|cff0090ff%d%%|r'):format(min / max * 100)
  end
end
oUF.Tags.Events['yna:druidpower'] = oUF.Tags.Events.missingpp

