------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local _, ns = ...
local tags = ns.oUF.Tags

------------------------------------------------------------------------
-- Util Funcs
------------------------------------------------------------------------
local function ShortValue(value)
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

tags.Methods['yna:status'] = Status

tags.Events['yna:leader'] = 'PARTY_LEADER_CHANGED'
tags.Methods['yna:leader'] = function(unit)
	if(UnitIsGroupLeader(unit)) then
		return '|cffffff00!|r'
	end
end

------------------------------------------------------------------------
-- Tags - Class specific
------------------------------------------------------------------------
