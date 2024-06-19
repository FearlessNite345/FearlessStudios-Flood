local increment = 0.1
local flooding = false
local isFlooded = false
local maxFlood
local floodThresholds = { 25, 50, 75, 100, 125, 150 }
local intervalBetweenIncrement

RegisterNetEvent('FearlessStudios-Flood:StartFlood', function(floodLevel)
    floodLevel = tonumber(floodLevel)

    if floodLevel == nil then
        print('Error: you did not provide a flood level')
    else
        if IsValidFloodLevel(floodLevel) then
            maxFlood = floodLevel
            
            intervalBetweenIncrement = CalculateIncrementInterval(maxFlood, increment, Config.floodTime)

            if not isFlooded then
                flooding = true
                TriggerServerEvent('FearlessStudios-Flood:UpdateFloodStatus', flooding, isFlooded)
                print('Flooding started')
                Citizen.Wait(2500)
                ResetLevels()
                LoadWaterFromPath(GetCurrentResourceName(), 'waterLevels/base.xml')
                Citizen.CreateThread(function()
                    while flooding do
                        local waterQuadCount = GetWaterQuadCount()
                        local allQuadsAtMax = true
                        local newLevel

                        for i = 1, waterQuadCount do
                            local success, waterQuadLevel = GetWaterQuadLevel(i)
                            if success then
                                newLevel = waterQuadLevel + increment
                                if newLevel <= maxFlood then
                                    SetWaterQuadLevel(i, newLevel)
                                    allQuadsAtMax = false
                                else
                                    SetWaterQuadLevel(i, maxFlood)
                                end
                            end
                        end

                        HandleLevelUpdate(newLevel)

                        if allQuadsAtMax then
                            flooding = false
                        end

                        Citizen.Wait(intervalBetweenIncrement) -- Adjust the interval as needed
                    end

                    print('Flooding ended')
                    isFlooded = true
                    TriggerServerEvent('FearlessStudios-Flood:UpdateFloodStatus', flooding, isFlooded)
                end)
            end
        end
    end
end)

RegisterNetEvent('FearlessStudios-Flood:ResetFlood', function()
    ResetWater()
    flooding = false
    isFlooded = false
    TriggerServerEvent('FearlessStudios-Flood:UpdateFloodStatus', flooding, isFlooded)
    print("Water level reset")
end)

RegisterNetEvent('FearlessStudios-Flood:RevertFlood', function()
    if flooding or isFlooded then
        flooding = false -- Stop any ongoing flooding
        TriggerServerEvent('FearlessStudios-Flood:UpdateFloodStatus', flooding, isFlooded)

        Citizen.CreateThread(function()
            print('Reverting flood started')
            local waterQuadCount = GetWaterQuadCount()
            local allQuadsAtMin = false

            while not allQuadsAtMin do
                allQuadsAtMin = true
                local newLevel

                for i = 1, waterQuadCount do
                    local success, waterQuadLevel = GetWaterQuadLevel(i)
                    if success then
                        newLevel = waterQuadLevel - increment
                        if newLevel >= 0 then
                            SetWaterQuadLevel(i, newLevel)
                            allQuadsAtMin = false
                        else
                            SetWaterQuadLevel(i, 0.0)
                        end
                    end
                end

                HandleLevelRevert(newLevel)

                Citizen.Wait(intervalBetweenIncrement) -- Adjust the interval as needed
            end

            print('Flooding fully reverted')
            ResetWater()
            isFlooded = false
            TriggerServerEvent('FearlessStudios-Flood:UpdateFloodStatus', flooding, isFlooded)
        end)
    else
        print('No flood to revert')
    end
end)

-- Table to keep track of levels that have already been hit
local levelsReached = {}

-- Function to handle level updates
function HandleLevelUpdate(newLevel)
    for _, threshold in ipairs(floodThresholds) do
        if newLevel >= threshold and not levelsReached[threshold] then
            print('Reached ' .. threshold)
            levelsReached[threshold] = true
            LoadWaterFromPath(GetCurrentResourceName(), 'waterLevels/base-' .. threshold .. '.xml')
        end
    end
end

function HandleLevelRevert(newLevel)
    for i = #floodThresholds, 1, -1 do
        local threshold = floodThresholds[i]
        if newLevel < threshold and levelsReached[threshold] then
            print('Reverted from ' .. threshold)
            levelsReached[threshold] = false
            LoadWaterFromPath(GetCurrentResourceName(), 'waterLevels/base-' .. threshold .. '.xml')
        end
    end
end

function IsValidFloodLevel(level)
    level = tonumber(level)
    for _, threshold in ipairs(floodThresholds) do
        if level == threshold then
            return true
        end
    end

    return false
end

-- Function to reset the levels
function ResetLevels()
    levelsReached = {}
end

function CalculateIncrementInterval(targetValue, increment, totalTimeSeconds)
    -- Calculate the total number of increments needed to reach the target value
    local totalIncrements = targetValue / increment

    -- Convert the total time duration from seconds to milliseconds
    local totalTimeMilliseconds = totalTimeSeconds * 1000

    -- Calculate the milliseconds per increment
    local millisecondsPerIncrement = totalTimeMilliseconds / totalIncrements

    return millisecondsPerIncrement
end
