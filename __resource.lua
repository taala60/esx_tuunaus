resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'taala'

version '2.1.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/fi.lua',
	'locales/pl.lua',
	'locales/br.lua',
	'config.lua',
	'server/sv_main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/fi.lua',
	'locales/pl.lua',
	'locales/br.lua',
	'config.lua',
	'client/cl_main.lua'
}
