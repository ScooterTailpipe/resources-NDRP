Config = {}

-- if you have renamed your qb-core, es_extended, event names, make sure to change them. Based on this information your framework will be detected.
Config.FrameworkTriggers = {
    ["qb"] = {
        ResourceName = "qb-core",
        PlayerLoaded = "QBCore:Client:OnPlayerLoaded",
        PlayerUnload = "QBCore:Client:OnPlayerUnload",
        OnJobUpdate = "QBCore:Client:OnJobUpdate",
    },
    ["esx"] = {
        ResourceName = "es_extended",
        PlayerLoaded = "esx:playerLoaded",
        PlayerUnload = "esx:playerDropped",
        OnJobUpdate = "esx:setJob",
    }
}

Config.Notify = "ox" -- qb || ox || esx || okok

-- this will ignore these jobs and will not show them in the job list. You can add the jobs you want to ignore here.
-- Do not add offduty jobs here(for esx only. For eg. offpolice, offambulance). these jobs will be ignored by default.
Config.IgnoreJobs = {
    ["unemployed"] = true,
}

-- Since I do a string search to look for "off" in the job name, I have added a whitelist here. If you have any job that starts with off, make sure to add it here.
-- Do not add offduty jobs here(for esx only. For eg. offpolice, offambulance). these jobs will be ignored by default.
Config.WhitelistJobsThatStartWithOff = {
    ["office"] = true
}

-- if you set this to true, you have to edit the roles/server id/bot token in server/open/sv_discord.lua
Config.DiscordRoleBasedJobLimit = true

-- Admins who can use the removejob command
Config.Admins = {
    ["license:6d3b6254a50416697dcaa91878e2eb03d911230"] = true,
}

-- These jobs wont have the option to toggle duty using the multijob menu
-- You can add the jobs you want to ignore here which will not have the option to toggle duty using the multijob menu.
Config.NotAllowDutySwitch = {
    "police", "ambulance"
}

Config.ShowDutyButton = false -- if you want to show the duty button in the multijob menu, set this to true. If you want to hide it, set this to false

-- DO NOT TOUCH THIS!!!!

for k, v in pairs(Config.FrameworkTriggers) do
    if GetResourceState(v.ResourceName) == "started" then
        Config.Framework = k
        break
    end
end
