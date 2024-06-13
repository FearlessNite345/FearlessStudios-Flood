local increment = 0.1
local maxWaterLevel = 150.0
local flooding = false

local waveAmplitudeIncrement = 0.2
local maxWaveAmplitude = 300.0

RegisterCommand('loadwater', function(source, args)
    print('Loading custom water.xml')
    local success = LoadWaterFromPath(GetCurrentResourceName(), 'waterLevels/base.xml')
    if success ~= 1 then
        print('Failed to load water.xml, does the file exist within the resource?')
    end
    local waterQuadCount = GetWaterQuadCount()
    print("water quad count: " .. waterQuadCount)
    local calmingQuadCount = GetCalmingQuadCount()
    print("calming quad count: " .. calmingQuadCount)
    local waveQuadCount = GetWaveQuadCount()
    print("wave quad count: " .. waveQuadCount)
end, false)

RegisterCommand('flood', function()
    if not flooding then
        flooding = true
        Citizen.CreateThread(function()
            while flooding do
                local waterQuadCount = GetWaterQuadCount()
                local waveQuadCount = GetWaveQuadCount()
                local allQuadsAtMax = true

                print(GetEntityCoords(PlayerPedId(), false).z)

                for i = 1, waterQuadCount do
                    local success, waterQuadLevel = GetWaterQuadLevel(i)
                    if success then
                        local newLevel = waterQuadLevel + increment
                        if newLevel <= maxWaterLevel then
                            SetWaterQuadLevel(i, newLevel)
                            allQuadsAtMax = false
                        else
                            SetWaterQuadLevel(i, maxWaterLevel)
                        end
                    end
                end

                for i = 1, waveQuadCount do
                    local success, waveQuadAmplitude = GetWaveQuadAmplitude(i)
                    if success then
                        local newAmplitude = waveQuadAmplitude + waveAmplitudeIncrement
                        if newAmplitude <= maxWaveAmplitude then
                            SetWaveQuadAmplitude(i, newAmplitude)
                            allQuadsAtMax = false
                        else
                            SetWaveQuadAmplitude(i, maxWaveAmplitude)
                        end
                    end
                end

                if allQuadsAtMax then
                    flooding = false
                end

                Citizen.Wait(Config.floodInterval) -- Adjust the interval as needed
            end

            print('Flooding ended')
        end)
    end
end, false)

RegisterCommand('resetFlood', function()
    ResetWater()
    flooding = false
    print("Water level and waves reset.")
end, false)

function DisableAllCalmingQuads()
    local calmingQuadCount = GetCalmingQuadCount()
    for i = 1, calmingQuadCount do
        SetCalmingQuadDampening(i, 0.0)
    end
end
