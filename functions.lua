------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF or oUF

------------------------------------------------------------------------
-- Util Funcs
------------------------------------------------------------------------
function ns.SetFontString(parent, fontName, fontHeight, point, anchor, rPoint, xoffset, yoffset, outline)
  local fs = parent:CreateFontString(nil, 'OVERLAY')
  fs:SetFont(fontName, fontHeight, outline)
  fs:SetPoint(point, anchor, rPoint, xoffset, yoffset)
  fs:SetShadowColor(0, 0, 0, .5)
  fs:SetShadowOffset(1, -1)
  return fs
end

function ns.SI(value)
  if(value >= 1e6) then
    return ('%.2fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
  elseif(value >= 1e4) then
    return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
  else
    return value
  end
end