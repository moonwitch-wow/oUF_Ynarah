------------------------------------------------------------------------
-- Namespace
------------------------------------------------------------------------
local _, ns = ...
local _, playerClass = UnitClass("player")
local _, playerRace = UnitRace("player")

------------------------------------------------------------------------
-- Buff Filters and Debuff filters
------------------------------------------------------------------------
local FilterPlayerBuffs
do
  local spells = {

    -- Priest
    [60062] = true, -- Essence of Life
    [77487] = true, -- Shadow Bollocks
    [124430] = true, -- Divine Insight
    [95740] = true, -- Shadow Orbs
    [104510] = true, -- Windsong Mastery
    [104509] = true, -- Windsong Crit
    [104423] = true, -- Windsong Haste
    [122309] = true, -- Mark of the catacombs
    -- Druid
    [5217] = true, -- Tiger's Fury
    [52610] = true, -- Savage Roar
    [106951] = true, -- Berserk
    [127538] = true, -- Savage Roar (glyphed)
    [124974] = true, -- Nature's Vigil
    [132158] = true, -- Nature's Swiftness
    [132402] = true, -- Savage Defense

    -- Shared
    [32182] = true, -- Heroism
    [57933] = true, -- Tricks of the Trade
    [80353] = true, -- Time Warp
  }

  function ns.FilterPlayerBuffs(...)
    local _, _, _, _, _, _, _, _, _, _, _, _, _, id = ...
      return spells[id]
    end
end

local FilterTargetDebuffs
do
  local show = {
    [1490] = true, -- Curse of Elements (Magic Vulnerability)
    [58410] = true, -- Master Poisoner (Magic Vulnerability)
    [81326] = true, -- Physical Vulnerability (Shared)
    [113746] = true, -- Weakened Armor (Shared)
    [770] = true, -- Faerie Fire
    [58180] = true, -- Infected Wounds
    [115798] = true, -- Weakened Blows
  }

  function ns.FilterTargetDebuffs(...)
    local _, unit, _, _, _, _, _, _, _, _, owner, _, _, id = ...

    if(owner == 'player' and hide[id]) then
      return false
    elseif(owner == 'player' or owner == 'vehicle' or UnitIsFriend('player', unit) or show[id] or not owner) then
      return true
    end
  end
end

