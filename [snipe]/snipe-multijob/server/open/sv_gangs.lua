if Config.Framework ~= "qb" then return end

local playerGangs = {}
local playerGangGrades = {}
local gangSources = {}
local isPlayerGangBoss = {}

lib.callback.register("snipe-multijob:server:playerGangInitialised", function(source, playerGang)
    if not playerGang then return end
    if playerGangs[source] then return end -- prevents from shitty multicharacters triggering player load events
    playerGangs[source] = playerGang.gang
    playerGangGrades[source] = playerGang.gangGrade
    isPlayerGangBoss[source] = playerGang.isBoss
    if not gangSources[playerGang.gang] then
        gangSources[playerGang.gang] = {}
    end
    table.insert(gangSources[playerGang.gang], source)
end)

lib.callback.register("snipe-multijob:server:playerGangUpdated", function(source, playerGang)
    if not playerGang then return end
    local oldGang = playerGangs[source]
    if oldGang then
        for k, v in pairs(gangSources[oldGang]) do
            if v == source then
                table.remove(gangSources[oldGang], k)
                break
            end
        end
    end
    playerGangs[source] = playerGang.gang
    playerGangGrades[source] = playerGang.gangGrade
    isPlayerGangBoss[source] = playerGang.isBoss
    if not gangSources[playerGang.gang] then
        gangSources[playerGang.gang] = {}
    end
    table.insert(gangSources[playerGang.gang], source)
end)

lib.callback.register("snipe-multijob:server:getGangData", function(source)
    local gang = playerGangs[source]

    if not gang then return {} end
    local gangIdentifierTable = {}
    for k, v in pairs(playerIdToIdentifier) do
        local identifier = v
        gangIdentifierTable[#gangIdentifierTable+1] = identifier
    end
    local data = MySQL.Sync.fetchAll(Queries[Config.Framework]["get_players_by_gang"], {
        ['@gangName'] = gang,
        ["@myGrade"] = playerGangGrades[source],
        ['@gangIdentifierTables'] = next(gangIdentifierTable) and gangIdentifierTable or {""},
    })

    for k, v in pairs(gangIdentifierTable) do
        if playerGangs[playerIdentifierToSource[v]] == gang then
            data[#data+1] = {
                id = v,
                name = playerIdentifierToName[v],
                gradeId = playerGangGrades[playerIdentifierToSource[v]],
                cannotFire = playerGangGrades[source] > playerGangGrades[playerIdentifierToSource[v]] and 0 or 1,
                isOnline = true
            }
        end
    end
    return data
end)

AddEventHandler("playerDropped", function(source)
    local gang = playerGangs[source]
    if not gang then return end

    for k, v in pairs(gangSources[gang]) do
        if v == source then
            table.remove(gangSources[gang], k)
            break
        end
    end
    playerGangs[source] = nil
    playerGangGrades[source] = nil
end)

-- Actions

lib.callback.register("snipe-multijob:server:fireGangMember", function(source, targetCitizenId)
    if not isPlayerGangBoss[source] then return end

    if playerIdentifierToSource[targetCitizenId] then
        local otherPlayer = QBCore.Functions.GetPlayer(playerIdentifierToSource[targetCitizenId])
        if otherPlayer then
            otherPlayer.Functions.SetGang("none", 0)
            ShowNotification(otherPlayer.PlayerData.source, Locales["removed_from_gang"])
            return
        end
    else
        local gang = {}
        gang.name = "none"
        gang.label = "No Affiliation"
        gang.payment = 0
        gang.onduty = true
        gang.isboss = false
        gang.grade = {}
        gang.grade.name = nil
        gang.grade.level = 0
        MySQL.update('UPDATE players SET gang = ? WHERE citizenid = ?', {json.encode(gang), targetCitizenId})
    end
    return
end)

lib.callback.register("snipe-multijob:server:changeGradeGang", function(source, targetCitizenId, newGrade)
    if not isPlayerGangBoss[source] then return end
    if playerIdentifierToSource[targetCitizenId] then
        local otherPlayer = QBCore.Functions.GetPlayer(playerIdentifierToSource[targetCitizenId])
        if otherPlayer then
            otherPlayer.Functions.SetGang(playerGangs[source], newGrade)
            ShowNotification(otherPlayer.PlayerData.source, string.format(Locales["grade_changed"], newGrade))
            return
        end
    else
        MySQL.Async.execute("UPDATE players SET gang = JSON_SET(gang, '$.grade.level', @newGrade) WHERE citizenid = @citizenid", {
            ['@newGrade'] = newGrade,
            ['@citizenid'] = targetCitizenId
        })
    end
    return
end)

lib.callback.register("snipe-multijob:server:hirePlayerGang", function(source, otherPlayerSrc, gang, grade)
    if not isPlayerGangBoss[source] then return end
    if otherPlayerSrc == source then return false, Locales["cannot_hire_self"] end
    if not playerIdToIdentifier[otherPlayerSrc] then return false, Locales["player_not_online"] end
    if playerGangs[otherPlayerSrc] ~= "none" then return false, Locales["already_in_gang"] end
    
    local name = playerIdentifierToName[playerIdToIdentifier[otherPlayerSrc]]

    local otherPlayer = QBCore.Functions.GetPlayer(otherPlayerSrc)
    otherPlayer.Functions.SetGang(gang, grade)
    return true, name, playerIdToIdentifier[otherPlayerSrc]
end)