---------------------------------------------------------------------
-- Namespacing teh shit out of this
---------------------------------------------------------------------
local _, oUFYna = ...
local oUF = ns.oUF or oUF

oUFYnaCfg = {}

---------------------------------------------------------------------
-- Configuration
---------------------------------------------------------------------
oUFYnaCfg = {
["media"] = 'Interface\\AddOns\\oUF_Ynarah\\media\\',
["texture"] = 'Interface\\TargetingFrame\\UI-StatusBar',
--["texture"] = media..'dP.tga',
["font"] = STANDARD_TEXT_FONT,
["numbers"] = 'Fonts\\skurri.TTF',
["fontSize"] = 12,
--["border"] = media..'border.tga',
["border"] = media..'gloss.tga',

["hpHeight"] = 20, -- height of healthbar of player/target/tot/focus/pet and height of castbar
["ppHeight"] = 8, -- height of powerbar of player/target/pet
["plWidth"] = 325, -- width of player/target and width of castbar
["focWidth"] = 185, -- width of tot/focus

--I got tired of typing this all the damn time k?
["backdrop"] = {
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1}
		},
["backdropcolor"] = {.1,.1,.1,1},
["backdropbordercolor"] = {.6,.6,.6,1},
}