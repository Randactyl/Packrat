Packrat = Packrat or {}

local function mailSuccess(eventCode)
	if Packrat.clearDiscoveries == true then
		SLASH_COMMANDS["/packratcleardiscoveries"]()
		Packrat.clearDiscoveries = false
	end
	EVENT_MANAGER:UnregisterForEvent("Packrat_MailSuccess", EVENT_MAIL_SEND_SUCCESS)
end

function Packrat.MailDiscoveredSets()
	if #Packrat.savedVars.discoveries > 0 then
		local recipient = "@Randactyl1"
		local subject = "Discovered set info for Packrat v" .. Packrat.addonVersion
		local body = ""
		local clearDiscoveries = false

		for _,v in pairs(Packrat.savedVars.discoveries) do
			if v.newSet == true then v.newSet = "NEW SET" else v.newSet = "" end
			body = body .. " newSet: " .. v.newSet .. "\n" .. "armorType: " .. v.armorType .. "\n" .. " setName: " .. v.setName .. "\n" .. " itemName: " .. v.itemName .. "\n\n"
		end

		Packrat.clearDiscoveries = true
		SendMail(recipient, subject, body)

		EVENT_MANAGER:RegisterForEvent("Packrat_MailSuccess", EVENT_MAIL_SEND_SUCCESS, mailSuccess)
	end
end

function Packrat.InitializeMail()
	EVENT_MANAGER:RegisterForEvent("Packrat_MailDiscoveredSets", EVENT_MAIL_OPEN_MAILBOX, Packrat.MailDiscoveredSets)
end