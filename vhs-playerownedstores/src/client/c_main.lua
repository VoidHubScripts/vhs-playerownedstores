if Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() else QBCore = exports['qb-core']:GetCoreObject() end

local spawnedPeds = {}

Citizen.CreateThread(function()
    Peds()
    Blips()
    targetStores()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    for _, peds in ipairs(spawnedPeds) do
        if DoesEntityExist(peds) then
            DeleteEntity(peds)
        end
    end
end)
  
if Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
        ESX.PlayerData = xPlayer
        Blips()
    end)
elseif Framework == 'qbcore' then
    local PlayerData = {}
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
        Blips()
    end)
end

function Peds()
    for k, v in pairs(Stores) do
        local peds = v.peds
        lib.requestModel(peds.model, 10000)
        local npc = CreatePed(4, peds.model, peds.location.x, peds.location.y, peds.location.z, peds.location.w, false, true)
        TaskStartScenarioInPlace(npc, peds.scenario, 0, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        table.insert(spawnedPeds, npc)
    end
end

function Blips()
    for k, v in pairs(Stores) do
        local location = v.peds.location
        local blipz = v.blips
        if blipz.useBlip then
            local blip = AddBlipForCoord(location.x, location.y, location.z)
            SetBlipSprite(blip, blipz.sprite)
            SetBlipDisplay(blip, 4) 
            SetBlipScale(blip, blipz.scale)
            SetBlipColour(blip, blipz.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipz.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end

function targetStores()
    for k, v in pairs(Stores) do
        local pedLocation = v.peds.location
        local rJob = v.manageJob.job
        local rGrade = v.manageJob.grade
        local storeOptions = {
            { icon = targetOptions.targetIcon, label = targetOptions.targetLabel, event = nil,
                action = function()
                    OpenStore(k)
                end,
                canInteract = function()
                    return true
                end
            },
            { icon = targetOptions.targetIcon1, label = targetOptions.targetLabel1, event = nil,
                action = function()
                    manageStore(k)
                end,
                canInteract = function()
                    if not v.manageJob.usePlayer then 
                        local jName, jGrade, jLabel = getJob()  
                        if jName == rJob and jGrade >= rGrade then
                            return true  
                        else
                            return false   
                        end
                    elseif v.manageJob.usePlayer then
                        local id = getIdentifier()
                        if id == v.manageJob.identifier then 
                            return true 
                        else 
                            return false 
                        end
                    end
                end 
            }
        }
        targetModel(v.peds.model, k, storeOptions, 
            function(entity)
                local pCoords = GetEntityCoords(PlayerPedId())
                local sCoords = vector3(pedLocation.x, pedLocation.y, pedLocation.z)
                local disNPC = Vdist2(pCoords, sCoords)
                local maxD = 3.0^2
                local dist = disNPC <= maxD
                return dist
            end, 
        nil, nil, 3.0)  
    end
end

function addStock(name)
    local inv = lib.callback.await('vhs-stores:getInv', false)
    if inv then 
        local menuOptions = {}
        for _, item in ipairs(inv) do
            table.insert(menuOptions, { title = item.label.. ' - ('.. item.count..'x)', icon = InventoryImagePath .. string.lower(item.name) .. ".png",  args = { store = name, item = string.lower(item.name), label = item.name, amount = item.count },
            onSelect = function()
                local input = lib.inputDialog('Add ' .. item.label .. ' as Product', { {type = 'number', label = 'Price', description = 'Set the price of stock', required = true, min = 1}, {type = 'slider', label = 'Stock Amount', description = 'Set the amount of stock', icon = 'hashtag', min = 1, max = item.count, required = true,} })
                if not input then 
                    return 
                end 
                local setup = lib.callback.await('vhs-store:setItem', false, input[1], input[2], string.lower(item.name), name)
            end
         })
        end
        lib.registerContext({ id = 'sstore_'.. name, title = '➕ Select Item to Setup', options = menuOptions })
        lib.showContext('sstore_'.. name)
    end 
end

function editProduct(name)
    local data = lib.callback.await('vhs-stores:getdata', false, name)
    local storeConfig = Stores[name]
    if storeConfig and data then
        local menuOptions = {}
        for item, data in pairs(data.items) do
            table.insert(menuOptions, { title = ItemLabel(item).. ' - $'.. data.price, description = 'Stock Avaliable - ('.. data.amount.. 'x)', icon = InventoryImagePath .. item .. ".png", args = { price = data.price, item = item, amount = data.amount },
            onSelect = function()
                local pItem = lib.callback.await('vhs-stores:getItem', false, item)
                local input = lib.inputDialog('Edit Product Listing: ' .. ItemLabel(item), {
                    { type = 'number', label = 'Manage Price - [ Price: '..data.price.. ' ]', icon = 'dollar', min = 1 },
                    { type = 'slider', label = 'Increase Stock - [ Stock: '..data.amount.. ' ]', min = 0, max = pItem.count },
                    { type = 'slider', label = 'Remove Stock - [ Stock: '..data.amount.. ' ]',  min = 0, max = data.amount },
                })
                if input then 
                    local newPrice = input[1]
                    local addStock = input[2]
                    local removeStock = input[3]
                    if addStock > 0 and removeStock > 0 then
                        Notify("error", "Invalid Input", "You can't add & remove stock at the same time.")
                        return
                    end
                    local edit = lib.callback.await('vhs-store:editProduct', false, name, item, newPrice, addStock, removeStock)
                else 
                    return
                end 
            end,
        })
        end
        lib.registerContext({ id = 'estore_'.. name, title = 'Edit Products - '.. storeConfig.menu.title, options = menuOptions })
        lib.showContext('estore_'.. name)
    else
        lib.registerContext({ id = 'estore_'.. name, title = storeConfig.menu.title, options = {{title = 'No Items Available' }} })
        lib.showContext('estore_'.. name)
    end
end

function manageStore(name)
    local storeConfig = Stores[name]
    lib.registerContext({
        id = 'mstore_'.. name,
        title = storeConfig.menu.title,
        options = {
            {
                title = '📦 Add New Product', 
                description = 'Add a new item to the store',
                onSelect = function()
                    addStock(name)
                end,
            }, 
            {
                title = '📋 Edit Product', 
                description = 'Edit a specific product in the store',
                onSelect = function()
                    editProduct(name)
                end,
            },
        }
    })
    lib.showContext('mstore_'.. name)
end 

function OpenStore(name)
    local data = lib.callback.await('vhs-stores:getdata', false, name)
    local storeConfig = Stores[name]
    if storeConfig and data then
        TriggerEvent('vhs-stores:open', name, storeConfig, data, true)
    else
        TriggerEvent('vhs-stores:open', name, storeConfig, data, false)
    end
end

RegisterNetEvent('vhs-stores:open')
AddEventHandler('vhs-stores:open', function(name, config, data, hasItems)
    if hasItems then
        local menuOptions = {}
        for item, data in pairs(data.items) do
            table.insert(menuOptions, { title = ItemLabel(item).. ' - $'.. data.price, description = 'Stock Avaliable - ('.. data.amount.. 'x)', icon = InventoryImagePath .. item .. ".png", args = { price = data.price, item = item, amount = data.amount },
            onSelect = function()
                local input = lib.inputDialog('Purchase ' .. ItemLabel(item), { {type = 'number', description = 'Amount to purchase', icon = 'hashtag', min = 1, max = data.amount, required = true} })
                if not input then 
                    return 
                end 
                local buy = lib.callback.await('vhs-store:buyItem', false, name, item, data.price, input[1])
            end,
        })
        end
        lib.registerContext({ id = 'store_'.. name, title = config.menu.title, options = menuOptions })
        lib.showContext('store_'.. name)
    else
        lib.registerContext({ id = 'store_'.. name, title = config.menu.title, options = {{ title = 'No Items Available' }}})
        lib.showContext('store_'.. name)
    end
end)
 
