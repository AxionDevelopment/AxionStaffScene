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
            radius = radiusBlip,
            x = coords.x,
            y = coords.y,
            z = coords.z
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

local wasInScene = false

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        local inScene = false

        for _, blipData in pairs(sceneBlips) do
            local distance = #(playerCoords - vector3(blipData.x, blipData.y, blipData.z))
            if distance > AxionStaffSceneConfig.ViewDistance then
                SetBlipDisplay(blipData.radius, 0)
                SetBlipDisplay(blipData.center, 0)
            else
                SetBlipDisplay(blipData.radius, 2)
                SetBlipDisplay(blipData.center, 2)
            end
        end

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
            wasInScene = true
            local playerVeh = GetVehiclePedIsIn(ped, false)
            
            SetEntityAlpha(ped, 150, false)
            if playerVeh ~= 0 then
                SetEntityAlpha(playerVeh, 150, false)
            end

            if GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then
                SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            end


            local playerVeh = GetVehiclePedIsIn(ped, false)
            local entityToCheck = (playerVeh ~= 0) and playerVeh or playerPed

            for _, player in ipairs(GetActivePlayers()) do
                local otherPed = GetPlayerPed(player)
                if otherPed ~= ped then
                    local otherVeh = GetVehiclePedIsIn(otherPed, false)
                    local otherEntity = (otherVeh ~= 0) and otherVeh or otherPed
                    
                    SetEntityNoCollisionEntity(entityToCheck, otherEntity, true)
                end
            end
            
            for _, player in ipairs(GetActivePlayers()) do
                local otherPed = GetPlayerPed(player)
                if otherPed ~= ped then
                    SetEntityNoCollisionEntity(ped, otherPed, true)
                end
            end
            
            drawScreenText(AxionStaffSceneConfig.ScreenText)

            DisableControlAction(0, 24, true) 
            DisableControlAction(0, 25, true) 
            DisableControlAction(0, 47, true) 
            DisableControlAction(0, 58, true) 
            DisableControlAction(0, 140, true) 
            DisableControlAction(0, 141, true) 
            DisableControlAction(0, 142, true) 
            DisableControlAction(0, 257, true) 
            DisableControlAction(0, 263, true) 
            DisableControlAction(0, 264, true) 

            if IsPedArmed(ped, 6) then
                DisablePlayerFiring(ped, true)
            end

            if IsDisabledControlPressed(0, 24) or IsDisabledControlPressed(0, 25) or IsDisabledControlPressed(0, 140) then
                if msgTimer then
                    if AxionStaffSceneConfig.NotificationType == 'axionnotification' and GetResourceState('AxionNotifications') == 'started' then
                        exports['AxionNotifications']:Notify('You cannot use weapons in a staff scene area.', 'error', 5000)
                    else
                        TriggerEvent('chat:addMessage', {
                            color = {255, 0, 0},
                            args = {'AxionStaffScene', 'You cannot use weapons in a staff scene area.'}
                        })
                    end
                    msgTimer = false
                    SetTimeout(5000, function() msgTimer = true end)
                end
            end

            SetEntityInvincible(ped, true)
            SetEntityProofs(ped, true, true, true, true, true, true, true, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdoll(ped, false)
            SetEntityHealth(ped, 200)
            SetEntityMaxHealth(ped, 200)
        else 
            if wasInScene then
                ResetEntityAlpha(ped)
                SetEntityInvincible(ped, false)
                SetEntityProofs(ped, false, false, false, false, false, false, false, false)
                SetBlockingOfNonTemporaryEvents(ped, false)
                SetPedCanRagdoll(ped, true)
                wasInScene = false -- Reset the state
            end
            sleep = 500
        end

        Wait(sleep)
    end
end)

-- Ensures that pvp is always reenabled.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(GetPlayerPed(-1), true, false)
    end
end)