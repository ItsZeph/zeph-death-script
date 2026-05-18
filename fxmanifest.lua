fx_version 'cerulean'
game 'gta5'

name 'Death Script'
description 'Death script with respawn/revive UI and countdowns'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html'
}

dependency 'spawnmanager'
