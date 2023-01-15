ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('WS:IsDonator', function()
	TriggerClientEvent('WS:GotDonator', source, IsSpelerDonateur(source))
end)

function IsSpelerDonateur(src)

	-- Your own Donator function 

end


RegisterServerEvent('WS:AddAttach')
AddEventHandler('WS:AddAttach', function(item, count, wpnname, comp, wpnitem, ConfigTable)
	local found = false
	local xPlayer  = ESX.GetPlayerFromId(source)
	local WeaponsTable = ConfigTable
	for k,v in pairs(WeaponsTable) do
		for Type, Info in pairs(v) do
			if wpnitem == Type then
				local NewInfo = Info
				NewInfo.COMPONENTS[comp] = true
				for k,v in pairs(WeaponsTable) do
					for Type, Info in pairs(v) do
						if json.encode(Info) == json.encode(NewInfo) and wpnitem ~= Type then
							if xPlayer.getInventoryItem(wpnitem).count > 0 and xPlayer.getInventoryItem(item).count > 0 then 
								found = true
								xPlayer.removeInventoryItem(wpnitem, 1)
								xPlayer.removeInventoryItem(item, count, true)
								xPlayer.addInventoryItem(Type, 1)
								break
							else
								xPlayer.removeInventoryItem(wpnitem, 1)
							end
						end
					end
				end
			end
		end
	end
end)

RegisterServerEvent('WS:RemoveAttach')
AddEventHandler('WS:RemoveAttach', function(item, count, wpnname, comp, wpnitem, ConfigTable)
	local found = false
	local xPlayer  = ESX.GetPlayerFromId(source)
	local WeaponsTable = ConfigTable
	for k,v in pairs(WeaponsTable) do
		for Type, Info in pairs(v) do
			if wpnitem == Type then
				local NewInfo = Info
				NewInfo.COMPONENTS[comp] = false
				for k,v in pairs(WeaponsTable) do
					for Type, Info in pairs(v) do
						if json.encode(Info) == json.encode(NewInfo) and wpnitem ~= Type then
							if xPlayer.getInventoryItem(wpnitem).count > 0 then 
								found = true
								xPlayer.removeInventoryItem(wpnitem, 1)
								xPlayer.addInventoryItem(item, count, true)
								xPlayer.addInventoryItem(Type, 1)
								break
							else
								xPlayer.removeInventoryItem(wpnitem, 1)
							end
						end
					end
				end
			end
		end
	end
end)

RegisterNetEvent('WS:RemoveUsedAmmo', function(Item, UsedAmmo)
	local xPlayer  = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(Item, UsedAmmo, true)
end)