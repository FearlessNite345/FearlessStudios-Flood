local increment = 0.1
local maxWaterLevel = 150.0
local flooding = false

Citizen.CreateThread(function ()
    LoadWaterFromPath(GetCurrentResourceName(), 'waterLevels/base.xml')
end)

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
