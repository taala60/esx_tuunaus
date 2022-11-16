local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX =					nil
local Vehicles =		{}
local PlayerData		= {}
local lsMenuIsShowed	= false
local isInLSMarker		= false
local myCar				= {}
local currentZone = nil
local zone 		  = nil
local lastZone    = nil
local _vehicle = nil
local vcoords = nil
local coords = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	ESX.TriggerServerCallback('esx_tuunaus:getVehiclesPrices', function(vehicles)
		Vehicles = vehicles
	end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_tuunaus:installMod')
AddEventHandler('esx_tuunaus:installMod', function()
    if _vehicle and source then
        myCar = ESX.Game.GetVehicleProperties(_vehicle)
        TriggerServerEvent('esx_tuunaus:refreshOwnedVehicle', myCar)
        StartVehicleHorn(_vehicle, 100, 1, false)
        SetVehicleLights(_vehicle, 2)
        Wait (200)
        SetVehicleLights(_vehicle, 0)
        StartVehicleHorn(_vehicle, 100, 1, false)
        Wait (200)
        SetVehicleLights(_vehicle, 1)
        Wait (400)
        SetVehicleLights(_vehicle, 2)
    else
        ESX.ShowNotification("TUUNAUS ERROR: IMvf")
    end
end)

RegisterNetEvent('esx_tuunaus:cancelInstallMod')
AddEventHandler('esx_tuunaus:cancelInstallMod', function()
	if _vehicle then
		ESX.Game.SetVehicleProperties(_vehicle, myCar)
	else
		ESX.ShowNotification("TUUNAUS ERROR: CIMvf")
	end
end)

function OpenLSMenu(elems, menuName, menuTitle, parent)
	Citizen.Wait(100)
	if _vehicle then
			
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), menuName,
		{
			title    = menuTitle,
			align    = 'top-right',
			elements = elems
		}, function(data, menu)
			local isRimMod, found = false, false
			local price = 0
			if data.current.modType == "modFrontWheels" then
				isRimMod = true
			end

			for k,v in pairs(Config.Menus) do

				if k == data.current.modType or isRimMod then

					if data.current.label == _U('by_default') or string.match(data.current.label, _U('installed')) then
						ESX.ShowNotification(_U('already_own', data.current.label))
						TriggerEvent('esx_tuunaus:installMod', _vehicle)
					else
						local vehiclePrice = 100
						local Ddata = {
							msg1 = 'Tuunaus',
							msg2 = GetPlayerName(PlayerId()),
							msg3 = " tuunasi ajoneuvoa ",
							msg4 = GetVehicleNumberPlateText(_vehicle),
							msg5 = " hintaan €",
							msg6 = 0,
							msg7 = " Modi: " .. k
						}
						for i=1, #Vehicles, 1 do
							if GetEntityModel(_vehicle) == GetHashKey(Vehicles[i].model) then
								vehiclePrice = Vehicles[i].price
								break
							end
						end
						if isRimMod then
							price = math.floor((vehiclePrice * data.current.price) / 140)
							TriggerServerEvent("esx_tuunaus:buyMod", price)
							Ddata.msg6 = tonumber(math.floor(vehiclePrice * data.current.price / 140))
						elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 or v.modType == 16 then
							price = math.floor((vehiclePrice * v.price[data.current.modNum + 1]) / 140)
							TriggerServerEvent("esx_tuunaus:buyMod", price)
							Ddata.msg6 = tonumber(math.floor(vehiclePrice * v.price[data.current.modNum + 1] / 140))
						elseif v.modType == 17 then
							price = math.floor((vehiclePrice * v.price[1]) / 140)
							TriggerServerEvent("esx_tuunaus:buyMod", price)
							Ddata.msg6 = tonumber(math.floor(vehiclePrice * v.price[1] / 140))
						else
							price = math.floor((vehiclePrice * v.price) / 140)
							TriggerServerEvent("esx_tuunaus:buyMod", price)
							Ddata.msg6 = tonumber(math.floor(vehiclePrice * v.price / 140))
						end
							TriggerServerEvent('discord:lscustom', Ddata)
					end

					menu.close()
					found = true
					break
				end

			end

			if not found then
				GetAction(data.current)
			end
		end, function(data, menu) -- on cancel
			menu.close()
			TriggerEvent('esx_tuunaus:cancelInstallMod')

			local playerPed = PlayerPedId()
			--local vehicle = GetVehiclePedIsIn(playerPed, false)
			--local vehicle = ESX.Game.GetClosestVehicle(coords)
			SetVehicleDoorsShut(_vehicle, false)

			if parent == nil then
				lsMenuIsShowed = false
				coords = nil
				vcoords = nil
				FreezeEntityPosition(_vehicle, false)
				SetVehicleLights(_vehicle, 0)
				myCar = {}
			end
		end, function(data, menu) -- on change
			UpdateMods(data.current)
		end)
	else
		ESX.ShowNotification("TUUNAUS ERROR: OLSMvf")
	end
