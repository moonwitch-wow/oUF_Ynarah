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

-- special powers
oUF.Tags['yna:sp'] = function(unit)
	local _, class = UnitClass(u)
	local SP, spcol = 0,{}
	if class == "PALADIN" then
		SP = UnitPower("player", SPELL_POWER_HOLY_POWER )
		spcol = {"8AFF30","FFF130","FF6161"}
	elseif class == "WARLOCK" then
		SP = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
		spcol = {"FF6161","FFF130","8AFF30"}
	end
	if SP == 1 then
		return "|cff"..spcol[1].."_|r"
	elseif SP == 2 then
		return "|cff"..spcol[2].."_ _|r"
	elseif SP == 3 then
		return "|cff"..spcol[3].."_ _ _|r"
	end
end
oUF.TagEvents['yna:sp'] = 'UNIT_POWER'

-- combo points
oUF.Tags['yna:cp'] = function(unit)
	local cp = UnitExists("vehicle") and GetComboPoints("vehicle", "target") or GetComboPoints("player", "target")
	cpcol = {"8AFF30","FFF130","FF6161"}
	if cp == 1 then		return "|cff"..cpcol[1].."_|r" 
	elseif cp == 2 then	return "|cff"..cpcol[1].."_ _|r"
	elseif cp == 3 then	return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_|r" 
	elseif cp == 4 then	return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_ _|r" 
	elseif cp == 5 then	return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_ _|r |cff"..cpcol[3].."_|r"
	end
end
oUF.TagEvents['yna:cp'] = 'UNIT_COMBO_POINTS'

-- shadow orbs
oUF.Tags['yna:orbs'] = function(unit)
	local name, _, _, count, _, duration = UnitBuff("player",GetSpellInfo(77487))
	if count == 1 then
		return "|cffFF6161_|r"
	elseif count == 2 then
		return "|cffFFF130_ _|r"
	elseif count == 3 then
		return "|cff8AFF30_ _ _|r"
	end
end
oUF.TagEvents['yna:orbs'] = 'UNIT_AURA'

-- water shield
oUF.Tags['yna:ws'] = function(unit)
	local name, _, _, count, _, duration = UnitBuff("player",GetSpellInfo(52127)) 
	if count == 1 then
		return "|cffFF6161_|r"
	elseif count == 2 then
		return "|cff8AFF30_ _|r"
	elseif count == 3 then
		return "|cff8AFF30_ _ _|r"
	end
end
oUF.TagEvents['mono:ws'] = 'UNIT_AURA'

-- lightning shield / maelstrom weapon
oUF.Tags['yna:ls'] = function(unit)
	local lsn, _, _, lsc = UnitBuff("player",GetSpellInfo(324))
	local mw, _, _, mwc = UnitBuff("player",GetSpellInfo(53817))
	if mw and not UnitBuff("player",GetSpellInfo(52127)) then
		if mwc == 1 then
			return "|cff8AFF30_|r"
		elseif mwc == 2 then
			return "|cff8AFF30_ _|r"
		elseif mwc == 3 then
			return "|cff8AFF30_ _|r |cffFFF130_ _|r"
		elseif mwc == 4 then
			return "|cff8AFF30_ _|r |cffFFF130_ _|r"
		elseif mwc == 5 then
			return "|cffFF6161_ _ _ _ _|r"
		end
	else
		if lsc == 1 then
			return "|cff434343_|r"
		elseif lsc == 2 then
			return "|cff434343_ _|r"
		elseif lsc == 7 then
			return "|cffFFF130_|r |cff434343_ _|r"
		elseif lsc == 8 then
			return "|cffFF6161_ _|r |cff434343_|r"
		elseif lsc == 9 then
			return "|cffFF6161_ _ _|r"
		elseif lsc then
			return "|cff434343_ _ _|r"
		end
	end
end
oUF.TagEvents['yna:ls'] = 'UNIT_AURA'

-- earth shield
oUF.earthCount = {1,2,3,4,5,6,7,8,9}
oUF.Tags['raid:earth'] = function(unit) 
	local c = select(4, UnitAura(u, GetSpellInfo(974))) 
	if c then return '|cffFFCF7F'..oUF.earthCount[c]..'|r' end end
oUF.TagEvents['raid:earth'] = 'UNIT_AURA'

-- Prayer of Mending
oUF.pomCount = {1,2,3,4,5,6}
oUF.Tags['raid:pom'] = function(unit) local c = select(4, UnitAura(u, GetSpellInfo(33076))) if c then return "|cffFFCF7F"..oUF.pomCount[c].."|r" end end
oUF.TagEvents['raid:pom'] = "UNIT_AURA"

-- Lifebloom
oUF.lbCount = { 1, 2, 3 }
oUF.Tags['raid:lb'] = function(unit) 
	local name, _,_, c,_,_, expirationTime, fromwho,_ = UnitAura(u, GetSpellInfo(33763))
	if not (fromwho == "player") then return end
	local spellTimer = GetTime()-expirationTime
	if spellTimer > -2 then
		return "|cffFF0000"..oUF.lbCount[c].."|r"
	elseif spellTimer > -4 then
		return "|cffFF9900"..oUF.lbCount[c].."|r"
	else
		return "|cffA7FD0A"..oUF.lbCount[c].."|r"
	end
end
oUF.TagEvents['raid:lb'] = "UNIT_AURA"

-- shrooooooooooooms (Wild Mushroom)
if select(2, UnitClass("player")) == "DRUID" then
	for i=1,3 do
		oUF.Tags['yna:wm'..i] = function(unit)
			_,_,_,dur = GetTotemInfo(i)
			if dur > 0 then
				return "|cffFF6161_ |r"
			end
		end
		oUF.TagEvents['yna:wm'..i] = 'PLAYER_TOTEM_UPDATE'
		oUF.UnitlessTagEvents.PLAYER_TOTEM_UPDATE = true
	end
end