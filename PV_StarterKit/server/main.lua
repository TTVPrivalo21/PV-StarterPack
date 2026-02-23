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

