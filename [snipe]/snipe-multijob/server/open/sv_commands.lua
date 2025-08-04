onlineAdmins = {}
local function HasAccessToRemoveCommand(source)
    if onlineAdmins[source] ~= nil then
        return onlineAdmins[source]
    end
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in pairs(identifiers) do
        if Config.Admins[id] then
            onlineAdmins[source] = true
            return true
        end
    end
    onlineAdmins[source] = false
    return false
end

lib.addCommand('removejob', {
    help = 'Removes Job From Player',
    params = {
        {
            name = 'target',
            type = 'number',
            help = 'Target player\'s server id',
        },
        {
            name = 'job',
            type = 'string',
            help = 'Name of the job to remove',
        },
    },
}, function(source, args, raw)
    if not HasAccessToRemoveCommand(source) then
        return
    end

    local target = args.target
    local job = args.job
    if not target or not job then
        return
    end
    if not playerIdToIdentifier[target] then
        ShowNotification(source, Locales.player_not_online, "error")
        return
    end
    if Config.IgnoreJobs[job] then
        ShowNotification(source, Locales.cannot_remove_ignored_jobs, "error")
        return
    end
    if Config.Framework == "esx" and OffDutyJob(job) then
        ShowNotification(source, Locales.cannot_remove_offduty_jobs, "error")
        return
    end
    RemoveJob(source, playerIdToIdentifier[target], job)
end)

local Debug = false
function debugPrint(msg)
    if Debug then
        print(msg)
    end
end