-- Function to add target for vehicle interaction
local function AddVehicleTarget(vehicle)
    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    exports.ox_target:addLocalEntity(vehicle, {
        {
            name = 'applyFakePlate',
            label = 'Apply Fake Plate',
            icon = 'fa-solid fa-screwdriver',
            onSelect = function()
                ESX.TriggerServerCallback('lofi:checkItems', function(hasItems)
                    if hasItems then
                        local playerPed = PlayerPedId()
                        TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
                        local countdown = 5
                        local coords = GetEntityCoords(playerPed)
                        
                        Citizen.CreateThread(function()
                            while countdown > 0 do
                                Citizen.Wait(1000)
                                countdown = countdown - 1
                            end
                            ClearPedTasks(playerPed)
                            TriggerServerEvent('lofi:attemptApply', vehicleNetId)
                        end)

                        Citizen.CreateThread(function()
                            while countdown > 0 do
                                DrawText3D(coords, "Applying Fake Plate... " .. countdown)
                                Citizen.Wait(0)
                            end
                        end)
                    else
                        exports.ox_lib:notify({
                            title = 'Error',
                            description = 'You do not have the required items.',
                            type = 'error'
                        })
                    end
                end, {'fakeplate', 'screwdriver'})
            end,
            distance = 2.5
        }
    })
end

-- Add target for vehicle interaction on player aiming at vehicle
CreateThread(function()
    local vehicles = {}
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 70)
        
        if vehicle ~= 0 and not vehicles[vehicle] then
            AddVehicleTarget(vehicle)
            vehicles[vehicle] = true
        end
        
        Wait(5000) -- Lower the frequency of checks to reduce resource usage
    end
end)

-- Draw text in 3D space
function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local p = GetGameplayCamCoords()
    local dist = #(p - coords)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Notifications
RegisterNetEvent('lofi:notify')
AddEventHandler('lofi:notify', function(type, message)
    exports.ox_lib:notify({
        title = type == 'success' and 'Success' or 'Error',
        description = message,
        type = type
    })
end)
