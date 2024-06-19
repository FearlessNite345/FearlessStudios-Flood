local flooding = false
local isFlooded = false

RegisterCommand('start-flood', function(source, args, rawCommand)
    if flooding or isFlooded then
        print('Error: A flood is already in progress or has been completed. Use reset or revert commands.')
    else
        local floodLevel = tonumber(args[1])
        if floodLevel == nil then
            print('Error: Invalid flood level provided')
        else
            flooding = true
            TriggerClientEvent('FearlessStudios-Flood:StartFlood', -1, floodLevel)
        end
    end
end, false)

RegisterCommand('reset-flood', function()
    TriggerClientEvent('FearlessStudios-Flood:ResetFlood', -1)
    flooding = false
    isFlooded = false
end, false)

RegisterCommand('revert-flood', function()
    TriggerClientEvent('FearlessStudios-Flood:RevertFlood', -1)
    flooding = false
    isFlooded = false
end, false)

RegisterNetEvent('FearlessStudios-Flood:UpdateFloodStatus', function(newFlooding, newIsFlooded)
    flooding = newFlooding
    isFlooded = newIsFlooded
end)
