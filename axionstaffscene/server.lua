local activeScenes = {}
local sceneId = 0

local function hasPermission(src)
    return IsPlayerAceAllowed(src, AxionStaffSceneConfig.Permission)
end

local function sendNotification(src, message, notificationType)
    local typeColor = {255, 255, 0}

    if notificationType == 'error' then
        typeColor = {255, 0, 0}
    elseif notificationType == 'success' then
        typeColor = {0, 255, 0}
    end

    if AxionStaffSceneConfig.NotificationType == 'axionnotification' and GetResourceState('AxionNotifications') == 'started' then
        exports['AxionNotifications']:Notify(src, message, notificationType, 5000)
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = typeColor,
            args = {'AxionStaffScene', message}
        })
    end
end

RegisterCommand('staffscene', function(source, args)
    if source == 0 then
        print('This command must be used in-game.')
        return
    end

    if not hasPermission(source) then
        sendNotification(source, 'You do not have permission to use this command.', 'error')
        return
    end

    local radius = tonumber(string.format("%.1f", tonumber(args[1]) or AxionStaffSceneConfig.DefaultRadius))

    TriggerClientEvent('axionstaffscene:client:createScene', source, radius)
end, false)

RegisterNetEvent('axionstaffscene:server:addScene', function(coords, radius)
    local src = source

    if not hasPermission(src) then
        return
    end

    sceneId = sceneId + 1

    activeScenes[sceneId] = {
        id = sceneId,
        coords = coords,
        radius = radius,
        createdBy = GetPlayerName(src)
    }

    TriggerClientEvent('axionstaffscene:client:syncScenes', -1, activeScenes)
    sendNotification(src, 'Scene created with radius ' .. radius .. 'm. ID: ' .. sceneId, 'success')
end)

RegisterCommand('clearstaffscene', function(source, args)
    if source == 0 then
        print('This command must be used in-game.')
        return
    end

    if not hasPermission(source) then
        sendNotification(source, 'You do not have permission to use this command.', 'error')
        return
    end

    local id = tonumber(args[1])

    if not id then
        sendNotification(source, 'Usage: /clearstaffscene [id]', 'info')
        return
    end

    if activeScenes[id] then
        activeScenes[id] = nil
        TriggerClientEvent('axionstaffscene:client:syncScenes', -1, activeScenes)
        sendNotification(source, 'Scene ID ' .. id .. ' cleared.', 'success')
    else
        sendNotification(source, 'No scene found with that ID.', 'error')
    end
end, false)

RegisterCommand('clearallstaffscenes', function(source)
    if source == 0 then
        print('This command must be used in-game.')
        return
    end

    if not hasPermission(source) then
        sendNotification(source, 'You do not have permission to use this command.', 'error')
        return
    end

    activeScenes = {}
    TriggerClientEvent('axionstaffscene:client:syncScenes', -1, activeScenes)
    sendNotification(source, 'All staff scenes cleared.', 'success')
end, false)

AddEventHandler('playerJoining', function()
    local src = source
    TriggerClientEvent('axionstaffscene:client:syncScenes', src, activeScenes)
end)
