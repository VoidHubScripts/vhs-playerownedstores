if Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() else QBCore = exports['qb-core']:GetCoreObject() end


Notify = function(type, title, text, targetClient)
    local types = { info = "inform", error = "error", success = "success" }
    if not types[type] then return end  

    if Notifications == "ox_lib" then
        if IsDuplicityVersion() then
                TriggerClientEvent('ox_lib:notify', targetClient, { type = types[type],  title = title, position = 'center-right', description = text })
        else 
            lib.notify({ title = title, description = text, position = 'center-right', type = types[type]})
    end 
    elseif Notifications == "esx" then
        if IsDuplicityVersion() then
            TriggerClientEvent('esx:showNotification', targetClient, text)
        else
            ESX.ShowNotification(text)
        end
    elseif Notifications == "qbcore" then
        local types = {info = "primary", error = "error", success = "success"}
        if types[type] then
            if IsDuplicityVersion() then
                TriggerClientEvent('QBCore:Notify', targetClient, text, types[type])
            else
                QBCore.Functions.Notify(text, types[type])
            end
        end
    elseif Notifications == "custom" then
            
        else

    end
end


ProgressBar = function(duration, label)
    if Progress == "ox_lib_circle" then
        return 
        lib.progressCircle({ duration = duration, position = 'bottom', allowFalling = true, label = label, useWhileDead = false, canCancel = true, disable = { move = true, car = true, combat = false, } })
    elseif Progress == "ox_lib_bar" then
        return 
        lib.progressBar({ duration = duration, label = label, useWhileDead = false, canCancel = true, disable = { move = false, car = true, combat = false, } })
    elseif Progress == "custom" then
        exports['progressBars']:startUI(duration, label)
    end
end