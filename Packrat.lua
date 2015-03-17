Packrat = Packrat or {}
Packrat.addonName = "Packrat"
Packrat.addonVersion = "1.0.0.0"
Packrat.savedVarsVersion = 1

local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack

function Packrat.OnAddonLoaded(eventCode, addonName)
	if addonName ~= Packrat.addonName then return end
	Packrat.Initialize()
end

function Packrat.Initialize()
	d("Initializing Packrat...")
	--set up saved vars
	local defaults = {
		sets = {},
	}
	Packrat.savedVars = ZO_SavedVars:NewAccountWide("Packrat_SavedVariables", Packrat.savedVarsVersion, nil, defaults)
	Packrat.InitDebug()
	Packrat.SetSlashCommand()

	Packrat.PackratUI.Initialize()

	d("Packrat initialized.")
end

function Packrat.InitDebug()
	SLASH_COMMANDS["/packratclear"] = function(arg)
		Packrat.savedVars.sets = {}
	end
end

function Packrat.SetSlashCommand()
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
					local equipType = GetItemLinkEquipType(itemLink)
					local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)

					--first encounter
					if Packrat.savedVars.sets[setName] == nil then
						Packrat.savedVars.sets[setName] = {}
					end
					if Packrat.savedVars.sets[setName][equipType] == nil then
						Packrat.savedVars.sets[setName][equipType] = {}
					end
					if Packrat.savedVars.sets[setName][equipType][itemId] == nil then
						Packrat.savedVars.sets[setName][equipType][itemId] = {
							link = itemLink,
							count = 0,
						}
					end

					--encountered before
					Packrat.savedVars.sets[setName][equipType][itemId].count = Packrat.savedVars.sets[setName][equipType][itemId].count + 1
				end
			end
		end
		d("Scan complete.")
	end
end

EVENT_MANAGER:RegisterForEvent("Packrat_OnAddonLoaded", EVENT_ADD_ON_LOADED, Packrat.OnAddonLoaded)