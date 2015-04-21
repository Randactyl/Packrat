Packrat = Packrat or {}
Packrat.addonName = "Packrat"
Packrat.addonVersion = "1.0.0.0"
Packrat.savedVarsVersion = 1

function Packrat.OnAddonLoaded(eventCode, addonName)
	if addonName ~= Packrat.addonName then return end
	EVENT_MANAGER:UnregisterForEvent("Packrat_OnAddonLoaded", EVENT_ADD_ON_LOADED)
	Packrat.Initialize()
end

function Packrat.Initialize()
	d("Initializing Packrat...")
	
	Packrat.savedVars = ZO_SavedVars:NewAccountWide("Packrat_SavedVariables", Packrat.savedVarsVersion, nil, Packrat.defaults)

	Packrat.InitializeDebug()
	Packrat.InitializeSlashCommands()
	--Packrat.InitializeMail()
	Packrat.PackratUI.Initialize()

	--EVENT_MANAGER:RegisterForEvent("Packrat_SingleSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Packrat.SingleSlotUpdate)

	d("Packrat initialized.")
end

function Packrat.InitializeDebug()
	SLASH_COMMANDS["/packratclear"] = function(arg)
		Packrat_SavedVariables["Default"]["@Randactyl"]["$AccountWide"] = {}
		ZO_DeepTableCopy(Packrat.defaults, Packrat.savedVars)
		ReloadUI()
		d("Packrat saved variables reset.")
	end

	SLASH_COMMANDS["/packratcleardiscoveries"] = function(arg)
		Packrat_SavedVariables["Default"]["@Randactyl"]["$AccountWide"]["discoveries"] = {}
		d("Packrat discoveries cleared.")
	end

	SLASH_COMMANDS["/packratfakediscoveries"] = function(arg)
		local temp = {
			armorType = 0,
			setName = "TEST_SET",
			itemName = "TEST_ITEM",
		}
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
		table.insert(Packrat.savedVars.discoveries, temp)
	end
end

function Packrat.InitializeSlashCommands()
	SLASH_COMMANDS["/packrat"] = function(arg)
		Packrat.PackratUI.ToggleWindow()
	end

	SLASH_COMMANDS["/packratscan"] = function(arg)
		Packrat.ScanInventory()
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