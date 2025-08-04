RegisterCommand("convertps" , function(source)
    if source ~= 0 then return print('This command can only be executed with the server console.') end
    -- truncate snipe_multijob table
    MySQL.Async.execute("TRUNCATE TABLE `snipe_multijob`", {}, function(rowsChanged)
        print("Truncated snipe_multijob")
    end)
    local data = MySQL.Sync.fetchAll("SELECT * FROM `multijobs`")

    for k, data in pairs(data) do
        local jobData = json.decode(data.jobdata)
        print(json.encode(jobData))
        for k, v in pairs(jobData) do
            
            MySQL.Async.execute("INSERT INTO `snipe_multijob` (identifier, job, grade) VALUES (@citizenid, @job, @grade)", {
                ['@citizenid'] = data.citizenid,
                ['@job'] = k,
                ['@grade'] = v
            }, function(rowsChanged)
                print("Inserted")
            end)
        end
    end
end)


RegisterCommand("convertlunar" , function(source)
    if source ~= 0 then return print('This command can only be executed with the server console.') end
    -- truncate snipe_multijob table
    MySQL.Async.execute("TRUNCATE TABLE `snipe_multijob`", {}, function(rowsChanged)
        print("Truncated snipe_multijob")
    end)
    local data = MySQL.Sync.fetchAll("SELECT * FROM `lunar_multijob`")
    for k, jobData in pairs(data) do
        MySQL.Async.execute("INSERT INTO `snipe_multijob` (identifier, job, grade) VALUES (@citizenid, @job, @grade)", {
            ['@citizenid'] = jobData.identifier,
            ['@job'] = jobData.name,
            ['@grade'] = jobData.grade
        }, function(rowsChanged)
            print("Inserted ".. jobData.name .. " for " .. jobData.identifier)
        end)
    end
end)