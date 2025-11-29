local active = {} -- [src] = {time = os.time(), zone = id}

-- Clear active data when player drops/disconnects
AddEventHandler('playerDropped', function()
    local src = source
    active[src] = nil
end)

-- Player started harvesting
RegisterNetEvent('ghostdevelopments:harvestStart', function(zoneId)
    local src = source
    local zone = nil

    -- Find the zone config by ID
    for _, z in pairs(Config.HarvestingLocations) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    -- If zone exists, mark player as actively harvesting
    if zone then
        active[src] = { time = os.time(), zone = zoneId }
    end
end)

-- Player finished harvesting
RegisterNetEvent('ghostdevelopments:harvestDone', function(zoneId)
    local src = source
    local data = active[src]

    -- === Anti-exploit checks ===
    if not data 
    or data.zone ~= zoneId 
    or (os.time() - data.time) > 35 then          -- adjust 35 if your harvest time is longer
        DropPlayer(src, 'Harvest exploit detected')
        return
    end

    -- Clear the active session
    active[src] = nil

    -- Find zone again to get item details
    local zone = nil
    for _, z in pairs(Config.HarvestingLocations) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    -- Reward the player
    if zone then
        local amount = math.random(zone.min, zone.max)
        exports.ox_inventory:AddItem(src, zone.item, amount)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Harvested',
            description = ('+%d %s'):format(amount, zone.label),
            type = 'success',
            duration = 4000
        })
    end
end)
