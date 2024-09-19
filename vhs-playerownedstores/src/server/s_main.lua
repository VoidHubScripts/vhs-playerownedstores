if Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() else QBCore = exports['qb-core']:GetCoreObject() end

local versionCheck = function()
	local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
	local latestReleaseUrl = 'https://api.github.com/repos/VoidHubScripts/vhs-playerownedstores/releases/latest'

	PerformHttpRequest(latestReleaseUrl, function(statusCode, resultData, headers)
		if statusCode == 200 then
			local releaseData   = json.decode(resultData)
			local latestVersion = releaseData.tag_name

			if currentVersion ~= latestVersion then
                print("^5Support Discord: ^5^0https://discord.gg/CBSSMpmqrK - ^5Site^5: ^0VoidHubScripts.com\n".."^0"..GetCurrentResourceName()..' | ^1Current Version: '..currentVersion.."\n^0"..GetCurrentResourceName()..' |^2 Updated Version: '..latestVersion.."")
			end
		end
	end, 'GET', headers)
end

if versionCheck then
    versionCheck()
end

function logDiscord(title, message, color) local data = { username = "vhs-playerstores",  avatar_url = "https://i.imgur.com/E2Z3mDO.png", embeds = { { ["color"] = color, ["title"] = title, ["description"] = message, ["footer"] = { ["text"] = "Installation Support - [ESX, QBCore, Qbox] -  https://discord.gg/CBSSMpmqrK" },} } } PerformHttpRequest(WebhookConfig.URL, function(err, text, headers) end, 'POST', json.encode(data), {['Content-Type'] = 'application/json'}) end

function editStock(store, item, newPrice, amount, increase)
    local src = source
    local sData = MySQL.query.await('SELECT store_data FROM vhs_playerstores WHERE store_id = ?', { store })
    if sData and sData[1] and sData[1].store_data then
        local data = json.decode(sData[1].store_data) or {}
        if data.items and data.items[item] then
            if newPrice ~= nil and newPrice > 0 then
                data.items[item].price = newPrice
            end
            if amount and amount > 0 then
                if increase then
                    data.items[item].amount = data.items[item].amount + amount
                    logDiscord('Stock Added', getName(src) .. ' added (' .. amount .. 'x) ' .. getLabel(item) .. ' to store ' .. store, 3066993) 
                else
                    data.items[item].amount = data.items[item].amount - amount
                    logDiscord('Stock Removed', getName(src) .. ' removed (' .. amount .. 'x) ' .. getLabel(item) .. ' from store ' .. store, 15158332) 
                    if data.items[item].amount <= 0 then
                        data.items[item] = nil
                    end
                end
            end
            local uData = json.encode(data)
            MySQL.query.await('UPDATE vhs_playerstores SET store_data = ? WHERE store_id = ?', { uData, store })
            return true
        else
            return false
        end
    else
        return false
    end
end

lib.callback.register('vhs-store:editProduct', function(source, store, item, newPrice, addStock, removeStock)
    if (newPrice ~= nil or (addStock and addStock > 0) or (removeStock and removeStock > 0)) then
        local amount = (addStock and addStock > 0) and addStock or removeStock
        local increase = (addStock and addStock > 0) 
        editStock(store, item, newPrice, amount, increase)
        if addStock and addStock > 0 then
            removeItem(source, item, addStock)
        elseif removeStock and removeStock > 0 then
            addItem(source, item, removeStock)
        end
    end
    return true
end)

lib.callback.register('vhs-stores:getdata', function(source, name)
    local data = MySQL.query.await('SELECT store_data FROM vhs_playerstores WHERE store_id = ?', {name})
    if data and data[1] then
        return json.decode(data[1].store_data)
    else
        return nil
    end
end)

lib.callback.register('vhs-store:buyItem', function(source, store, item, price, amount)
    local storeConfig = Stores[store]
    local price = amount * price 
    if getMoney(source) >= price then 
        removeMoney(source, price)
        if storeConfig.manageJob.usePlayer then 
            addMoney(storeConfig.manageJob.identifier, price)
        else 
            societyDeposit(storeConfig.manageJob.job, price)
        end 
        addItem(source, item, amount)
        editStock(store, item, nil, amount, false)
    else
        Notify('info', 'Cannot Afford', 'You need more moneys', source) 
    end
end)

lib.callback.register('vhs-stores:getInv', function(source)
    local inv = getInventory(source)
    return inv
end)

lib.callback.register('vhs-stores:getItem', function(source, item)
    local item = getItem(source, item)
    return item
end)

lib.callback.register('vhs-store:setItem', function(source, price, amount, name, store)
    local sData = MySQL.query.await('SELECT store_data FROM vhs_playerstores WHERE store_id = ?', { store })
    local storeData = Stores[store] 
    
    if storeData.allowedItems.useAllowed then
        local isAllowed = false
        for _, allowedItem in ipairs(storeData.allowedItems.list) do
            
            if string.lower(name) == string.lower(allowedItem) then
                isAllowed = true
                break
            end
        end
        if not isAllowed then
            Notify('error', 'Item Not Allowed', 'This item is not allowed to be added to this store.', source)
            return false
        end
    end
    if sData and sData[1] and sData[1].store_data then
        local data = json.decode(sData[1].store_data) or {}
        data.items = data.items or {}
        if data.items[name] then
            Notify('error', 'Item Exists', 'This item already exists in store. Edit the product instead.', source)
            return false
        else
            data.items[name] = { price = price, amount = amount }
            logDiscord('New Item Added', getName(source) .. ' added (' .. amount .. 'x) ' .. getLabel(name) .. ' to store ' .. store .. ' at a price of $' .. price, 3066993)
        end
        local uData = json.encode(data)
        MySQL.query('UPDATE vhs_playerstores SET store_data = ? WHERE store_id = ?', { uData, store })
        removeItem(source, name, amount)
        return true
    else
        local iData = { items = { [name] = { price = price, amount = amount } } }
        local dataJson = json.encode(iData)
        MySQL.query('INSERT INTO vhs_playerstores (store_id, store_data) VALUES (?, ?)', { store, dataJson })
        removeItem(source, name, amount)
        return true
    end
end)



