local strings = {
	["de"] = {},
	["en"] = {
		["SI_PACKRAT_BANK_KEY"] = "Bank",
		["SI_PACKRAT_BANK_SCAN_ERROR"] = "Your bank wasn't scanned. Open it and scan again if you need to refresh those items.",
		["SI_PACKRAT_HEADERNODE_HEAVY"] = "Heavy Armor",
		["SI_PACKRAT_HEADERNODE_LIGHT"] = "Light Armor",
		["SI_PACKRAT_HEADERNODE_MEDIUM"] = "Medium Armor",
		["SI_PACKRAT_HEADERNODE_OTHER"] = "Weapons & Jewelry",
		["SI_PACKRAT_MAIL_BUTTON"] = "Mail Discoveries",
		["SI_PACKRAT_MAIL_NO_DISCOVERIES"] = "No discoveries to mail. Thanks anyway!",
		["SI_PACKRAT_MAIL_SENT_DISCOVERIES"] = "Mailed Packrat discoveries to @Randactyl. Thank you!",
		["SI_PACKRAT_NEW_ITEM_SET"] = "Discovered new item set: ",
		["SI_PACKRAT_NEW_SET_ITEM"] = "Discovered new set item: ",
		["SI_PACKRAT_SCAN_BUTTON"] = "Scan Items",
		["SI_PACKRAT_SCAN_COMPLETE"] = "Scan complete.",
		["SI_PACKRAT_TITLE"] = "Packrat",	
	},
	["es"] = {},
	["fr"] = {},
	["ru"] = {},
}

--use metatables to set english as default language
setmetatable(strings["de"], {__index = strings["en"]})
setmetatable(strings["es"], {__index = strings["en"]})
setmetatable(strings["fr"], {__index = strings["en"]})
setmetatable(strings["ru"], {__index = strings["en"]})

local function AddStringsToGame()
	local lang = GetCVar("language.2")
	if strings[lang] == nil then lang = "en" end

	for i,v in pairs(strings[lang]) do
		ZO_CreateStringId(i, v)
	end
end

AddStringsToGame()