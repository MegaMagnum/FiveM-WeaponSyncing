fx_version 'cerulean'

game 'gta5'

lua54 'yes'

author 'MegaMagnum#7570'

ui_page 'notification/ui/ui.html'
files {
    'notification/ui/app.js',
    'notification/ui/ui.html',
    'notification/ui/popupsound.mp3',
    'notification/ui/styles/app.css'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config/*.lua', 
    'server/*.lua',
}

client_scripts {
    'client/*.lua',
    'config/*.lua', 
}

client_script "@GroningenACleiding/Anti-injectie.lua"
