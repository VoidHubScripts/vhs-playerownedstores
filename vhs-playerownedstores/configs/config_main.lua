Config = Config or {}

Framework = 'qbcore' -- esx, qbcore 
Notifications = 'ox_lib'  -- qbcore, esx, ox_lib
Progress = 'ox_lib_circle' 
InventoryImagePath = "nui://ox_inventory/web/images/"

targetOptions = {
    targetIcon = '', 
    targetLabel = 'Open Store', 
    targetIcon1 = '', 
    targetLabel1 = 'Manage Store', 
}

Stores = {
    lsc = { 
        blips = { useBlip = true, sprite = 24, scale = 0.8, color = 3, label = 'Mechanic Store' }, 
        peds = { location = vec4(-368.4481, -101.0956, 38.5430, 163.5545), model = 'a_m_m_prolhost_01', scenario = 'WORLD_HUMAN_CLIPBOARD_FACILITY' }, 
        manageJob = { job = 'mechanic', grade = 2, usePlayer = false, identifier = 'HZT7I7DR'  --[[ citizen id or esx identifier ]] },
        menu = { title = '🧰 **LSC Store**' },
        allowedItems = {
            useAllowed = true, 
            list = {
                "repairkit", 
                "nitrous", 
                "harness", 
            } 
        }, 
    }, 
    --[[ 
    otherstore = { 
        blips = { useBlip = true, sprite = 24, scale = 0.8, color = 3, label = 'Other Store' }, 
        peds = { location = vec4(-372.2540, -117.0190, 38.6961, 345.1687), model = 'g_m_m_armlieut_01', scenario = 'WORLD_HUMAN_CLIPBOARD_FACILITY' }, 
        manageJob = { job = 'police', grade = 2 },
        menu = { title = '**Other Store**' },
    }, 
    ]]
}

