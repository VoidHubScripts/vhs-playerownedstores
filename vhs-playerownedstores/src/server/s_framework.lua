-- = [ Inventory Bridge ] = -- 

function addItem(source, item, amount)
    if Framework == 'esx' then 
        local Player = ESX.GetPlayerFromId(source)
        if Player.canCarryItem(item, amount) then 
            Player.addInventoryItem(item, amount)
            return true
        else
            return false
        end
    elseif GetResourceState('ox_inventory') == 'started' then
        if exports.ox_inventory:CanCarryItem(source, item, amount) then
            local success, response = exports.ox_inventory:AddItem(source, item, amount)
            if success then
                return true
            else
                print(response) 
                return false
            end
        else
            return false
        end
    elseif Framework == 'qbcore' then 
        local added = exports['qb-inventory']:AddItem(source, item, amount)
        return added ~= nil 
    end 
    return false
end

function removeItem(source, item, amount)
    if Framework == 'esx' then 
        local Player = ESX.GetPlayerFromId(source)
        if Player then        
            if Player.getInventoryItem(item).count >= amount then
                Player.removeInventoryItem(item, amount)
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
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.RemoveItem(item, amount)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove', amount)
                return true
            else
            return false
        end 
    end 
end

function getInventory(source)
    local inv = {}
    local aggregatedItems = {} 

    if Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then
            local inventory = Player.getInventory()
            for _, item in pairs(inventory) do
                if item.name and item.label and item.count then
                    if aggregatedItems[item.name] then
                        aggregatedItems[item.name].count = aggregatedItems[item.name].count + item.count
                    else
                        aggregatedItems[item.name] = { name = item.name, label = item.label, count = item.count }
                    end
                end
            end
        end
    elseif GetResourceState('ox_inventory') == 'started' then
        local inventory = exports.ox_inventory:GetInventoryItems(source)
        for _, item in pairs(inventory) do
            if item.name and item.label and item.count then
                if aggregatedItems[item.name] then
                    aggregatedItems[item.name].count = aggregatedItems[item.name].count + item.count
                else
                    aggregatedItems[item.name] = { name = item.name, label = item.label, count = item.count }
                end
            end
        end
    elseif Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            local inventory = exports['qb-inventory']:LoadInventory(source, Player.PlayerData.citizenid)
            for _, item in pairs(inventory) do
                if item.name and item.label and item.amount then
                    if aggregatedItems[item.name] then
                        aggregatedItems[item.name].count = aggregatedItems[item.name].count + item.amount
                    else
                        aggregatedItems[item.name] = { name = item.name, label = item.label, count = item.amount }
                    end
                end
            end
        end
    end

    for _, item in pairs(aggregatedItems) do
        table.insert(inv, item)
    end

    return inv
end

function getItem(source, item)
    if Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then
            local esxItem = Player.getInventoryItem(item)
            if esxItem and esxItem.count > 0 then
                return { count = esxItem.count, label = esxItem.label }
            end
        end
    elseif GetResourceState('ox_inventory') == 'started' then
        local OxItem = exports.ox_inventory:GetItem(source, item)
        return { count = OxItem.count, label = OxItem.label }
    elseif Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
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
        local Player = ESX.GetPlayerFromId(source)
        if Player then
            return Player.getMoney()
        end
    elseif Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.money.cash
        end
    end
    return 0
end

function removeMoney(source, amount)
    if Framework == 'esx' then 
        local Player = ESX.GetPlayerFromId(source)
        if Player then 
            Player.removeMoney(amount)
        end 
    elseif Framework == 'qbcore' then 
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then 
            Player.Functions.RemoveMoney('cash', amount)
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

function addMoney(identifier, amount, source, store)
    if Framework == 'esx' then
        local player = ESX.GetPlayerFromIdentifier(identifier)
        if player then
            player.addAccountMoney('bank', amount)
            Notify('info', 'Payment Received ', store.. ' payment of $'.. amount, source) 
        else
            MySQL.Async.execute('UPDATE users SET bank = bank + @amount WHERE identifier = @identifier', {['@amount'] = amount,['@identifier'] = identifier})
        end
    elseif Framework == 'qbcore' then
        local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
        if player then
            player.Functions.AddMoney('bank', amount)
            Notify('info', 'Payment Received ', store.. ' payment of $'.. amount, source) 
        else
            MySQL.Async.execute('UPDATE players SET money = JSON_SET(money, "$.bank", JSON_EXTRACT(money, "$.bank") + @amount) WHERE citizenid = @identifier', { ['@amount'] = amount, ['@identifier'] = identifier })
        end
    end
end

-- = [ Other Bridges ] = -- 

function getName(source)
    if Framework == 'esx' then 
        local Player = ESX.GetPlayerFromId(source)
        return Player.getName()
    elseif Framework == 'qbcore' then 
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        end
    end 
end


