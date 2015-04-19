Packrat = Packrat or {}

local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack

function Packrat.ScanInventory()
	local inventory = nil
	local location = ""
	if BACKPACK:IsHidden() == false then
		inventory = BACKPACK.data
		location = GetUnitName("player")
	elseif BANK:IsHidden() == false then
		inventory = BANK.data
		location = "bank"
	end

	if inventory ~= nil then
		--reset target location
		ZO_DeepTableCopy(Packrat.defaults.sets["bank"], Packrat.savedVars.sets[location])
		--clear discoveries buffer
		SLASH_COMMANDS["/packratcleardiscoveries"]()
		--fill target location
		for i = 1, #inventory do
			if inventory[i] then
				local itemLink = GetItemLink(inventory[i].data.bagId, inventory[i].data.slotIndex, LINK_STYLE_BRACKETS)
				local hasSet, setName, numberOfBonuses, numEquipped, maxWearable = GetItemLinkSetInfo(itemLink)
				local newSet = false

				if hasSet == true then
					local armorType = GetItemLinkArmorType(itemLink)
					local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
					local itemName = GetItemLinkName(itemLink)

					--first encounter
					if Packrat.savedVars.sets[location] == nil then
						Packrat.savedVars.sets[location] = {}
					end
					if Packrat.savedVars.sets[location][armorType] == nil then
						Packrat.savedVars.sets[location][armorType] = {}
					end
					if Packrat.savedVars.sets[location][armorType][setName] == nil then
						Packrat.savedVars.sets[location][armorType][setName] = {}
						d("Discovered new item set: " .. setName)
						newSet = true
					end
					if Packrat.savedVars.sets[location][armorType][setName][itemName] == nil then
						Packrat.savedVars.sets[location][armorType][setName][itemName] = {
							instances = {},
						}
						d("Discovered new set item: " .. itemLink)
						local temp = {
							armorType = armorType,
							setName = setName,
							itemName = itemName,
							newSet = newSet,
						}
						table.insert(Packrat.savedVars.discoveries, temp)
					end
					if Packrat.savedVars.sets[location][armorType][setName][itemName].instances[itemId] == nil then
						Packrat.savedVars.sets[location][armorType][setName][itemName].instances[itemId] = {
							itemLink = itemLink,
							count = 0,
						}
					end

					--encountered before
					Packrat.savedVars.sets[location][armorType][setName][itemName].instances[itemId].count = Packrat.savedVars.sets[location][armorType][setName][itemName].instances[itemId].count + 1
				end
			end
		end
		d("Scan complete.")
	end
end