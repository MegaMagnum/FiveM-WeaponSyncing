ESX = exports["es_extended"]:getSharedObject()

ItemsInBuild = {}
Donator = false
WasDonator = false

RegisterNetEvent('WS:GotDonator', function(bool)
    Donator = bool
    WasDonator = bool
    BuildLoadout()
end)

Citizen.CreateThread(function()
    SetWeaponsNoAutoreload(false)
    TriggerServerEvent('WS:IsDonator')
    Wait(100)
    BuildLoadout()
end)

RegisterNetEvent('esx:playerLoaded',function()
    Citizen.Wait(100) 
    BuildLoadout()
end)

RegisterNetEvent('esx:addInventoryItem', function()
    Citizen.Wait(100) 
    if OnlyAmmoChange(item) then
        BuildLoadout(true)
    else
        BuildLoadout()
    end
end)

RegisterNetEvent('esx:removeInventoryItem', function(item, count)
    Citizen.Wait(100) 
    if OnlyAmmoChange(item) then
        BuildLoadout(true)
    else
        BuildLoadout()
    end
end)

RegisterNetEvent('WS:ReloadLoadout', function()
    BuildLoadout()
end)

RegisterCommand('WSReload', function()
    BuildLoadout()
end)

RegisterCommand('WSToggleSkins', function()
    if WasDonator then
        Donator = not Donator
    end
    BuildLoadout()
end)

function OnlyAmmoChange(item)
    for ammotype, table in pairs(Ammo) do
        if table.item == item then
            return true
        end
    end
    return false
end

function BuildLoadout(OnlyAmmo)
    inventory =  ESX.GetPlayerData().inventory
    ItemsInBuild = {}
    if not OnlyAmmo then
        for k,v in pairs(Weapons) do
            HasIt = false
            for Type, Info in pairs(v) do
                for i=1, #inventory, 1 do
                    if inventory[i].name == Type and inventory[i].count > 0 then
                        GiveWeaponToPed(PlayerPedId(), GetHashKey(k), 0, false, false)
                        table.insert(ItemsInBuild, Type)
                        HasIt = true
                        if Donator then
                            if GetWeaponTintCount(GetHashKey(k)) > 8 then
                                SetPedWeaponTintIndex(PlayerPedId(), GetHashKey(k), 23)
                            else
                                SetPedWeaponTintIndex(PlayerPedId(), GetHashKey(k), 2)
                            end
                        end
                        if Info.COMPONENTS then
                            for Compenent, bool in pairs(Info.COMPONENTS) do
                                if bool then
                                    GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(k), GetHashKey(Compenent))
                                else
                                    RemoveWeaponComponentFromPed(PlayerPedId(), GetHashKey(k), GetHashKey(Compenent))
                                end
                            end
                        end
                    elseif  inventory[i].name == Type and inventory[i].count <= 0 and not HasIt then    
                        RemoveWeaponFromPed(PlayerPedId(), GetHashKey(k))
                    end
                end
            end
        end
    end
    for ammotype, table in pairs(Ammo) do
        for i=1, #inventory, 1 do
            if inventory[i].name == table.item then
                SetPedAmmoByType(PlayerPedId(), GetHashKey(ammotype), inventory[i].count)
            end
        end
    end
end

local CurrentWeapon 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = GetPlayerPed(-1)
        if CurrentWeapon ~= GetSelectedPedWeapon(playerPed) then
            IsShooting = false
            RemoveUsedAmmo()
            CurrentWeapon = GetSelectedPedWeapon(playerPed)
            AmmoBefore = GetAmmoInPedWeapon(playerPed, CurrentWeapon)
        end
        if IsPedShooting(playerPed) and not IsShooting then
            IsShooting = true
        elseif IsShooting and IsControlJustReleased(0, 24) then
            IsShooting = false
            AmmoBefore = RemoveUsedAmmo()
        elseif not IsShooting and IsControlJustPressed(0, 45) then
            AmmoBefore = GetAmmoInPedWeapon(playerPed, CurrentWeapon)
        end
        
        if GetPedParachuteState(playerPed) == 1 then
            Wait(2000)
            TriggerServerEvent('WS:RemoveUsedAmmo', 'parachute', 1)
        end
    end
end)

function RemoveUsedAmmo()  
    local playerPed = GetPlayerPed(-1)
    local AmmoAfter = GetAmmoInPedWeapon(playerPed, CurrentWeapon)
    local ammoType = {item = nil}
    for ammotype, table in pairs(Ammo) do
        if GetHashKey(ammotype) == GetPedAmmoTypeFromWeapon(PlayerPedId(), CurrentWeapon) then
            ammoType = table
        end
    end
    if ammoType and ammoType.item then
        local ammoDiff = AmmoBefore - AmmoAfter
        if ammoDiff > 0 then
            TriggerServerEvent('WS:RemoveUsedAmmo', ammoType.item, ammoDiff)
        end
    end
    return AmmoAfter
end