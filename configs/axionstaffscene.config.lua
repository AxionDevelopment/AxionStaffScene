AxionStaffSceneConfig = {}

-- Permission required to use the staff scene commands.
AxionStaffSceneConfig.Permission = 'axionstaffscene.use'

-- NotificationType options:
-- "axionnotification" - Warning will be sent as an Axion Notification (requires AxionNotifications resource) (default)
--     Download AxionNotifications here: https://github.com/AxionDevelopment/AxionNotifications
-- "chat" - Warning will be sent as a chat message. No dependencies required.
AxionStaffSceneConfig.NotificationType = 'axionnotification'

-- Default radius for new staff scenes.
AxionStaffSceneConfig.DefaultRadius = 75.0

-- Default radius for new staff scenes.
AxionStaffSceneConfig.ViewDistance = 300.0

-- Blip settings for staff scenes.
AxionStaffSceneConfig.SceneBlip = {
    sprite = 161,
    color = 1,
    scale = 0.9,
    name = 'Staff Scene'
}

-- Blip settings for the radius of staff scenes.
AxionStaffSceneConfig.RadiusBlip = {
    color = 1,
    alpha = 90
}

-- Text to display when a player is inside a staff scene area.
-- Can use \n for new lines.
AxionStaffSceneConfig.ScreenText = 'You are inside a staff scene area.\nYou are not allowed to roleplay here.\nPlease leave the area unless involved in the scene.\nWeapons and combat are prohibited.'