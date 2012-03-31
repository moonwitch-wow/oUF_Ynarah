---------------------------------------------------------------------
-- Custom tags
---------------------------------------------------------------------
oUF.TagEvents['yna:AFKDND'] = 'PLAYER_FLAGS_CHANGED'
oUF.Tags['yna:AFKDND'] = function(unit)
	return UnitIsAFK(unit) and '|cffff0000A|r' or UnitIsDND(unit) and '|cffff00ffD|r' or Unit
end

oUF.Tags['yna:colorpp'] = function(unit)
	local _, str = UnitPowerType(unit)
	local coloredmana = _COLORS.power[str]
	return coloredmana and string.format('|cff%02x%02x%02x', coloredmana[1] * 255, coloredmana[2] * 255, coloredmana[3] * 255)
end

oUF.TagEvents['yna:pp'] = 'UNIT_POWER'
oUF.Tags['yna:pp'] = function(unit)
	local power = UnitPower(unit)
	if UnitIsDeadOrGhost(unit) then
		return ''
	elseif UnitPower(unit) <= 0 then
		return ''
	else
		local _, type = UnitPowerType(unit)
		local colors = _COLORS.power
		return format('%s%s (%.1f%%)|r | ', Hex(colors[type] or colors['RUNES']), letter(UnitPower(unit)), UnitPower(unit)/UnitPowerMax(unit)*100)
	end
end

oUF.TagEvents['yna:shortname'] = 'UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION'
oUF.Tags['yna:shortname'] = function(unit)
	local name = UnitName(unit)
	return (string.len(name) > 10) and string.gsub(name, '%s?(.)%S+%s', '%1. ') or name
end

oUF.Tags['yna:smarthp'] = function(unit)
	return UnitIsDeadOrGhost(unit) and oUF.Tags['[dead]'](unit) or (UnitHealth(unit)~=UnitHealthMax(unit)) and format('%s (%.0f%%)', letter(UnitHealth(unit)), (UnitHealth(unit)/UnitHealthMax(unit)*100) or letter(UnitHealthMax(unit)))
end

oUF.Tags['yna:druidpower'] = function(unit)
	local min, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)
	if(UnitPowerType(unit) ~= 0 and min ~= max) then
		return ('|cff0090ff%d%%|r'):format(min / max * 100)
	end
end
oUF.TagEvents['yna:druidpower'] = 'UNIT_DISPLAYPOWER'

local Shadow_Orb = GetSpellInfo(77487)
oUF.Tags['yna:ShadowOrbs'] = function(unit)
    if(unit == 'player') then
      local name, _, icon, count = UnitBuff('player', Shadow_Orb)
	  return name and count
    end
end
oUF.TagEvents['yna:ShadowOrbs'] = 'UNIT_AURA'

local Evangelism = GetSpellInfo(81661) or GetSpellInfo(81660)
local Dark_Evangelism = GetSpellInfo(87118) or GetSpellInfo(87117)
oUF.Tags['yna:Evangelism'] = function(unit)
	if unit == 'player' then
      local name, _, icon, count = UnitBuff('player', Evangelism)
	  if name then return count end
	  name, _, icon, count = UnitBuff('player', Dark_Evangelism)
	  return name and count
	end
end
oUF.TagEvents['yna:Evangelism'] = 'UNIT_AURA'