Packrat = Packrat or {}
Packrat.addonName = "Packrat"
Packrat.addonVersion = "1.0.0.0"
Packrat.savedVarsVersion = 1

local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack

function Packrat.OnAddonLoaded(eventCode, addonName)
	if addonName ~= Packrat.addonName then return end
	EVENT_MANAGER:UnregisterForEvent("Packrat_OnAddonLoaded", EVENT_ADD_ON_LOADED)
	Packrat.Initialize()
end

function Packrat.Initialize()
	d("Initializing Packrat...")
	--set up saved vars
	Packrat.savedVars = ZO_SavedVars:NewAccountWide("Packrat_SavedVariables", Packrat.savedVarsVersion, nil, Packrat.defaults)
	Packrat.InitDebug()

	--Packrat.PackratUI.Initialize()

	EVENT_MANAGER:RegisterForEvent("Packrat_SingleSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Packrat.SingleSlotUpdate)

	d("Packrat initialized.")
end

function Packrat.InitDebug()
	SLASH_COMMANDS["/packratclear"] = function(arg)
		ZO_DeepTableCopy(Packrat.defaults, Packrat.savedVars)
	end

	SLASH_COMMANDS["/packratscan"] = function(arg)
		local inventory
		if BACKPACK:IsHidden() == false then
			inventory = BACKPACK.data
		elseif BANK:IsHidden() == false then
			inventory = BANK.data
		end

		for i = 1, #inventory do
			if inventory[i] then
				local itemLink = GetItemLink(inventory[i].data.bagId, inventory[i].data.slotIndex)
				local hasSet, setName, numberOfBonuses, numEquipped, maxWearable = GetItemLinkSetInfo(itemLink)

				if hasSet == true then
					local armorType = GetItemLinkArmorType(itemLink)
					local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
					local itemName = GetItemLinkName(itemLink)
					local location = GetUnitName("player")
					if inventory[i].data.bagId == BAG_BANK then location = "Bank" end

					--first encounter
					if Packrat.savedVars.sets[armorType] == nil then
						Packrat.savedVars.sets[armorType] = {}
					end
					if Packrat.savedVars.sets[armorType][setName] == nil then
						Packrat.savedVars.sets[armorType][setName] = {}
						d("Discovered new item set: " .. setName)
					end
					if Packrat.savedVars.sets[armorType][setName][itemName] == nil then
						Packrat.savedVars.sets[armorType][setName][itemName] = {
							instances = {},
						}
						d("Discovered new set item: " .. itemLink)
					end
					if Packrat.savedVars.sets[armorType][setName][itemName].instances[location] == nil then
						Packrat.savedVars.sets[armorType][setName][itemName].instances[location] = {}
					end
					if Packrat.savedVars.sets[armorType][setName][itemName].instances[location][itemId] == nil then
						Packrat.savedVars.sets[armorType][setName][itemName].instances[location][itemId] = {
							itemLink = itemLink,
							count = 0,
						}
					end

					--encountered before
					Packrat.savedVars.sets[armorType][setName][itemName].instances[location][itemId].count = Packrat.savedVars.sets[armorType][setName][itemName].instances[location][itemId].count + 1
				end
			end
		end
		d("Scan complete.")
	end
end

function Packrat.SingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason)
	d("bagId: " .. bagId)
	d("slotIndex: " .. slotIndex)
	if isNewItem then d("New item")
	else d("Old item") end
	d("itemSoundCategory: " .. itemSoundCategory)
	d("updateReason: " .. updateReason)
end

EVENT_MANAGER:RegisterForEvent("Packrat_OnAddonLoaded", EVENT_ADD_ON_LOADED, Packrat.OnAddonLoaded)