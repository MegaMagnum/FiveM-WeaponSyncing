
local AllowedToOpen = true
local NearbyEntity = false

Citizen.CreateThread(function()
    while true do
        if AllowedToOpen and json.encode(ItemsInBuild) ~= '[]' then
            for _, v in pairs(Props) do
                if NearbyEntity then v = NearbyEntity end
                entity = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 1.0, GetHashKey(v), false, false, false)
                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) < 15 or NearbyEntity then
                    NearbyEntity = v
                    if entity == 0 then NearbyEntity = nil end
                    Citizen.Wait(0)
                    x,y,z = table.unpack(GetEntityCoords(entity))
                    if not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), "general-menu") then 
                        DrawText3D(x,y,z + 1.58, "Wapen werkbank")
                        DrawText3D(x,y,z + 1.5, "Druk op ~r~[E]~w~ om aan de slag te gaan")
                        if IsControlJustReleased(0, 38) then
                            TaskTurnPedToFaceEntity(PlayerPedId(), entity, 1000)
                            TaskGoToEntity(PlayerPedId(), entity, 1000, 0.1, 1, 1, 1)
                            Citizen.Wait(2000)
                            FreezeEntityPosition(PlayerPedId(), true)
                            InBench()
                        end
                    end
                else
                    NearbyEntity = nil
                    Citizen.Wait(350)
                end
            end
            if not entity then Citizen.Wait(1000) end
        else
            Citizen.Wait(0)
        end
    end
end)

function InBench()
    AllowedToOpen = false
    entity = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 1.0, 865942478, false, false, false)
    local weaponsininv = GetWeaponsInInv()
    if #weaponsininv ~= 0 then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), "general-menu", {
            title = "Wapen werkbank",
            align = 'top-left',
            elements = weaponsininv
        }, 
        function(data,menu)
           chosen = true
           menu.close()
           ComponentMenu(data)
        end,
    
        function()
            ESX.UI.Menu.CloseAll()
            AllowedToOpen = true
            FreezeEntityPosition(PlayerPedId(), false)
        end)
    else
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

function ComponentMenu(data)
    CompTable = GetPossibleComps(data.current.value)
    name = data.current.label
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'general_menu', {
		title 	 = data.current.label,
		align 	 = "top-right",
		elements = CompTable
		}, function(data, menu)
            inventory =  ESX.GetPlayerData().inventory
            for i=1, #inventory, 1 do
                if inventory[i].name == data.current.value then
                    if not data.current.bool then
                        if inventory[i].count > 0 then
                            AddAttach(name, inventory[i].name, inventory[i].label, data.current.comp, data.current.wpnname)
                        else
                            --TriggerEvent('gr_corefunctions:SendNotification', "bi bi-exclamation-triangle", "Je hebt het item hier niet voor!", true)
                            ESX.ShowNotification("Je hebt het item hier niet voor!")
                        end
                    else
                        RemoveAttach(name, inventory[i].name, inventory[i].label, data.current.comp, data.current.wpnname)
                    end
                end
             end
             menu.close()
		end, 
		function(data, menu)
			menu.close()
            InBench()
	end)
end

function AddAttach(wpnname, item, label, comp, wpnitem)
    AllowedToOpen = false
	TriggerEvent('mythic_progbar:client:progress', {
        name = 'add_comp',
        duration = 15000,
        label = 'Attachment toevoegen aan '..wpnname,
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        },
        animation = {
            animDict = 'mini@repair',
            anim = 'fixing_a_player',
            flags = 49,
            task = nil
        }
    }, function(status)

        TriggerServerEvent('WS:AddAttach', item, 1, wpnname, comp, wpnitem, wpntype)
        --TriggerEvent('gr_corefunctions:SendNotification', "bi bi-check-circle", "Je hebt een "..label.." op je wapen gezet", true)
        ESX.ShowNotification("Je hebt een "..label.." op je wapen gezet")
        AllowedToOpen = true
        TriggerEvent('WS:ReloadLoadout')
        Wait(150)
        InBench()
    end)
end

function RemoveAttach(wpnname, item, label, comp, wpnitem)
    AllowedToOpen = false
	TriggerEvent('mythic_progbar:client:progress', {
        name = 'add_comp',
        duration = 15000,
        label = 'Attachment verwijderen van '..wpnname,
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true
        },
        animation = {
            animDict = 'mini@repair',
            anim = 'fixing_a_player',
            flags = 49,
            task = nil
        }
    }, function(status)
        TriggerServerEvent('WS:RemoveAttach', item, 1, wpnname, comp, wpnitem)
        --TriggerEvent('gr_corefunctions:SendNotification', "bi bi-check-circle", "Je hebt een "..label.." van je wapen afgehaald", true)
        ESX.ShowNotification("Je hebt een "..label.." van je wapen afgehaald")
        AllowedToOpen = true
        TriggerEvent('WS:ReloadLoadout')
        Wait(150)
        InBench()
    end)
end

function GetPossibleComps(selected)
    PComponents = {}
    for k,v in pairs(Weapons) do
        for Type, Info in pairs(v) do
            if Type == selected then
                if Info.COMPONENTS then
                    for Compenent, bool in pairs(Info.COMPONENTS) do
                        for name, intel in pairs(ComponentsTable) do
                            if Compenent == name then
                                if bool then
                                    table.insert(PComponents, {label = "✔️>>  "..intel.type, value = intel.item, bool = bool, comp = name, wpnname = Type})
                                else
                                    table.insert(PComponents, {label = "❌>>  "..intel.type, value = intel.item, bool = bool, comp = name, wpnname = Type})
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return PComponents
end

function GetWeaponsInInv()
    local weapons = {}
    inventory =  ESX.GetPlayerData().inventory
    for k,v in pairs(Weapons) do
        for Type, Info in pairs(v) do
            for i=1, #inventory, 1 do
                if inventory[i].name == Type and inventory[i].count >= 1 then
                    table.insert(weapons, {label = inventory[i].label, value = Type})
                end
            end
        end
    end
    return weapons
end




function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 125)
    ClearDrawOrigin()
end

