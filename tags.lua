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

oUF.Tags.Events['yna:leader'] = 'PARTY_LEADER_CHANGED'
oUF.Tags.Methods['yna:leader'] = function(unit)
  if(UnitIsGroupLeader(unit)) then
    return '|cffffff00!|r'
  end
end

------------------------------------------------------------------------
-- Tags - Class specific
------------------------------------------------------------------------
