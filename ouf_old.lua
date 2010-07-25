local func_of_doom = function(self, unit, settings)
	if unit == "player" or unit == "target" then
		self:SetBackdrop{
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			insets = {left = -2, right = -2, top = -2, bottom = -5},
		}
		self:SetBackdropColor(0, 0, 0, .8)
	elseif unit == "focus" or unit == "focustarget" then
		self:SetBackdrop{
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			insets = {left = -2, right = -2, top = -2, bottom = -6},
		}
		self:SetBackdropColor(0, 0, 0, .8)
	else
		self:SetBackdrop{
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			insets = {left = -2, right = -2, top = -2, bottom = -2},
		}
		self:SetBackdropColor(0, 0, 0, .8)
	end

-----------------------------------------------------------------------
-- Naming conventions and ze buffage
-----------------------------------------------------------------------

	-- Rep on mouseover when the char is max level :)
	if(IsAddOnLoaded"oUF_Reputation" and unit == "player" and UnitLevel("player") == MAX_PLAYER_LEVEL) then
		self.Reputation = CreateFrame("StatusBar", nil, self)
		self.Reputation:SetHeight(5)
		self.Reputation:SetStatusBarTexture(statusbar)
		self.Reputation:SetStatusBarColor(unpack(colors.health))
		self.Reputation:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
		self.Reputation:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -1)
		self.Reputation:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -1, bottom = -1},
			}
		self.Reputation:SetBackdropColor(0, 0, 0, .3)
		self.Reputation.Tooltip = true

		self.Reputation.Text = self.Reputation:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		self.Reputation.Text:SetPoint("CENTER", self.Reputation, "CENTER")
	end

	-- Experience on mouseover
	if(IsAddOnLoaded("oUF_Experience") and (unit == "pet" or unit == "player") and UnitLevel("player") < MAX_PLAYER_LEVEL) then
		self.Experience = CreateFrame("StatusBar", nil, self)
		self.Experience:SetStatusBarTexture(statusbar)
		self.Experience:SetHeight(5)
		self.Experience:SetStatusBarColor(unpack(colors.health))
		self.Experience:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -1)
		self.Experience:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -1)
		self.Experience:SetAlpha(0)
		self.Experience:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -1, bottom = -1},
			}
		self.Experience:SetBackdropColor(0, 0, 0, .3)

		self.Experience.Rested = CreateFrame("StatusBar", nil, self.Experience)
		self.Experience.Rested:SetAllPoints(self.Experience)
		self.Experience.Rested:SetStatusBarTexture(statusbar)
		self.Experience.Rested:SetStatusBarColor(0, 0.4, 1, 0.6)
		self.Experience.Rested:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
			insets = {left = -2, right = -2, top = -1, bottom = -1},
			}
		self.Experience.Rested:SetBackdropColor(0, 0, 0, .3)
		self.Experience.Rested:SetAlpha(0)

		self.Experience.Text = self.Experience:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		self.Experience.Text:SetPoint("CENTER", self.Experience, "CENTER")
		self.Experience:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
		self.Experience:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
		self.Experience.Rested:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
		self.Experience.Rested:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
		
		self.Experience.Tooltip = true
	end



	
end