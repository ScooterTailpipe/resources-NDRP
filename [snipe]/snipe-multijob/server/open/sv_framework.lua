QBCore, ESX = nil, nil
disabled = false
JobsTable = {}

if Config.Framework == "qb" then
    TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
    if QBCore == nil then
        QBCore = exports[Config.FrameworkTriggers["qb"].ResourceName]:GetCoreObject()
    end

    local TempJobsTable = QBCore.Shared.Jobs
    -- dump from TempJobsTable to JobsTable with grade from number to string
    for k, v in pairs(TempJobsTable) do
        JobsTable[k] = JobsTable[k] or {
            label = v.label,
            grades = {},
            defaultDuty = v.defaultDuty,
            offDutyPay = v.offDutyPay,
        }
        for grade, gradeData in pairs(v.grades) do
            if not  JobsTable[k]["grades"] then
                JobsTable[k]["grades"] = {}
            end
            JobsTable[k]["grades"][tostring(grade)] = gradeData
        end
    end
elseif Config.Framework == "esx" then
    local status, errorMsg = pcall(function() ESX = exports[Config.FrameworkTriggers["esx"].ResourceName]:getSharedObject() end)
    if (ESX == nil) then
        TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
    end
    while not next(ESX.GetJobs()) do 
        Wait(50) 
    end
    JobsTable = ESX.GetJobs()
else
    print("Framework not found")
    disabled = true
end

function ShowNotification(source, msg, type)
    if Config.Notify == "qb" then
        TriggerClientEvent('QBCore:Notify', source, msg, type)
    elseif Config.Notify == "ox" then
        TriggerClientEvent('ox_lib:notify', source, {type = type, description = msg})
    elseif Config.Notify == "esx" then
        TriggerClientEvent('esx:showNotification', source, msg)
    elseif Config.Notify == "okok" then
        TriggerClientEvent('okokNotify:Alert', source, "Banking", msg, 5000, type)
    end
end

function GetPlayerFrameworkIdentifier(id)
    if Config.Framework == "qb" then
        local player = QBCore.Functions.GetPlayer(id)
        if not player then return nil end
        return player.PlayerData.citizenid
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(id)
        if not xPlayer then return nil end
        return xPlayer.identifier
    end
end

function SetPlayerJob(source, job, grade)
    if Config.Framework == "qb" then
        local player = QBCore.Functions.GetPlayer(source)
        if not player then return end
        player.Functions.SetJob(job, grade)
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end
        xPlayer.setJob(job, grade)
    end
end

function ToggleDuty(source)
    if Config.Framework == "qb" then
        local player = QBCore.Functions.GetPlayer(source)
        if not player then return end
        player.Functions.ToggleDuty()
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return end
        xPlayer.setJob(xPlayer.job.name, xPlayer.job.grade, not xPlayer.job.onduty)
    end
end

function GetPlayerFrameWorkName(id)
    if Config.Framework == "qb" then
        local player = QBCore.Functions.GetPlayer(id)
        if not player then return nil end
        return player.PlayerData.charinfo.firstname.." "..player.PlayerData.charinfo.lastname
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(id)
        if not xPlayer then return nil end
        return xPlayer.getName()
    end
end

-- ONLY FOR ESX
-- if you have any job that starts with off, make sure to add it here. For example, if you have a job called office, you can add it here and it will be shown in the job list.
-- I have added clause for off duty jobs and I neglect all the jobs that start with off, so if you have any job that starts with off, make sure to add it here.
-- do not add off duty jobs here (eg .offpolice)
function OffDutyJob(job)
    -- check if the job name starts with off
    if string.sub(job, 1, 3) == "off" and not Config.WhitelistJobsThatStartWithOff[job] then
        return true
    end
    return false
end

function GetPlayerDutyStatus(source)
    if Config.Framework == "qb" then
        local player = QBCore.Functions.GetPlayer(source)
        if not player then return nil end
        return player.PlayerData.job.onduty
    elseif Config.Framework == "esx" then
        if OffDutyJob(playerIdToJob[source]) or playerIdToJob[source] == "unemployed" then
            return false
        end
        return true
    end
end

function SetOfflineUnemployedJob(identifier)
    if Config.Framework == "qb" then
        local job = {}
        job.name = "unemployed"
        job.label = "Unemployed"
        job.payment = JobsTable[job.name].grades['0'].payment or 500
        job.onduty = false
        job.isboss = false
        job.grade = {}
        job.grade.name = nil
        job.grade.level = 0
        MySQL.update('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), identifier })
    elseif Config.Framework == "esx" then
        local job = "unemployed"
        MySQL.update('UPDATE users SET job = ?, job_grade = 0 WHERE identifier = ?', { job, identifier })
    end
end

RegisterNetEvent('QBCore:Server:OnJobUpdate', function(source, newJob)
    ValidataJobChange(source, newJob)
end)

RegisterNetEvent('esx:setJob', function(source, newJob)
    ValidataJobChange(source, newJob)
end)

-- Only for ESX
lib.callback.register("snipe-multijob:server:toggleDuty", function(source)
    local currentJob = playerIdToJob[source]

    if currentJob == "unemployed" then
        ShowNotification(source, "You are unemployed", "error")
        return {false, false}
    end

    if not esxOffDuty then
        if JobsTable["off"..currentJob] then
            SetPlayerJob(source, "off"..currentJob, playerIdToJobGrade[source])
            UpdateJobTables(source, currentJob, "off"..currentJob, playerIdToJobGrade[source])
            esxOffDuty = true
            return {true, false}
        else
            SetPlayerJob(source, "unemployed", 0)
            UpdateJobTables(source, currentJob, "unemployed", 0)
            esxOffDuty = false
            return {true, true}
        end
    else
        SetPlayerJob(source, string.sub(playerIdToJob[source], 4), playerIdToJobGrade[source])
        UpdateJobTables(source, "off"..currentJob, currentJob, playerIdToJobGrade[source])
        esxOffDuty = false
        return {true, false}
    end
end)