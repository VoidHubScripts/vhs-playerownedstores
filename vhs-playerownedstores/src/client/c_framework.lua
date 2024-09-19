
function getIdentifier()
    if Framework == 'esx' then
        local playerData = ESX.GetPlayerData()
        if playerData then
            return playerData.identifier
        end
    elseif Framework == 'qbcore' then
        local playerData = QBCore.Functions.GetPlayerData()
        return playerData.citizenid
    end
end

function ItemLabel(item)
    local label = lib.callback.await('vhs-framework:itemLabel', false, item)
    if label then
        return label
    end
end

function getJob(source)
    if Framework == 'esx' then
        local playerData = ESX.GetPlayerData()
        if playerData then
            return playerData.job.name, playerData.job.grade, playerData.job.grade_label
        end
    elseif Framework == 'qbcore' then
        local playerData = QBCore.Functions.GetPlayerData()
        if playerData then
            return playerData.job.name, playerData.job.grade.level, playerData.job.grade.name
        end
    else
        return 'unemployed', 'unemployed', 0
    end
    return 'unemployed', 'unemployed', 0
end

function removeTarget(name)
    if Framework == 'esx' then
        exports.ox_target:removeGlobalPed(name)
    elseif Framework == 'qbcore' then
        exports['qb-target']:RemoveGlobalPed(name)
    end
end

function targetModel(model, name, options, interact, job, gang, distance)
    local targetOptions = {}
    for _, opt in ipairs(options) do
        table.insert(targetOptions, { name = name, icon = opt.icon, label = opt.label, event = opt.event, items = opt.item, groups = job,
            canInteract = function(entity, dist, coords, name, bone)
                local result = type(interact) == "function" and interact(entity, dist, coords, name, bone)
                if opt.canInteract then
                    return result and opt.canInteract(entity, dist, coords, name, bone)
                end
                return result
            end,
            onSelect = function(data)
                if type(opt.action) == "function" then
                    opt.action(data)
                end
        end })
    end
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addModel(model, targetOptions)
    elseif GetResourceState('qb-target') == 'started' then
        local qbOptions = { options = {}, distance = distance }
        for _, opt in ipairs(options) do
            table.insert(qbOptions.options, { event = opt.event, icon = opt.icon, label = opt.label, item = opt.item, job = job, gang = gang,
                action = function(entity)
                    if type(opt.action) == "function" then
                        opt.action(entity)
                    end
                end,
                canInteract = function(entity, dist, data)
                    local result = type(interact) == "function" and interact(entity, dist, data)
                    if opt.canInteract then
                        return result and opt.canInteract(entity, dist, data)
                    end
                    return result
                end
            })
        end
        exports['qb-target']:AddTargetModel(model, qbOptions)
    else
        print('Neither ox_target nor qb-target is started.')
    end
end


