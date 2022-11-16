ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local Vehicles = nil

RegisterServerEvent('esx_tuunaus:buyMod')
AddEventHandler('esx_tuunaus:buyMod', function(price)
	local _vehicle = vehicle
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	price = tonumber(price)

	if Config.IsMechanicJobOnly then

		local societyAccount = nil
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			societyAccount = account
		end)
		--print(societyAccount.name .. " " .. societyAccount.money)
		if price < societyAccount.money then
			TriggerClientEvent('esx_tuunaus:installMod', _source)
                        TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = _U('purchased') })
			xPlayer.removeMoney(price)
		else
			TriggerClientEvent('esx_tuunaus:cancelInstallMod', _source)
                        TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = _U('not_enough_money') })
		end

	else

		if price < xPlayer.getMoney() then
			TriggerClientEvent('esx_tuunaus:installMod', _source)
                        TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = _U('purchased') })
			xPlayer.removeMoney(price)
		else
			TriggerClientEvent('esx_tuunaus:cancelInstallMod', _source)
                        TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = _U('not_enough_money') })

		end

	end
end)

RegisterServerEvent('esx_tuunaus:refreshOwnedVehicle')
AddEventHandler('esx_tuunaus:refreshOwnedVehicle', function(myCar)
	if source then
		MySQL.Async.execute('UPDATE `owned_vehicles` SET `vehicle` = @vehicle WHERE `plate` = @plate',
		{
			['@plate']   = myCar.plate,
			['@vehicle'] = json.encode(myCar)
		})
	end
end)

ESX.RegisterServerCallback('esx_tuunaus:getVehiclesPrices', function(source, cb)
	if Vehicles == nil then
		MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
			local vehicles = {}

			for i=1, #result, 1 do
				table.insert(vehicles, {
					model = result[i].model,
					price = result[i].price
				})
			end

			Vehicles = vehicles
			cb(Vehicles)
		end)
	else
		cb(Vehicles)
	end
end)