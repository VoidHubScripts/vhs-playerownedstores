fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'vhs-playerownedstores'
version '0.1'

client_scripts {
    'configs/config_main.lua',
    'src/client/c_framework.lua',
    'src/client/c_main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'src/server/s_framework.lua',
    'configs/sv_webhook.lua',
    'src/server/s_main.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'configs/config_main.lua',
    'configs/utils.lua',
}
