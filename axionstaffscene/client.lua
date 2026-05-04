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
        SetBlipAsShortRange(centerBlip, false)

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

    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.88)
end

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
        end

        Wait(sleep)
    end
end)