end

function UpdateMods(data)
	--local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	if _vehicle then
		if data.modType ~= nil then
			local props = {}
			
			if data.wheelType ~= nil then
				props['wheels'] = data.wheelType
				ESX.Game.SetVehicleProperties(_vehicle, props)
				props = {}
			elseif data.modType == 'neonColor' then
				if data.modNum[1] == 0 and data.modNum[2] == 0 and data.modNum[3] == 0 then
					props['neonEnabled'] = { false, false, false, false }
				else
					props['neonEnabled'] = { true, true, true, true }
				end
				ESX.Game.SetVehicleProperties(_vehicle, props)
				props = {}
			elseif data.modType == 'tyreSmokeColor' then
				props['modSmokeEnabled'] = true
				ESX.Game.SetVehicleProperties(_vehicle, props)
				props = {}
			end

			props[data.modType] = data.modNum
			ESX.Game.SetVehicleProperties(_vehicle, props)
		end
	else
		ESX.ShowNotification("TUUNAUS ERROR: UMv")
	end
end

function GetAction(data)
	local elements  = {}
	local menuName  = ''
	local menuTitle = ''
	local parent    = nil
	local playerPed = PlayerPedId()
	local currentMods = ESX.Game.GetVehicleProperties(_vehicle)

	if data.value == 'modSpeakers' or
		data.value == 'modTrunk' or
		data.value == 'modHydrolic' or
		data.value == 'modEngineBlock' or
		data.value == 'modAirFilter' or
		data.value == 'modStruts' or
		data.value == 'modTank' then
		SetVehicleDoorOpen(_vehicle, 4, false)
		SetVehicleDoorOpen(_vehicle, 5, false)
	elseif data.value == 'modDoorSpeaker' then
		SetVehicleDoorOpen(_vehicle, 0, false)
		SetVehicleDoorOpen(_vehicle, 1, false)
		SetVehicleDoorOpen(_vehicle, 2, false)
		SetVehicleDoorOpen(_vehicle, 3, false)
	else
		SetVehicleDoorsShut(_vehicle, false)
	end

	local vehiclePrice = 10

	for i=1, #Vehicles, 1 do
		if GetEntityModel(_vehicle) == GetHashKey(Vehicles[i].model) then
			vehiclePrice = Vehicles[i].price
			break
		end
	end

	for k,v in pairs(Config.Menus) do

		if data.value == k then

			menuName  = k
			menuTitle = v.label
			parent    = v.parent

			if v.modType ~= nil then
				
				if v.modType == 22 then
					table.insert(elements, {label = " " .. _U('by_default'), modType = k, modNum = false})
				elseif v.modType == 'neonColor' or v.modType == 'tyreSmokeColor' then -- disable neon
					table.insert(elements, {label = " " ..  _U('by_default'), modType = k, modNum = {0, 0, 0}})
				elseif v.modType == 'color1' or v.modType == 'color2' or v.modType == 'pearlescentColor' or v.modType == 'wheelColor' then
					local num = myCar[v.modType]
					table.insert(elements, {label = " " .. _U('by_default'), modType = k, modNum = num})
				elseif v.modType == 17 then
					table.insert(elements, {label = " " .. _U('no_turbo'), modType = k, modNum = false})
 				else
					table.insert(elements, {label = " " .. _U('by_default'), modType = k, modNum = -1})
				end

				if v.modType == 14 then -- HORNS
					for j = 0, 51, 1 do
						local _label = ''
						if j == currentMods.modHorns then
							_label = GetHornName(j) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = math.floor((vehiclePrice * v.price) / 140)
							_label = GetHornName(j) .. ' - <span style="color:green;">€' .. price .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
					end
				elseif v.modType == 'plateIndex' then -- PLATES
					for j = 0, 4, 1 do
						local _label = ''
						if j == currentMods.plateIndex then
							_label = GetPlatesName(j) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = math.floor((vehiclePrice * v.price) / 140)
							_label = GetPlatesName(j) .. ' - <span style="color:green;">€' .. price .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
					end
				elseif v.modType == 22 then -- NEON
					local _label = ''
					if currentMods.modXenon then
						_label = _U('neon') .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
					else
						price = math.floor((vehiclePrice * v.price) / 140)
						_label = _U('neon') .. ' - <span style="color:green;">€' .. price .. ' </span>'
					end
					table.insert(elements, {label = _label, modType = k, modNum = true})
				elseif v.modType == 'neonColor' or v.modType == 'tyreSmokeColor' then -- NEON & SMOKE COLOR
					local neons = GetNeons()
					price = math.floor((vehiclePrice * v.price) / 140)
					for i=1, #neons, 1 do
						table.insert(elements, {
							label = '<span style="color:rgb(' .. neons[i].r .. ',' .. neons[i].g .. ',' .. neons[i].b .. ');">' .. neons[i].label .. ' - <span style="color:green;">€' .. price .. '</span>',
							modType = k,
							modNum = { neons[i].r, neons[i].g, neons[i].b }
						})
					end
				elseif v.modType == 'color1' or v.modType == 'color2' or v.modType == 'pearlescentColor' or v.modType == 'wheelColor' then -- RESPRAYS
					local colors = GetColors(data.color)
					for j = 1, #colors, 1 do
						local _label = ''
						price = math.floor((vehiclePrice * v.price) / 140)
						_label = colors[j].label .. ' - <span style="color:green;">€' .. price .. ' </span>'
						table.insert(elements, {label = _label, modType = k, modNum = colors[j].index})
					end
				elseif v.modType == 'windowTint' then -- WINDOWS TINT
					for j = 1, 5, 1 do
						local _label = ''
						if j == currentMods.modHorns then
							_label = GetWindowName(j) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = math.floor((vehiclePrice * v.price) / 140)
							_label = GetWindowName(j) .. ' - <span style="color:green;">€' .. price .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
					end
				elseif v.modType == 23 then -- WHEELS RIM & TYPE
					local props = {}

					props['wheels'] = v.wheelType
					ESX.Game.SetVehicleProperties(_vehicle, props)

					local modCount = GetNumVehicleMods(_vehicle, v.modType)
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(_vehicle, v.modType, j)
						if modName ~= nil then
							local _label = ''
							if j == currentMods.modFrontWheels then
								_label = GetLabelText(modName) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
							else
								price = math.floor((vehiclePrice * v.price) / 140)
								_label = GetLabelText(modName) .. ' - <span style="color:green;">€' .. price .. ' </span>'
							end
							table.insert(elements, {label = _label, modType = 'modFrontWheels', modNum = j, wheelType = v.wheelType, price = v.price})
						end
					end
				elseif v.modType == 11 or v.modType == 12 or v.modType == 13 or v.modType == 15 or v.modType == 16 then
					local modCount = GetNumVehicleMods(_vehicle, v.modType) -- UPGRADES
					for j = 0, modCount, 1 do
						local _label = ''
						if j == currentMods[k] then
							_label = _U('level', j+1) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
						else
							price = tonumber(math.floor((vehiclePrice * v.price[j+1]) / 140))
							_label = _U('level', j+1) .. ' - <span style="color:green;">€' .. price .. ' </span>'
						end
						table.insert(elements, {label = _label, modType = k, modNum = j})
						if j == modCount-1 then
							break
						end
					end
				elseif v.modType == 17 then -- TURBO
					local _label = ''
					if currentMods[k] then
						_label = 'Turbo - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
					else
						_label = 'Turbo - <span style="color:green;">€' .. math.floor(vehiclePrice * v.price[1] / 140) .. ' </span>'
					end
					table.insert(elements, {label = _label, modType = k, modNum = true})
				else
					local modCount = GetNumVehicleMods(_vehicle, v.modType) -- BODYPARTS
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(_vehicle, v.modType, j)
						if modName ~= nil then
							local _label = ''
							if j == currentMods[k] then
								_label = GetLabelText(modName) .. ' - <span style="color:cornflowerblue;">'.. _U('installed') ..'</span>'
							else
								price = math.floor((vehiclePrice * v.price) / 140)
								_label = GetLabelText(modName) .. ' - <span style="color:green;">€' .. price .. ' </span>'
							end
							table.insert(elements, {label = _label, modType = k, modNum = j})
						end
					end
				end
			else
				if data.value == 'primaryRespray' or data.value == 'secondaryRespray' or data.value == 'pearlescentRespray' or data.value == 'modFrontWheelsColor' then
					for i=1, #Config.Colors, 1 do
						if data.value == 'primaryRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'color1', color = Config.Colors[i].value})
						elseif data.value == 'secondaryRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'color2', color = Config.Colors[i].value})
						elseif data.value == 'pearlescentRespray' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'pearlescentColor', color = Config.Colors[i].value})
						elseif data.value == 'modFrontWheelsColor' then
							table.insert(elements, {label = Config.Colors[i].label, value = 'wheelColor', color = Config.Colors[i].value})
						end
					end
				else
					for l,w in pairs(v) do
						if l ~= 'label' and l ~= 'parent' then
							table.insert(elements, {label = w, value = l})
						end
					end
				end
			end
			break
		end
	end

	table.sort(elements, function(a, b)
		return a.label < b.label
	end)

	OpenLSMenu(elements, menuName, menuTitle, parent)
