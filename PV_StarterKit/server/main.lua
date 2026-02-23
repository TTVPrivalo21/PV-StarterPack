local QBCore = exports['qb-core']:GetCoreObject()

local function GeneratePlate()
    local plate = Config.Vehicle.PlatePrefix .. tostring(math.random(1000, 9999))
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate
    end
end

RegisterNetEvent('pv_starterkit:server:checkStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.metadata['starterkit_claimed'] then
        lib.notify(src, {
            title = 'Atención',
            description = Config.Notify.AlreadyClaimed,
            type = 'error'
        })
    else
       
        Player.Functions.SetMetaData('starterkit_claimed', false) 
        TriggerClientEvent('pv_starterkit:client:openMenu', src)
    end
end)

RegisterNetEvent('pv_starterkit:server:claimKit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.metadata['starterkit_claimed'] then
        print(('[ALERTA] ID %s intentó reclamar el kit dos veces.'):format(src))
        return
    end

    if Config.Rewards.Money.Cash > 0 then
        Player.Functions.AddMoney('cash', Config.Rewards.Money.Cash, 'starter-kit')
    end
    if Config.Rewards.Money.Bank > 0 then
        Player.Functions.AddMoney('bank', Config.Rewards.Money.Bank, 'starter-kit')
    end

    for item, amount in pairs(Config.Rewards.Items) do
        exports.ox_inventory:AddItem(src, item, amount)
    end

    if Config.Vehicle.Enable then
        local plate = GeneratePlate()
        local coords = Config.Vehicle.SpawnPoint
        
        QBCore.Functions.SpawnVehicle(src, Config.Vehicle.Model, coords, true)
        
        SetTimeout(1000, function()
            local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
            if not veh or veh == 0 then
                local vehicles = GetAllVehicles()
                for i=1, #vehicles do
                    if #(GetEntityCoords(vehicles[i]) - vector3(coords.x, coords.y, coords.z)) < 3.0 then
                        veh = vehicles[i]
                        break
                    end
                end
            end

            if veh and veh ~= 0 then
                SetVehicleNumberPlateText(veh, plate)
                SetVehicleColours(veh, Config.Vehicle.Colors.Primary, Config.Vehicle.Colors.Secondary)
                
                -- Guardar en Base de Datos (Propiedad)
                MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
                    Player.PlayerData.license,
                    Player.PlayerData.citizenid,
                    Config.Vehicle.Model,
                    GetHashKey(Config.Vehicle.Model),
                    '{}',
                    plate,
                    'pillboxgarage', 
                    1
                })

                -- Meter llaves (Soporte qb-vehiclekeys)
                TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
            end
        end)
    end

    Player.Functions.SetMetaData('starterkit_claimed', true)
    Player.Functions.Save()
    

    Entity(GetPlayerPed(src)).state:set('hasStarterKit', true, true)

    lib.notify(src, {
        title = 'Éxito',
        description = Config.Notify.Success,
        type = 'success',
        duration = 5000
    })
end)

-- Comandos Admin y Exports
QBCore.Commands.Add('resetstarter', 'Resetear kit de inicio (Admin)', {{name='id', help='ID del jugador'}}, true, function(source, args)
    local targetId = tonumber(args[1])
    local Target = QBCore.Functions.GetPlayer(targetId)
    
    if Target then
        Target.Functions.SetMetaData('starterkit_claimed', false)
        Target.Functions.Save()
        Entity(GetPlayerPed(targetId)).state:set('hasStarterKit', false, true)
        TriggerClientEvent('ox_lib:notify', source, {type='success', description='Kit reseteado para ID: '..targetId})
    else
        TriggerClientEvent('ox_lib:notify', source, {type='error', description='Jugador no encontrado'})
    end
end, 'admin')

exports('HasClaimedKit', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    return Player and Player.PlayerData.metadata['starterkit_claimed'] or false

end)





local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
local resourceName = GetCurrentResourceName()

local versionUrl = "https://raw.githubusercontent.com/TTVPrivalo21/PV-StarterPack/main/PV_StarterKit/fxmanifest.lua?v=" .. os.time()

AddEventHandler('onResourceStart', function(resource)
    if resource == resourceName then
        PerformHttpRequest(versionUrl, function(errorCode, resultData, resultHeaders)
            if errorCode == 200 then
                local remoteVersion = resultData:match("[\n\r]%s*version%s*['\"]([^'\"]+)['\"]")
                
                if not remoteVersion then
                    remoteVersion = resultData:match("version%s*['\"]([^'\"]+)['\"]")
                end

                if remoteVersion then
                    remoteVersion = remoteVersion:gsub("%s+", "")
                    local localV = currentVersion:gsub("%s+", "")

                    if remoteVersion ~= localV then
                        print("^1---------------------------------------------------------------^7")
                        print("^3["..resourceName.."] Estatus: ^1ACTUALIZACIÓN DISPONIBLE^7")
                        print("^3Versión Local: ^7" .. localV)
                        print("^3Versión GitHub: ^2" .. remoteVersion)
                        print("^3Link: ^5https://github.com/TTVPrivalo21/PV-StarterPack^7")
                        print("^1---------------------------------------------------------------^7")
                    else
                        print("^2["..resourceName.."] El script está en la última versión (v"..localV..").^7")
                    end
                else
                    print("^3["..resourceName.."] Error: No se pudo encontrar el formato de versión en GitHub.^7")
                end
            else
                print("^3["..resourceName.."] Error de conexión: "..errorCode.."^7")
            end
        end, 'GET')
    end
end)


