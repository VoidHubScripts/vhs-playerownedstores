-- = [ Inventory Bridge ] = -- 

function addItem(source, item, amount)
    if Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.canCarryItem(item, amount) then 
            xPlayer.addInventoryItem(item, amount)
        end 
    elseif GetResourceState('ox_inventory') == 'started' then
        local success, response = exports.ox_inventory:AddItem(source, item, amount)
        if not success then
            return print(response)
        end   
    elseif Framework == 'qbcore' then 
        local added = exports['qb-inventory']:AddItem(source, item, amount)
    end 
end

function removeItem(source, item, amount)
    if Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then        
            if xPlayer.getInventoryItem(item).count >= amount then
                xPlayer.removeInventoryItem(item, amount)
                return true
            else
                return false
            end
        else 
            return false
        end 
    elseif GetResourceState('ox_inventory') == 'started' then
        local success = exports.ox_inventory:RemoveItem(source, item, amount)
    elseif Framework == 'qbcore' then 
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
                xPlayer.Functions.RemoveItem(item, amount)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove', amount)
                return true
            else
            return false
        end 
    end 
end

function getInventory(source)
    local inv = {}
    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local inventory = xPlayer.getInventory()
            for _, item in ipairs(inventory) do
                if item.name and item.label and item.count then
                    table.insert(inv, { name = item.name, label = item.label, count = item.count })
                end
            end
        end
    elseif GetResourceState('ox_inventory') == 'started' then
        local inventory = exports.ox_inventory:GetInventoryItems(source)  
        for _, item in pairs(inventory) do
            if item.name and item.label and item.count then
                table.insert(inv, { name = item.name, label = item.label, count = item.count })
            end
        end  
    elseif Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            local inventory = exports['qb-inventory']:LoadInventory(source, Player.PlayerData.citizenid)
            for _, item in pairs(inventory) do
                if item.name and item.label and item.amount then
                    table.insert(inv, { name = item.name, label = item.label, count = item.amount })
                end
            end
        end
    end
    return inv
end

function getItem(source, item)
    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local esxItem = xPlayer.getInventoryItem(item)
            if esxItem and esxItem.count > 0 then
                return { count = esxItem.count, label = esxItem.label }
            end
        end
    elseif GetResourceState('ox_inventory') == 'started' then
        local OxItem = exports.ox_inventory:GetItem(source, item)
        return { count = OxItem.count, label = OxItem.label }
    elseif Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            local qItem = exports['qb-inventory']:GetItemByName(source, item)
            if qItem and qItem.amount then
                return { count = qItem.amount, label = qItem.label }
            end
        end
    end
    return nil
end

function getLabel(item)
    if Framework == 'esx' then
        return ESX.GetItemLabel(item)
    elseif GetResourceState('ox_inventory') == 'started' then
        local Oxitem = exports.ox_inventory:Items(item)
        return Oxitem.label
    elseif Framework == 'qbcore' then
        if QBCore and QBCore.Shared and QBCore.Shared.Items[item] then
            return QBCore.Shared.Items[item].label
        else
            return item  
        end
    end
end

lib.callback.register('vhs-framework:itemLabel', function(source, item)
    return getLabel(item)
end)

-- = [ Moneys Bridge ] = --

function getMoney(source)
    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getMoney()
        end
    elseif Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            return xPlayer.PlayerData.money.cash
        end
    end
    return 0
end

function removeMoney(source, amount)
    if Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then 
            xPlayer.removeMoney(amount)
        end 
    elseif Framework == 'qbcore' then 
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then 
            xPlayer.Functions.RemoveMoney('cash', amount)
        end 
    end 
end 

function societyDeposit(society, amount)
    if Framework == 'esx' then 
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..society, function(account)
            account.addMoney(amount)
          end)
    elseif GetResourceState('qbx_core') == 'started' then    
        exports['Renewed-Banking']:addAccountMoney(society, amount)  
    elseif Framework == 'qbcore' then 
        exports['qb-banking']:AddMoney(society, amount, 'Store Payment')
    end 
end   

-- = [ Other Bridges ] = -- 

function getName(source)
    if Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getName()

    elseif Framework == 'qbcore' then 
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        end
    end 
end


