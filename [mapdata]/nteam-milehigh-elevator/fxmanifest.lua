fx_version 'cerulean'
games { 'gta5' }

lua54 'yes'

shared_script {
  '@ox_lib/init.lua',
}

client_scripts {
	'client/cl_*.lua',
}

escrow_ignore {
	'client/cl_editable.lua',
}

dependency '/assetpacks'
dependency '/assetpacks'