end

-- Blippi, jos et halua blippii niin pida toi viiva tos
--[[Citizen.CreateThread(function()
	for k,v in pairs(Config.Alue) do
		local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
		SetBlipSprite(blip, 72)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(v.Name)
		EndTextCommandSetBlipName(blip)
	end
end)]]

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	Citizen.Wait(5000)
	if #Vehicles == 0 then
		ESX.TriggerServerCallback('esx_tuunaus:getVehiclesPrices', function(vehicles)
			Vehicles = vehicles
		end)
	end
	while true do
		Citizen.Wait(1)
		if not lsMenuIsShowed then
			local kaikistKaukan = true
			local playerPed = PlayerPedId()		
			if (PlayerData.job ~= nil and PlayerData.job.name == 'mechanic' and PlayerData.job.grade_name ~= 'recrue') or Config.IsMechanicJobOnly == false then
				coords      = GetEntityCoords(PlayerPedId())
				for k,v in pairs(Config.Alue) do
					if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x then
						isInLSMarker  = true
						ESX.ShowHelpNotification(v.Hint)
						kaikistKaukan = false
						break
					else
						isInLSMarker  = false
					end
				end
				if (not isInLSMarker and kaikistKaukan) then
					Citizen.Wait(3000)
				else
					if IsControlJustReleased(0, Keys['E']) and not lsMenuIsShowed and isInLSMarker then
						_vehicle = nil
						local vehicle = ESX.Game.GetClosestVehicle(coords)
						vcoords = GetEntityCoords(vehicle)
						if GetDistanceBetweenCoords(coords, vcoords) < 5 then
							lsMenuIsShowed = true

							FreezeEntityPosition(vehicle, true)

							myCar = ESX.Game.GetVehicleProperties(vehicle)
                                                        exports['mythic_notify']:SendAlert('inform', 'Tuunataan ajoneuvoa!')
							_vehicle = vehicle
							SetVehicleLights(_vehicle, 2)
							ESX.UI.Menu.CloseAll()
							GetAction({value = 'main'})
							Citizen.Wait(1000)
						else
                                                        exports['mythic_notify']:SendAlert('inform', 'Ei lähettyvillä ajoneuvoja')
						end
					end
				end
				if isInLSMarker and not hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = true
				end

				if not isInLSMarker and hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = false
				end
			else
				Citizen.Wait(10000)
			end
		elseif vcoords and coords and GetDistanceBetweenCoords(coords, vcoords) > 7 then
			isInLSMarker = false
			lsMenuIsShowed = false
			ESX.UI.Menu.CloseAll()
			FreezeEntityPosition(_vehicle, false)
			SetVehicleLights(_vehicle, 0)
			myCar = {}
			ESX.ShowNotification("menu resetoitu")			
		else
			coords      = GetEntityCoords(PlayerPedId())
			Citizen.Wait(1000)
		end
	end
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if lsMenuIsShowed then
			DisableControlAction(2, Keys['F1'], true)
			DisableControlAction(2, Keys['F2'], true)
			DisableControlAction(2, Keys['F3'], true)
			DisableControlAction(2, Keys['F4'], true)
			DisableControlAction(2, Keys['F5'], true)
			DisableControlAction(2, Keys['F6'], true)
			DisableControlAction(2, Keys['F7'], true)
			--DisableControlAction(2, Keys['F'], true)
			--DisableControlAction(0, 75, true)  -- Disable exit vehicle
			--DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)