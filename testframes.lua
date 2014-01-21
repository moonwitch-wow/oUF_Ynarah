local groups = { -- Change these to the global names your layout will make.
  party = {"oUF_YnarahParty1", "oUF_YnarahParty2", "oUF_YnarahParty3", "oUF_YnarahParty4"},
  -- arena = { "oUF_YnarahArena1", "oUF_YnarahArena2", "oUF_YnarahArena3", "oUF_YnarahArena4", "oUF_YnarahArena5",  "oUF_YnarahArenaPet1", "oUF_YnarahArena2", "oUF_YnarahArenaPet3", "oUF_YnarahArenaPet4", "oUF_YnarahArenaPet5" },
  boss = { "oUF_YnarahBoss1", "oUF_YnarahBoss2", "oUF_YnarahBoss3", "oUF_YnarahBoss4", "oUF_YnarahBoss5" },
  focus = { "oUF_YnarahFocus", "oUF_YnarahFocusTarget"},
}

local function toggle(f)
  if f.__realunit then
    f:SetAttribute("unit", f.__realunit)
    f.unit = f.__realunit
    f.__realunit = nil
    f:Hide()
  else
    f.__realunit = f:GetAttribute("unit") or f.unit
    f:SetAttribute("unit", "player")
    f.unit = "player"
    f:Show()
  end
end

SLASH_OUFTEST1 = "/otest"
SlashCmdList.OUFTEST = function(group)
  local frames = groups[strlower(strtrim(group))]
  if not frames then return end
  for i = 1, #frames do
    local frame = _G[frames[i]]
    if frame then
      toggle(frame)
      print('frame exists: '..group..i)
    end
  end
end