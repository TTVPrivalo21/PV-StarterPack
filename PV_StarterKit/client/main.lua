local QBCore = exports['qb-core']:GetCoreObject()
local pedSpawned = nil

-- Función para spawnear el NPC
local function SpawnNPC()
    if pedSpawned then return end

    local model = type(Config.NPC.Model) == 'string' and joaat(Config.NPC.Model) or Config.NPC.Model
    lib.requestModel(model)

    pedSpawned = CreatePed(0, model, Config.NPC.Coords.x, Config.NPC.Coords.y, Config.NPC.Coords.z - 1.0, Config.NPC.Coords.w, false, false)
    
    SetEntityInvincible(pedSpawned, true)
    FreezeEntityPosition(pedSpawned, true)
    SetBlockingOfNonTemporaryEvents(pedSpawned, true)
    
    if Config.NPC.Scenario then
        TaskStartScenarioInPlace(pedSpawned, Config.NPC.Scenario, 0, true)
    end

    -- Integración con ox_target
    exports.ox_target:addLocalEntity(pedSpawned, {
        {
            name = 'starter_npc',
            icon = Config.NPC.Icon,
            label = Config.NPC.Label,
            distance = 2.5,
            onSelect = function()
                TriggerServerEvent('pv_starterkit:server:checkStatus')
            end,
            canInteract = function(entity, distance, coords, name)
                return not LocalPlayer.state.hasStarterKit 
            end
        }
    })
end

CreateThread(function()
    while true do
        local sleep = 1000
        local playerCoords = GetEntityCoords(cache.ped)
        local dist = #(playerCoords - vector3(Config.NPC.Coords.x, Config.NPC.Coords.y, Config.NPC.Coords.z))

        if dist < Config.NPC.RenderDistance then
            sleep = 0
            if not pedSpawned then SpawnNPC() end
        else
            if pedSpawned then
                if DoesEntityExist(pedSpawned) then DeleteEntity(pedSpawned) end
                pedSpawned = nil
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('pv_starterkit:client:openMenu', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        config = Config.UI,
        rewards = Config.Rewards,
        vehicle = Config.Vehicle.Model
    })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('claim', function(_, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('pv_starterkit:server:claimKit')
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and pedSpawned then
        DeleteEntity(pedSpawned)
    end

end)
