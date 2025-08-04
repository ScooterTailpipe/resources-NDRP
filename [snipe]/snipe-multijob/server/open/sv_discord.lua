jobLimit = {}
if not Config.DiscordRoleBasedJobLimit then return end

local bottoken = "" -- Add your bot token here
local serverid = "" -- Add your discord server id here

-- this is the job limit table for each role. If a person has multiple roles, it will add all the limits. 
-- if you want a role to have unlimited jobs, set the job limit to -1
local discordRoles = {
    -- [role_id] = job_limit
    [704683097719046164] = 2,
}

local function GetPlayerIdentifiersList(source, type)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

function PopulateDiscordTable(source)
    if bottoken == "" or serverid == "" then
        print("You have to add your bot token and server id in server/open/sv_discord.lua")
        jobLimit[source] = -1
        return
    end
    local discordid = GetPlayerIdentifiersList(source, "discord")
    local data = nil
    local colonIndex = string.find(discordid, ":")
    discordid = string.sub(discordid, colonIndex + 1)
    PerformHttpRequest(string.format("https://discordapp.com/api/guilds/%s/members/%s", serverid, discordid), function(statusCode, response, headers)
        if statusCode == 200 then
            response = json.decode(response)
            data = response['roles']
        end
        if statusCode == 404 then
            data = false
        end
    end, 'GET', "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot "..bottoken})

    local tries = 0
    while data == nil do
        if tries < 10 then
            tries = tries + 1
            Wait(1000)
        else
            -- tried 10 times and still no data, set job limit to -1
            jobLimit[source] = -1 
            break
        end
    end

    
    for k, v in pairs(data) do
        if discordRoles[tonumber(v)] then
            if not jobLimit[source] then
                if discordRoles[tonumber(v)] == -1 then
                    jobLimit[source] = -1
                    return
                else
                    jobLimit[source] = discordRoles[tonumber(v)]
                end
            else
                if discordRoles[tonumber(v)] == -1 then
                    jobLimit[source] = -1
                    return
                else
                    jobLimit[source] = jobLimit[source] + discordRoles[tonumber(v)]
                end
            end
        end
    end
end 
