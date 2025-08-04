fx_version 'cerulean'
game 'gta5'

description 'Snipe Multijob System'
version '1.3.0'
author 'Snipe'

lua54 'yes'

ui_page 'html/index.html'

files {
	'html/**/*',
}

shared_scripts{
    '@ox_lib/init.lua',
    'shared/**/*.lua'
}

client_scripts{
    'client/**/*.lua',
} 

server_scripts{
    '@oxmysql/lib/MySQL.lua',
    'server/**/*.lua',
}

escrow_ignore{
    'client/open/*',
    'server/open/*',
    'shared/**/*'
}

dependency '/assetpacks'