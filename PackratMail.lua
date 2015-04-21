Packrat = Packrat or {}

function Packrat.MailDiscoveries()
	if #Packrat.savedVars.discoveries == 0 then
		d(GetString(SI_PACKRAT_MAIL_NO_DISCOVERIES))
	else
		local numDiscoveries = #Packrat.savedVars.discoveries
		local recipient = "@Randactyl"
		local subject = "Discovered data for Packrat v" .. Packrat.addonVersion
		local bodies = {}
		local tempBody = ""
		local delay = 200
		local i = 0

		RequestOpenMailbox()

		while numDiscoveries > 0 do
			i = i + 1
			numDiscoveries = #Packrat.savedVars.discoveries

			for j = zo_min(4, numDiscoveries), 1, -1 do
				if Packrat.savedVars.discoveries[j] then
					if Packrat.savedVars.discoveries[j].newSet == true then
						Packrat.savedVars.discoveries[j].newSet = "NEW SET\n"
					else Packrat.savedVars.discoveries[j].newSet = "" end

					tempBody = tempBody .. Packrat.savedVars.discoveries[j].newSet
				            .. "armorType: " .. Packrat.savedVars.discoveries[j].armorType .. "\n"
				            .. "setName: " .. Packrat.savedVars.discoveries[j].setName .. "\n"
				            .. "itemName: " .. Packrat.savedVars.discoveries[j].itemName .. "\n\n"
				   	table.remove(Packrat.savedVars.discoveries, j)
				end
			end

			bodies[i] = tempBody
			tempBody = ""
		end

		for j = 1, #bodies do
			zo_callLater(function()
					SendMail(recipient, subject .. "(" .. j .. " of " .. #bodies .. ")", bodies[j])
				end, delay)
			delay = delay + 200
		end

		CloseMailbox()
		d(GetString(SI_PACKRAT_MAIL_SENT_DISCOVERIES))
	end
end