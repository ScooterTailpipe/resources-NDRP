QBCore, ESX = nil, nil
PlayerInfo = {}
PlayerJob = nil
PlayerGang = nil
PlayerFullyLoaded = false

if Config.Framework == "qb" then
    QBCore = exports[Config.FrameworkTriggers["qb"].ResourceName]:GetCoreObject()
elseif Config.Framework == "esx" then
    local status, errorMsg = pcall(function() ESX = exports[Config.FrameworkTriggers["esx"].ResourceName]:getSharedObject() end)
    if (ESX == nil) then
        while ESX == nil do
            Wait(100)
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
        end
    end
end

local function PopulateData()
    if Config.Framework == "qb" then
        PlayerData = QBCore.Functions.GetPlayerData()
        PlayerJob = PlayerData.job
        PlayerInfo = {
            job = PlayerData.job.name,
            jobLabel = PlayerData.job.label,
            jobGrade = PlayerData.job.grade.level,
        }
        PlayerGang = {
            gang = PlayerData.gang.name,
            gangLabel = PlayerData.gang.label,
            gangGrade = PlayerData.gang.grade.level,
            isBoss = PlayerData.gang.isboss,
        }
        lib.callback.await("snipe-multijob:server:playerGangInitialised", false, PlayerGang)
        Config.JobAccounts = true
        PlayerData = nil
    elseif Config.Framework == "esx" then
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
        PlayerData = ESX.GetPlayerData()
        PlayerJob = PlayerData.job
        PlayerInfo = {
            job = PlayerData.job.name,
            jobLabel = PlayerData.job.label,
            jobGrade = PlayerData.job.grade,
        }
        PlayerData = nil
    end

    lib.callback.await("snipe-multijob:server:playerInitialised", false, PlayerInfo)
    print("Snipe-Multijob: Player Data Loaded")
    PlayerFullyLoaded = true
end

local function UpdateJob(jobData)
    if Config.Framework == "qb" then
        PlayerInfo.job = jobData.name
        PlayerInfo.jobLabel = jobData.label
        PlayerInfo.jobGrade = jobData.grade.level
    elseif Config.Framework == "esx" then
        PlayerInfo.job = jobData.name
        PlayerInfo.jobLabel = jobData.label
        PlayerInfo.jobGrade = jobData.grade
    end
    lib.callback.await("snipe-multijob:server:playerJobUpdated", false, PlayerInfo)
end

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].PlayerLoaded)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].PlayerLoaded, function()
    PopulateData()
end)

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].PlayerUnload)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].PlayerUnload, function()
    PlayerLoaded = false
    PlayerJob = nil
    lib.callback.await("snipe-multijob:server:playerUnloaded", false)
end)

RegisterNetEvent(Config.FrameworkTriggers[Config.Framework].OnJobUpdate)
AddEventHandler(Config.FrameworkTriggers[Config.Framework].OnJobUpdate, function(job)
    PlayerJob = job
    UpdateJob(job)
end)

RegisterNetEvent("QBCore:Client:SetDuty")
AddEventHandler("QBCore:Client:SetDuty", function(dutyStatus)
    lib.callback.await("snipe-multijob:server:playerJobUpdated", false, PlayerInfo)
end)

RegisterNetEvent("QBCore:Client:OnGangUpdate")
AddEventHandler("QBCore:Client:OnGangUpdate", function(gang)
    PlayerGang = {
        gang = gang.name,
        gangLabel = gang.label,
        gangGrade = gang.grade.level,
        isBoss = gang.isboss,
    }
    lib.callback.await("snipe-multijob:server:playerGangUpdated", false, PlayerGang)
end)

AddEventHandler("onResourceStart", function(name)
    Wait(2000)
    if name ~= GetCurrentResourceName() then return end
    PopulateData()
    
end)

function ShowNotification(msg, type)
    if Config.Notify == "ox" then
        lib.notify({type = type, description = msg})
    elseif Config.Notify == "qb" then
        QBCore.Functions.Notify(msg, type)
    elseif Config.Notify == "esx" then
        ESX.ShowNotification(msg)
    elseif Config.Notify == "okok" then
        exports['okokNotify']:Alert("Banking", msg, 5000, type)
    end
end

-- if using QBCore only. For ESX, the changes are on server side in sv_framework.lua
function ToggleDuty()
    TriggerServerEvent("QBCore:ToggleDuty") -- this event is present in qb-core/server/main.lua
end

RegisterNetEvent("qb-gangmenu:client:OpenMenu", function()
    exports["snipe-multijob"]:OpenGangMenu()
end)