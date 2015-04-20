Packrat = Packrat or {}

local function mailSuccess(eventCode)
	if Packrat.clearDiscoveries == true then
		d("Mailed Packrat discoveries to @Randactyl. Thank you!")
		--SLASH_COMMANDS["/packratcleardiscoveries"]()
		Packrat.clearDiscoveries = false
	end
	EVENT_MANAGER:UnregisterForEvent("Packrat_MailSuccess", EVENT_MAIL_SEND_SUCCESS)
end

function Packrat.MailDiscoveredSets()
	if #Packrat.savedVars.discoveries > 0 then
		local recipient = "@Randactyl1"
		local subject = "Discovered set info for Packrat v" .. Packrat.addonVersion
		local body = ""
		local delay = 100
        local i = 1
		Packrat.clearDiscoveries = false

		for i = 1, #Packrat.savedVars.discoveries do
			--i = i - 1
			local limit = zo_min(4, #Packrat.savedVars.discoveries - i)
			for j = 1, limit do
				if Packrat.savedVars.discoveries[i] then
					if Packrat.savedVars.discoveries[i].newSet == true then
						Packrat.savedVars.discoveries[i].newSet = "NEW SET" 
					else Packrat.savedVars.discoveries[i].newSet = "" end

					body = body .. Packrat.savedVars.discoveries[i].newSet .. "\n"
				            .. "armorType: " .. Packrat.savedVars.discoveries[i].armorType .. "\n"
				            .. "setName: " .. Packrat.savedVars.discoveries[i].setName .. "\n"
				            .. "itemName: " .. Packrat.savedVars.discoveries[i].itemName .. "\n\n"
				end
				i = i + 1
			end
			zo_callLater(function()
					SendMail(recipient, subject, body)
					d("mail sent")
				end, delay)
			delay = delay + 100
			body = ""
		end

		--[[for _,v in pairs(Packrat.savedVars.discoveries) do
			
		end]]

		Packrat.clearDiscoveries = true
		zo_callLater(function()
				EVENT_MANAGER:RegisterForEvent("Packrat_MailSuccess", EVENT_MAIL_SEND_SUCCESS, mailSuccess)
			end, delay)
	end
end

function Packrat.InitializeMail()
	EVENT_MANAGER:RegisterForEvent("Packrat_MailDiscoveredSets", EVENT_MAIL_OPEN_MAILBOX, Packrat.MailDiscoveredSets)
end