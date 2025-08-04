Config = Config or {}
--[[
    All the roles here can access the admin menu
    Only the GOD can set the panels for the other roles
    There are 3 options
    1. God -> can access all the commands
    
    IMPORTANT: DO NOT REMOVE GOD ROLE, IF YOU DO SO, YOU WILL NOT BE ABLE TO ACCESS THE ADMIN MENU AT ALL

    If you have a new role, you can add it here and select to give either God, Admin or Moderator or any of the custom perms you want

    eg. ["new_role"] = "God",
    eg. ["dev"] = "Admin",
]]--
Config.GodRoles = {
    ["god"] = "God", -- This is the biggest role (DO NOT REMOVE THIS ROLE)
    ["admin"] = "Admin", -- This is just a custom role
    ["mod"] = "Moderator", -- This is just a custom role
    -- ["new_role1"] = "Test", -- if you want to add more roles just add them here
    -- ["new_role2"] = "Test", -- if you want to add more roles just add them here
    -- ["new_role3"] = "Test",
    -- if you want to add more roles just add them here
    -- ["NEW_ROLE_HERE"] = "God",
    -- ["NEW_ROLE_HERE"] = "Admin",
    -- ["NEW_ROLE_HERE"] = "Moderator",
}

-- Original Permissions table for information on all possible available options
Config.Permissions = {
    ["license:8d6880e256e73fdb1ca3c81764f73ca015152880"] = "god", -- CUSH the role god, admin or mod should be the key from Config.GodRoles which means the values that are added in square brackets.
    ["license:aaaa0693a6a2a27bc86430659dd85779e942e550d0"] = "god", -- AUSTIN
    ["license:a8fe274f60e97d5540675fed219467b9d0570255"] = "god", -- TEDDY
    ["license:17149106431c0f0e20fc4495108efdf958a87b2e"] = "god", -- KATIE
    ["license:81cbc9e440ad246a4a5e58dda2072e15c39997ad"] = "god", -- IRISHCUSH
    ["license:6777ac3067bffe8a6a7a11daa6605eb6cc9f8318"] = "god", -- ANGEL
    ["license:56f05a67542d8c6dc4f271cb1af2af508225a0f3"] = "god", -- ATLAS
    ["license:492bb1bf4cbece8da0d2891401c19cdce8de559e"] = "god", -- JAY
    ["license:dadee8a808a4e42f4cddfbc3547b5c2952acea87"] = "god", -- SCOOTER


    --["fivem:1234"] = "god",
    --["steam:1234"] = "god",
    --["124584938326312"] = "god", -- discord roles (copy the role id and paste it here) (If you want to use the discord roles, you need to add the bot token and server id in sv_perms.lua at the top)
    --["XY123456"] = "god", -- citizenid for qbcore
    --["char1:12334"] = "god", -- charid for ESX

    
  
  
  
  
  
    -- ["license:6d3b6254a50416697dcaa91878e2eb03d9112302"] = {"mod", "admin"}, -- the role god, admin or mod should be the key from Config.GodRoles which means the values that are added in square brackets.
    -- ["license:1234"] = "admin",
    -- ["license:1234"] = "mod",
    -- ["license:1234"] = "new_role1",
    -- ["license:1234"] = "new_role2",
    -- ["license:1234"] = "new_role3",
}

