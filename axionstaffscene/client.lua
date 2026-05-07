local activeScenes = {}
local sceneBlips = {}

local function createBlips()
    for _, blipData in pairs(sceneBlips) do
        if blipData.center and DoesBlipExist(blipData.center) then
            RemoveBlip(blipData.center)
        end

        if blipData.radius and DoesBlipExist(blipData.radius) then
            RemoveBlip(blipData.radius)
        end
    end

    sceneBlips = {}

    for id, scene in pairs(activeScenes) do
        local coords = scene.coords

        local radiusBlip = AddBlipForRadius(coords.x, coords.y, coords.z, scene.radius)
        SetBlipColour(radiusBlip, AxionStaffSceneConfig.RadiusBlip.color)
        SetBlipAlpha(radiusBlip, AxionStaffSceneConfig.RadiusBlip.alpha)

        local centerBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(centerBlip, AxionStaffSceneConfig.SceneBlip.sprite)
        SetBlipColour(centerBlip, AxionStaffSceneConfig.SceneBlip.color)
        SetBlipScale(centerBlip, AxionStaffSceneConfig.SceneBlip.scale)
        SetBlipAsShortRange(centerBlip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(AxionStaffSceneConfig.SceneBlip.name .. ' #' .. id)
        EndTextCommandSetBlipName(centerBlip)

        sceneBlips[id] = {
            center = centerBlip,
            radius = radiusBlip
        }
    end
end

RegisterNetEvent('axionstaffscene:client:createScene', function(radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    TriggerServerEvent('axionstaffscene:server:addScene', {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, radius)
end)

RegisterNetEvent('axionstaffscene:client:syncScenes', function(scenes)
    activeScenes = scenes or {}
    createBlips()
end)

local function drawScreenText(text)
    SetTextFont(4)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)
    
    SetTextWrap(0.0, 1.0) 

    BeginTextCommandDisplayText("CELL_EMAIL_BCON")
    
    -- Split the string into chunks of 99 characters
    for i = 1, #text, 99 do
        AddTextComponentSubstringPlayerName(string.sub(text, i, i + 98))
    end
    
    EndTextCommandDisplayText(0.5, 0.5)
end

local msgTimer = true;

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        local inScene = false

        for _, scene in pairs(activeScenes) do
            local sceneCoords = vector3(scene.coords.x, scene.coords.y, scene.coords.z)
            local dist = #(playerCoords - sceneCoords)

            if dist <= scene.radius then
                inScene = true
                break
            end
        end

        if inScene then
            sleep = 0
            drawScreenText(AxionStaffSceneConfig.ScreenText)

            -- Disable combat and weapon controls
            DisableControlAction(0, 24, true) -- Left Click / Attack
            DisableControlAction(0, 25, true) -- Right Click / Aim
            DisableControlAction(0, 47, true) -- G / Weapon Special (Grenades)
            DisableControlAction(0, 58, true) -- G / Aiming / Throwing
            DisableControlAction(0, 140, true) -- R / Light Melee
            DisableControlAction(0, 141, true) -- Q / Heavy Melee
            DisableControlAction(0, 142, true) -- Left Click / Melee Attack
            DisableControlAction(0, 257, true) -- Fire (Vehicle/Foot)
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 264, true) -- Melee Attack 2

            -- Disable player firing altogether
            if IsPedArmed(ped, 6) then
                DisablePlayerFiring(ped, true)
            end

            if IsDisabledControlPressed(0, 24) or IsDisabledControlPressed(0, 25) or IsDisabledControlPressed(0, 47) or IsDisabledControlPressed(0, 58) or IsDisabledControlPressed(0, 140) or IsDisabledControlPressed(0, 141) or IsDisabledControlPressed(0, 142) or IsDisabledControlPressed(0, 257) or IsDisabledControlPressed(0, 263) or IsDisabledControlPressed(0, 264) then
                if (msgTimer) then
                    if AxionStaffSceneConfig.NotificationType == 'axionnotification' and GetResourceState('AxionNotifications') == 'started' then
                        exports['AxionNotifications']:Notify('You cannot use weapons in a staff scene area.', 'error', 5000)
                    else
                        TriggerEvent('chat:addMessage', {
                            color = {255, 0, 0},
                            args = {'AxionStaffScene', 'You cannot use weapons in a staff scene area.'}
                        })
                    end
                    msgTimer = false
                    SetTimeout(5000, function()
                        msgTimer = true
                    end)
                end
            end
        end

        Wait(sleep)
    end
end)