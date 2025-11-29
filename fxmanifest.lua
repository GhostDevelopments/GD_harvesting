fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Ghost Developments'
description 'Standalone harvesting | ox_lib + ox_inventory |'
version '2.0'

shared_script '@ox_lib/init.lua'
shared_scripts { 'config.lua' }

client_scripts { 'client.lua' }
server_scripts { 'server.lua' }

dependencies { 'ox_lib', 'ox_inventory' }