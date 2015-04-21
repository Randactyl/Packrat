Packrat = Packrat or {}

local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack

local function Scan(bagId)
	local inventory = SHARED_INVENTORY.bagCache[bagId]
	local location = ""

	if bagId == BAG_BANK then
		location = "Bank"
	else
		location = GetUnitName("player")
	end
	
	if inventory ~= nil then
		for i = 1, #inventory do
			if inventory[i] then
				local itemLink = GetItemLink(inventory[i].bagId, inventory[i].slotIndex, LINK_STYLE_BRACKETS)
				local hasSet, setName, numberOfBonuses, numEquipped, maxWearable = GetItemLinkSetInfo(itemLink)
				local newSet = false

				if hasSet == true then
					local armorType = GetItemLinkArmorType(itemLink)
					local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
					local itemName = GetItemLinkName(itemLink)

					--first encounter
					if Packrat.savedVars.sets[armorType] == nil then
						Packrat.savedVars.sets[armorType] = {}
					end
					if Packrat.savedVars.sets[armorType][setName] == nil then
						Packrat.savedVars.sets[armorType][setName] = {}
						d("Discovered new item set: " .. setName)
						newSet = true
					end
					if Packrat.savedVars.sets[armorType][setName][itemName] == nil then
						Packrat.savedVars.sets[armorType][setName][itemName] = {}
						d("Discovered new set item: " .. itemLink)
						local temp = {
							armorType = armorType,
							setName = setName,
							itemName = itemName,
							newSet = newSet,
						}
						table.insert(Packrat.savedVars.discoveries, temp)
					end
					if Packrat.savedVars.sets[armorType][setName][itemName][location] == nil then
						Packrat.savedVars.sets[armorType][setName][itemName][location] = {}
					end
					if Packrat.savedVars.sets[armorType][setName][itemName][location][itemId] == nil then
						Packrat.savedVars.sets[armorType][setName][itemName][location][itemId] = {
							itemLink = itemLink,
							count = 0,
						}
					end

					--encountered before
					Packrat.savedVars.sets[armorType][setName][itemName][location][itemId].count = Packrat.savedVars.sets[armorType][setName][itemName][location][itemId].count + 1
				end
			end
		end
	end
end
function Packrat.ScanInventory()
	--reset target location
	for _, armorType in pairs(Packrat.savedVars.sets) do
		for _, setName in pairs(armorType) do
			for _, itemName in pairs(setName) do
				for _, loc in pairs(itemName) do
					if not (_ == "Bank" and SHARED_INVENTORY[BAG_BANK] == nil) then
						for _, itemId in pairs(loc) do
							itemId.count = 0
						end
					end
				end
			end
		end
	end
	--clear discoveries buffer
	SLASH_COMMANDS["/packratcleardiscoveries"]()
	--fill target location
	Scan(BAG_WORN)
	Scan(BAG_BACKPACK)
	Scan(BAG_BANK)

	d("Scan complete.")

	--reform the tree
	Packrat.PackratUI.PopulateTree()
end