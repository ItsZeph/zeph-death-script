local isDead = false
local reviveAllowed = false
local respawnAllowed = false
local deathCoords = nil

local function notify(data)
    exports['ox_lib']:notify(data)
end

local function getDistance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

local function getNearestHospital()
    local nearest = nil
    local nearestDist = math.huge
    for _, hospital in ipairs(Config.Hospitals) do
        local dist = getDistance(deathCoords.x, deathCoords.y, deathCoords.z, hospital.x, hospital.y, hospital.z)
        if dist < nearestDist then
            nearestDist = dist
            nearest = hospital
        end
    end
    return nearest
end

local function resetState()
    isDead = false
    reviveAllowed = false
    respawnAllowed = false
    deathCoords = nil
    SendNUIMessage({ action = "hide" })
    SetNuiFocus(false, false)
end

local function doRespawn()
    local hospital = getNearestHospital()
    local label = hospital.label
    resetState()
    RequestCollisionAtCoord(hospital.x, hospital.y, hospital.z)
    NetworkResurrectLocalPlayer(hospital.x, hospital.y, hospital.z, hospital.h, true, false)
    Wait(0)
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)
    FreezeEntityPosition(ped, false)
    TriggerEvent('playerSpawned', hospital.x, hospital.y, hospital.z, hospital.h)
    notify({
        title = 'Respawned',
        description = 'You have respawned at ' .. label .. '.',
        type = 'success',
        position = 'top-center'
    })
end

local function doRevive()
    local coords = deathCoords
    resetState()
    local ped = PlayerPedId()
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    Wait(0)
    ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)
    FreezeEntityPosition(ped, false)
    notify({
        title = 'Revived',
        description = 'You have been revived.',
        type = 'success',
        position = 'top-center'
    })
end

AddEventHandler('onClientMapStart', function()
    exports.spawnmanager:spawnPlayer()
    Wait(1500)
    exports.spawnmanager:setAutoSpawn(false)
end)

CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()

        if IsEntityDead(ped) then
            if not isDead then
                isDead = true
                reviveAllowed = false
                respawnAllowed = false
                deathCoords = GetEntityCoords(ped)

                SendNUIMessage({
                    action = "show",
                    respawnTime = Config.RespawnTime,
                    reviveTime = Config.ReviveTime
                })

                CreateThread(function()
                    Wait(Config.RespawnTime * 1000)
                    if isDead then
                        respawnAllowed = true
                        SendNUIMessage({ action = "respawnReady" })
                    end
                end)

                CreateThread(function()
                    Wait(Config.ReviveTime * 1000)
                    if isDead then
                        reviveAllowed = true
                        SendNUIMessage({ action = "reviveReady" })
                    end
                end)
            end

            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
        end
    end
end)

RegisterCommand('respawn', function()
    if not isDead then return end
    if not respawnAllowed then
        notify({
            title = 'Cannot Respawn',
            description = 'You cannot respawn until the timer is up.',
            type = 'error',
            position = 'top-center'
        })
        return
    end
    doRespawn()
end, false)

RegisterCommand('revive', function()
    if not isDead then return end
    if not reviveAllowed then
        notify({
            title = 'Cannot Revive',
            description = 'You cannot revive until the timer is up.',
            type = 'error',
            position = 'top-center'
        })
        return
    end
    doRevive()
end, false)

RegisterNetEvent('death:adminRespawn', function()
    if not isDead then return end
    doRespawn()
end)

RegisterNetEvent('death:adminRevive', function()
    if not isDead then return end
    doRevive()
end)
