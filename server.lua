local active = {} -- [src] = {time = os.time(), zone = id}

-- Clear active data when player drops
AddEventHandler('playerDropped', function()
    active[source] = nil
end)

-- Start harvesting event
RegisterNetEvent('forcng:harvestStart', function(zoneId)
    local src = source
    local zone = nil

    -- Find the zone by ID
    for _, z in pairs(Config.HarvestingLocations) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    -- If zone exists, track the harvest start
    if zone then
        active[src] = { time = os.time(), zone = zoneId }
    end
end)

-- Complete harvesting event
RegisterNetEvent('forcng:harvestDone', function(zoneId)
    local src = source
    local data = active[src]

    -- Anti-exploit check: ensure valid harvesting session
    if not data or data.zone ~= zoneId or (os.time() - data.time) > 35 then
        DropPlayer(src, 'Harvest exploit detected')
        return
    end

    -- Clear the active harvest data for the player
    active[src] = nil

    -- Find the zone by ID to retrieve the item details
    local zone = nil
    for _, z in pairs(Config.HarvestingLocations) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    -- If zone is valid, grant harvested items to the player
    if zone then
        local amount = math.random(zone.min, zone.max)
        exports.ox_inventory:AddItem(src, zone.item, amount)

        -- Notify the player of the successful harvest
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Harvested',
            description = ('+%d %s'):format(amount, zone.label),
            type = 'success',
            duration = 4000
        })
    end
end)