local isHarvesting = false

-- Create zones + blips only
CreateThread(function()
    for _, zone in pairs(Config.HarvestingLocations) do
        -- Optional blip on map
        if zone.blip then
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, zone.blip.sprite)
            SetBlipColour(blip, zone.blip.color)
            SetBlipScale(blip, zone.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.name)
            EndTextCommandSetBlipName(blip)
        end

        -- Create the marker for the harvesting location
        CreateThread(function()
            while true do
                Wait(0) -- Loop continuously to keep the marker drawn

                -- Draw the marker at the zone's coordinates
                DrawMarker(27, zone.coords.x, zone.coords.y, zone.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)

                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - vector3(zone.coords.x, zone.coords.y, zone.coords.z))
                
                if distance < zone.radius then
                    lib.showTextUI('[E] Harvest ' .. zone.label, {
                        icon = 'seedling',
                        position = 'left-center'
                    })

                    if IsControlJustReleased(0, 38) and not isHarvesting then
                        StartHarvest(zone)
                    end
                else
                    lib.hideTextUI()
                end
            end
        end)
    end
end)

-- Harvest function (clean & smooth)
function StartHarvest(zone)
    if isHarvesting then return end
    isHarvesting = true

    
    TriggerServerEvent('ghostdevelopments:harvestStart', zone.id)

    lib.requestAnimDict('pickup_object')
    TaskPlayAnim(PlayerPedId(), 'pickup_object', 'pickup_low', 8.0, -8.0, -1, 49, 0, false, false, false)

    local success = lib.progressCircle({
        duration = zone.time,
        label = 'Harvesting ' .. zone.label .. '...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { dict = 'pickup_object', clip = 'pickup_low' }
    })

    ClearPedTasksImmediately(PlayerPedId())
    isHarvesting = false

    if success then
       
        TriggerServerEvent('ghostdevelopments:harvestDone', zone.id)
    else
        lib.notify({
            title = 'Cancelled',
            description = 'You stopped harvesting',
            type = 'error'
        })
    end
end
