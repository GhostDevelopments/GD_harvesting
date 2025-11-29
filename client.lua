local isHarvesting = false

-- Helper: Native GTA V Help Text (bottom left)
local function ShowHelpNotification(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Create blips + zones + native help text
CreateThread(function()
    for _, zone in pairs(Config.HarvestingLocations) do
        
        -- Blip (optional)
        if zone.blip then
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, zone.blip.sprite or 496)
            SetBlipColour(blip, zone.blip.color or 2)
            SetBlipScale(blip, zone.blip.scale or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.name or zone.label)
            EndTextCommandSetBlipName(blip)
        end

        -- Modern ox_lib zone (handles distance & E press perfectly)
        lib.zones.sphere({
            name = 'harvest_' .. zone.id,
            coords = zone.coords,
            radius = zone.radius or 2.0,
            debug = false,

            onEnter = function()
                -- Native GTA-style text when you walk in
                ShowHelpNotification("Press ~INPUT_CONTEXT~ to harvest ~g~" .. zone.label)
            end,

            inside = function()
                -- Keep showing the message while inside
                ShowHelpNotification("Press ~INPUT_CONTEXT~ to harvest ~g~" .. zone.label)

                -- Press E
                if IsControlJustReleased(0, 38) and not isHarvesting then -- 38 = E
                    StartHarvest(zone)
                end
            end,

            onExit = function()
                -- Optional: clear help text when leaving (GTA does this automatically after ~3 sec)
            end
        })

        -- Marker (only drawn when nearby - optimized)
        CreateThread(function()
            while true do
                Wait(1000)
                local dist = #(GetEntityCoords(PlayerPedId()) - zone.coords)
                if dist < 50.0 then
                    DrawMarker(27, zone.coords.x, zone.coords.y, zone.coords.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.2, 1.2, 1.0, 255, 0, 0, 100,
                        false, true, 2, false, false, false, false)
                    if dist < zone.radius then Wait(0) else Wait(200) end
                end
            end
        end)
    end
end)

-- Harvest function (unchanged, still perfect)
function StartHarvest(zone)
    if isHarvesting then return end
    isHarvesting = true

    TriggerServerEvent('ghostdevelopments:harvestStart', zone.id)

    local success = lib.progressCircle({
        duration = zone.time or 6000,
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
            title = 'Harvesting Cancelled',
            description = 'You stopped harvesting ' .. zone.label,
            type = 'error'
        })
    end
end
