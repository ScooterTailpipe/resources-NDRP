AddEventHandler('jobs_creator:injectJobs', function(jobs)
    -- Assign the new jobs to the QBCore object, the following line depends on how your script is structured
    if Config.Framework == "qb" then
        QBCore.Shared.Jobs = jobs
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
    else
        JobsTable = jobs
    end
    
end)

MySQL.ready(function()
    MySQL.Sync.execute("CREATE TABLE IF NOT EXISTS `snipe_multijob` (`id` int(11) NOT NULL AUTO_INCREMENT, `identifier` varchar(100) NOT NULL DEFAULT '0', `job` varchar(100) NOT NULL DEFAULT '0', `grade` int(11) NOT NULL DEFAULT 0, `dutyHours` double DEFAULT 0, PRIMARY KEY (`id`))", {})


    -- check if table exists and doesnt have dutyHours column

    MySQL.Async.fetchAll("SELECT * FROM information_schema.COLUMNS WHERE TABLE_NAME = 'snipe_multijob' AND COLUMN_NAME = 'dutyHours'", {}, function(data)
        if not next(data) then
            print("Adding dutyhours column to snipe_multijob table")
            MySQL.Sync.execute("ALTER TABLE `snipe_multijob` ADD `dutyHours` double DEFAULT 0", {})
        end
    end)

    -- get all unique jobs from snipe_multijob
    while not next(JobsTable) do 
        Wait(50) 
    end
    MySQL.Async.fetchAll("SELECT DISTINCT job FROM snipe_multijob", {}, function(jobs)
        for k, v in pairs(jobs) do
            if not JobsTable[v.job] then
                print("Deleting job from multijob table because it doesnt exist in the jobs table anymore: " .. v.job)
                -- delete from snipe-multijob if job does not exist in JobsTable
                MySQL.Async.execute("DELETE FROM snipe_multijob WHERE job = @job", {
                    ['@job'] = v.job
                })
            end
        end
    end)

    MySQL.Async.fetchAll("SELECT * FROM snipe_multijob", {}, function(data)
        for k, v in pairs(data) do
            if not JobsTable[v.job].grades[tostring(v.grade)] then
                print("Deleting job from multijob table because it doesnt exist in the jobs table anymore: " .. v.job.. " grade: " .. v.grade)
                -- delete from snipe-multijob if job does not exist in JobsTable
                MySQL.Async.execute("DELETE FROM snipe_multijob WHERE job = @job AND grade = @grade", {
                    ['@job'] = v.job,
                    ['@grade'] = v.grade
                })
            end

        end
    end)
end)

