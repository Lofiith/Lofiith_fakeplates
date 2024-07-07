-- Server-side script

-- Config
local Config = {
    RequiredItems = {'fakeplate', 'screwdriver'}
}

-- Check if player has required items
ESX.RegisterServerCallback('lofi:checkItems', function(source, cb, items)
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasItems = true

    for _, item in ipairs(items) do
        local itemCount = exports.ox_inventory:Search(source, 'count', item)
        if itemCount == 0 then
            hasItems = false
            break
        end
    end

    cb(hasItems)
end)

-- Attempt to apply fake plate
RegisterNetEvent('lofi:attemptApply')
AddEventHandler('lofi:attemptApply', function(vehicleNetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        print("Debug: xPlayer is nil for source:", source)
        return
    end
    
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not DoesEntityExist(vehicle) then
        print("Debug: Vehicle does not exist for network ID:", vehicleNetId)
        TriggerClientEvent('lofi:notify', source, 'error', 'Vehicle does not exist.')
        return
    end

    local hasFakePlate = exports.ox_inventory:Search(source, 'count', 'fakeplate') > 0
    local hasScrewdriver = exports.ox_inventory:Search(source, 'count', 'screwdriver') > 0

    if hasFakePlate and hasScrewdriver then
        local fakePlate = GeneratePlate()
        SetVehicleNumberPlateText(vehicle, fakePlate)
        exports.ox_inventory:RemoveItem(source, 'fakeplate', 1)
        TriggerClientEvent('lofi:notify', source, 'success', 'Fake plate applied successfully.')
    else
        TriggerClientEvent('lofi:notify', source, 'error', 'You do not have the required items.')
    end
end)

-- Generate a random plate
function GeneratePlate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local nums = '0123456789'
    return string.sub(chars, math.random(#chars), math.random(#chars)) ..
           string.sub(nums, math.random(#nums), math.random(#nums), math.random(#nums), math.random(#nums))
end
