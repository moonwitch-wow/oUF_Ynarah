local _, ns = ...
local cfg = ns.cfg
local oUF = ns.oUF or oUF

local referenceSpells = {
	45902,			-- Death Knight
	1978,			-- Hunter
	21562,			-- Priest
	35395,			-- Paladin
	686,			-- Warlock
	44614,			-- Mage
	7386,			-- Warrior
	403,			-- Shaman
	1752,			-- Rogue
	5176,			-- Druid
	100780,         -- Monk
}


local GetTime = GetTime
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local GetSpellCooldown = GetSpellCooldown


local spellid = nil


--
-- find a spell to use.
--
local Init = function()
	local FindInSpellbook = function(spell)
		for tab = 1, 4 do
			local _, _, offset, numSpells = GetSpellTabInfo(tab)
			for i = (1+offset), (offset + numSpells) do
				local bspell = GetSpellInfo(i, BOOKTYPE_SPELL)
				if (bspell == spell) then
					return i
				end
			end
		end
		return nil
	end

	for _, lspell in pairs(referenceSpells) do
		local na = GetSpellInfo (lspell)
		local x = FindInSpellbook(na)
		if x ~= nil then
			spellid = lspell
			break
		end
	end

	if spellid == nil then
		-- XXX: print some error ..
		print ("Foo!")
	end

	return spellid
end


local OnUpdateGCD = function(self)
	local perc = (GetTime() - self.starttime) / self.duration
	if perc > 1 then
		self:Hide()
	else
		self:SetValue(perc)
	end
end


local OnHideGCD = function(self)
 	self:SetScript('OnUpdate', nil)
end


local OnShowGCD = function(self)
	self:SetScript('OnUpdate', OnUpdateGCD)
end


local Update = function(self, event, unit)
	if self.GCD then
		if spellid == nil then
			if Init() == nil then
				return
			end
		end

		local start, dur = GetSpellCooldown(spellid)

		if (not start) then return end
		if (not dur) then dur = 0 end

		if (dur == 0) then
			self.GCD:Hide()
		else
			self.GCD.starttime = start
			self.GCD.duration = dur
			self.GCD:Show()
		end
	end
end


local Enable = function(self)
	if (self.GCD) then
		self.GCD:Hide()
		self.GCD.starttime = 0
		self.GCD.duration = 0
		self.GCD:SetMinMaxValues(0, 1)

		self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN', Update)
		self.GCD:SetScript('OnHide', OnHideGCD)
		self.GCD:SetScript('OnShow', OnShowGCD)
	end
end


local Disable = function(self)
	if (self.GCD) then
		self:UnregisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
		self.GCD:Hide()
	end
end


oUF:AddElement('GCD', Update, Enable, Disable)