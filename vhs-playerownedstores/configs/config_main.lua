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
                "trowel", 
             
            } 
        }, 
    }, 
    weaponStore = { 
        blips = { useBlip = true, sprite = 59, scale = 0.8, color = 69, label = 'Weapons Store' }, 
        peds = { location = vec4(22.7322, -1105.5125, 28.7970, 158.4887), model = 'a_m_m_prolhost_01', scenario = 'WORLD_HUMAN_CLIPBOARD_FACILITY' }, 
        manageJob = { job = 'mechanic', grade = 2, usePlayer = true, identifier = 'P4D531MU'  --[[ citizen id or esx identifier ]] },
        menu = { title = '**Class A - Weapons Store**' },
        allowedItems = {
            useAllowed = true, 
            list = {
                'at_suppressor_light', 
                'at_clip_extended_pistol', 
                "weapon_pistol", 
                "weapon_knife", 
                "ammo-9", 
            } 
        }, 
    }, 
    
}

