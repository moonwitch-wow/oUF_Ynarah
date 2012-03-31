---------------------------------------------------------------------
-- Namespacing teh shit out of this
---------------------------------------------------------------------
local _, oUFYna = ...

---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------
local media = 'Interface\\AddOns\\oUF_Ynarah\\media\\'
local texture = 'Interface\\TargetingFrame\\UI-StatusBar'
--local texture = media..'dP.tga'
local font = STANDARD_TEXT_FONT
local numbers = 'Fonts\\skurri.TTF'
local fontSize = 12
--local border = media..'border.tga'
local border = media..'gloss.tga'

local hpHeight = 20 -- height of healthbar of player/target/tot/focus/pet and height of castbar
local ppHeight = 8 -- height of powerbar of player/target/pet
local plWidth = 325 -- width of player/target and width of castbar
local focWidth = 185 -- width of tot/focus

--I got tired of typing this all the damn time k?
local backdrop = {
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1}
		}
local backdropcolor = {.1,.1,.1,1}
local backdropbordercolor = {.6,.6,.6,1}