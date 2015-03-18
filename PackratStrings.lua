local strings = {
	["de"] = {

	},
	["en"] = {
		["SI_PACKRAT_TITLE"] = "Packrat",
		["SI_PACKRAT_HEADERNODE_LIGHT"] = "Light Armor",
		["SI_PACKRAT_HEADERNODE_MEDIUM"] = "Medium Armor",
		["SI_PACKRAT_HEADERNODE_HEAVY"] = "Heavy Armor",
		["SI_PACKRAT_HEADERNODE_OTHER"] = "Weapons & Jewelry",
	},
	["es"] = {

	},
	["fr"] = {

	},
	["ru"] = {

	},
}

--use metatables to set english as default language
setmetatable(strings["de"], {__index = strings["en"]})
setmetatable(strings["fr"], {__index = strings["en"]})
setmetatable(strings["ru"], {__index = strings["en"]})
setmetatable(strings["es"], {__index = strings["en"]})

local function AddStringsToGame()
	local lang = GetCVar("language.2")
	if strings[lang] == nil then lang = "en" end

	for i,v in pairs(strings[lang]) do
		ZO_CreateStringId(i, v)
	end
end

AddStringsToGame()