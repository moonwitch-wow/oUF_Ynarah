---------------------------------------------------------------------
-- Namespacing teh shit out of this
---------------------------------------------------------------------
local ns, oUFYna = ...
local oUF = ns.oUF or oUF

---------------------------------------------------------------------
-- Converts 1000000 into 1M
---------------------------------------------------------------------
oUFYna.letter = function(value) -- to shorten HP/MP strings at full
	if value >= 1e6 then
		return ('%.1fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
	elseif value >= 1e3 or value <= -1e3 then
		return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
	else
		return value
	end
end

---------------------------------------------------------------------
-- Colorize NOW
---------------------------------------------------------------------
oUFYna.hex = function(r, g, b)
	if(type(r) == 'table') then
		if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
end

---------------------------------------------------------------------
-- Custom fontcreation
---------------------------------------------------------------------
oUFYna.SetFontString = function(parent, fontName, fontHeight, point, anchor, rPoint, xoffset, yoffset, outline)
	local fs = parent:CreateFontString(nil, 'OVERLAY')
	fs:SetFont(fontName, fontHeight, outline)
	fs:SetPoint(point, anchor, rPoint, xoffset, yoffset)
	fs:SetShadowColor(0, 0, 0, .7)
	fs:SetShadowOffset(1, -1)
	return fs
end

---------------------------------------------------------------------
-- Right click player menu -- taken from p3lim's excellently coded layout
---------------------------------------------------------------------
oUFYna.SpawnMenu = function(self)
	ToggleDropDownMenu(1, nil, _G[string.gsub(self.unit, '^.', string.upper)..'FrameDropDown'], 'cursor')
end
