local QBCore = exports['qb-core']:GetCoreObject()

-- Función auxiliar para generar placa única
local function GeneratePlate()
    local plate = Config.Vehicle.PlatePrefix .. tostring(math.random(1000, 9999))
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    if result then
        return GeneratePlate()
    else
        return plate
    end
end

-- 1. Verificar Estado (Seguridad ante todo)
RegisterNetEvent('pv_starterkit:server:checkStatus', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Usamos metadata para persistencia sin SQL extra
    if Player.PlayerData.metadata['starterkit_claimed'] then
        lib.notify(src, {
            title = 'Atención',
            description = Config.Notify.AlreadyClaimed,
            type = 'error'
        })
    else
        -- Sincronizar state bag para el cliente (ox_target check)
        Player.Functions.SetMetaData('starterkit_claimed', false) -- Asegurar que exista
        TriggerClientEvent('pv_starterkit:client:openMenu', src)
    end
end)

-- 2. Reclamar Kit
RegisterNetEvent('pv_starterkit:server:claimKit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Doble verificación (Server Authority)
    if Player.PlayerData.metadata['starterkit_claimed'] then
        -- Posible exploit detectado
        print(('[ALERTA] ID %s intentó reclamar el kit dos veces.'):format(src))
        return
    end

    -- A. Entregar Dinero
    if Config.Rewards.Money.Cash > 0 then
        Player.Functions.AddMoney('cash', Config.Rewards.Money.Cash, 'starter-kit')
    end
    if Config.Rewards.Money.Bank > 0 then
        Player.Functions.AddMoney('bank', Config.Rewards.Money.Bank, 'starter-kit')
    end

    -- B. Entregar Items (Usando export de ox_inventory para seguridad)
    for item, amount in pairs(Config.Rewards.Items) do
        exports.ox_inventory:AddItem(src, item, amount)
    end

    -- C. Entregar Vehículo (Si aplica)
    if Config.Vehicle.Enable then
        local plate = GeneratePlate()
        local coords = Config.Vehicle.SpawnPoint
        
        -- Spawnear vehículo server-side
        QBCore.Functions.SpawnVehicle(src, Config.Vehicle.Model, coords, true)
        
        -- Esperar un tick para obtener la entidad
        SetTimeout(1000, function()
            local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
            if not veh or veh == 0 then
                -- Si el jugador no fue tepeado o algo falló, buscamos en el radio
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
                    '{}', -- Mods vacíos por defecto
                    plate,
                    'pillboxgarage', -- Garage por defecto (ajustar según tu script de garage)
                    1 -- State 1 = Out
                })

                -- Meter llaves (Soporte qb-vehiclekeys)
                TriggerClientEvent('vehiclekeys:client:SetOwner', src, plate)
            end
        end)
    end

    -- D. Finalizar
    Player.Functions.SetMetaData('starterkit_claimed', true)
    Player.Functions.Save() -- Guardar jugador inmediatamente
    
    -- Actualizar statebag para que el target desaparezca instantáneamente
    Entity(GetPlayerPed(src)).state:set('hasStarterKit', true, true)

    lib.notify(src, {
        title = 'Éxito',
        description = Config.Notify.Success,
        type = 'success',
        duration = 5000
    })
end)

-- 3. Comandos Admin y Exports
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