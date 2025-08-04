RegisterCommand("multijob", function()
    OpenMultiJob()
end)

if Config.Framework == "qb" then
    RegisterCommand("opengangmenu", function()
        exports["snipe-multijob"]:OpenGangMenu()
    end)
end


RegisterKeyMapping('multijob', "Open Multi Job Menu", "keyboard", "J")

TriggerEvent('chat:removeSuggestion', '/multijob')
