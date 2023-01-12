ESX = exports["es_extended"]:getSharedObject()

--[[Citizen.CreateThread(function()
	local count = 0
	for k,v in pairs(Weapons) do
		for Type, Info in pairs(v) do
			if true then
				print(Type)
				count = count + 1
				MySQL.Sync.execute('INSERT INTO `groningen`.`items` (name, label, weight) VALUES (@name, @label, @weight)', {
					['@name'] = Type,
					['@label'] = Info.name,
					['@weight'] = 1000
				})
			end
		end
	end
	print(count)
end)]]

RegisterNetEvent('WS:IsDonator', function()
	TriggerClientEvent('WS:GotDonator', source, IsSpelerDonateur(source))
end)

function IsSpelerDonateur(src)

    return false
	-- Your own Donator function
        
end


RegisterServerEvent('WS:AddAttach')
AddEventHandler('WS:AddAttach', function(item, count, wpnname, comp, wpnitem, wpntype)
	print(item, count, wpnname, comp, wpnitem, wpntype)
	local found = false
	local xPlayer  = ESX.GetPlayerFromId(source)
	for k,v in pairs(Weapons) do
		for Type, Info in pairs(v) do
			if wpnitem == Type then
				local NewInfo = Info
				NewInfo.COMPONENTS[comp] = true
				for k,v in pairs(Weapons) do
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
	if not found then
		print('Not found')
		print(json.encode(comp))
	end
end)

RegisterServerEvent('WS:RemoveAttach')
AddEventHandler('WS:RemoveAttach', function(item, count, wpnname, comp, wpnitem)
	local found = false
	local xPlayer  = ESX.GetPlayerFromId(source)
	for k,v in pairs(Weapons) do
		for Type, Info in pairs(v) do
			if wpnitem == Type then
				local NewInfo = Info
				NewInfo.COMPONENTS[comp] = false
				for k,v in pairs(Weapons) do
					for Type, Info in pairs(v) do
						if json.encode(Info) == json.encode(NewInfo) and wpnitem ~= Type then
							print(Type)
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
	if not found then
		print('Not found') 
		print(json.encode(comp))
	end
end)

RegisterNetEvent('WS:RemoveUsedAmmo', function(Item, UsedAmmo)
	local xPlayer  = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(Item, UsedAmmo, true)
end)