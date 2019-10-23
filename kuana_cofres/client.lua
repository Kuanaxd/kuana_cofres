ESX = nil
local Cofres = {}
local playerPedt
local PlayerData = {}



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerData = ESX.GetPlayerData()

	ESX.TriggerServerCallback('kuana:getCofres', function(data)
		for _,v in pairs(data) do
			local x = v.xx + 0.0
			local y = v.yy + 0.0
			local z = v.zz + 0.0

			local zz = z - 1
			local portaid = 0
			local corpoid = 0
		
			ESX.Game.SpawnObject("bkr_prop_biker_safebody_01a", {
				x = x,
				y = y,
				z = zz
			}, function(obj1)
				FreezeEntityPosition(obj1, true)
				SetEntityHeading(obj1, v.h + 180.0)
				portaid = obj1
			end)
		
			local xx = x
			local yy = y
			local zz = zz + 0.1
		
			ESX.Game.SpawnObject("bkr_prop_biker_safedoor_01a", {
				x = xx,
				y = yy,
				z = zz
			}, function(obj)
				FreezeEntityPosition(obj, true)
				SetEntityHeading(obj, v.h + 180.0)
				corpoid = obj
			end)
			table.insert( Cofres, {id = v.id, owner = v.owner, x = x, y = y, z = z, h = h, money = 0, porta = portaid, corpo = corpoid})
		end
	end)
end)

Citizen.CreateThread(function()
	while Cofres ~= nil do
		Citizen.Wait(5)
		local i = 0
		for k, v in pairs(Cofres) do
		  i = i + 1
		  playerPedt = PlayerPedId()
		  local coords = GetEntityCoords(playerPedt)
		  local dist = GetDistanceBetweenCoords(v.x, v.y, v.z, coords.x, coords.y, coords.z, false)
		  if dist <= 0.5 then
			DrawText3D(v.x, v.y, v.z, "Pressiona [~g~E~w~] para abrir o cofre ~y~/~w~ Pressiona [~r~G~w~] para retirar o cofre.", 0.4)
			if dist <= 0.5 and IsControlJustPressed(0, 38) then
				ESX.TriggerServerCallback("kuana:getplayerowner",function(check)
					if check == v.owner then
						FreezeEntityPosition(playerPedt, true)
						openmenu(v.x, v.y, v.z, v.h)
					else
						ESX.ShowNotification("Este cofre ~r~nao~w~ lhe pertence.")
					end
				end, v.id)
			elseif dist <= 0.5 and IsControlJustPressed(0, 47) then
				ESX.TriggerServerCallback("kuana:getplayerowner",function(check)
					if check == v.owner then
						DeleteObject(v.porta)
						DeleteObject(v.corpo)
						TriggerServerEvent("kuana:deletecofredb", v.id)
						TriggerServerEvent("kuana:deleteallcofre", i)
					elseif PlayerData.job ~= nil and PlayerData.job.name == "police" then
						DeleteObject(v.porta)
						DeleteObject(v.corpo)
						TriggerServerEvent("kuana:deletecofredb", v.id)
						TriggerServerEvent("kuana:deleteallcofre", i)
					else
						ESX.ShowNotification("Este cofre ~r~nao~w~ lhe pertence.")
					end
				end, v.id)
			end
		  end
		end
	end
end)

RegisterNetEvent('kuana:deletecofreall')
AddEventHandler('kuana:deletecofreall', function(num)
	table.remove( Cofres, num )
end)


function openmenu(x, y, z, h)
	local elements = {
		{label = "Colocar" , value = "colocar"},
		{label = "Retirar" , value = "retirar"}
	}
	
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'kuanaitem',
		{
			title    = "Cofre Menu",
			align    = 'top-left',
			elements = elements,
		},
		function(data, menu)
			menu.close()
			if data.current.value == "colocar" then
				opencolocar(x, y, z, h)

			elseif data.current.value == "retirar" then
				openretirar(x, y, z, h)
			end
		end,
		function(data, menu)
			menu.close()
			FreezeEntityPosition(playerPedt, false)
			--CurrentAction = 'open_garage_action'
		end
	)	
end



function opencolocar(x, y, z, h)

	local elements2 = {}

	ESX.TriggerServerCallback("kuana:getPlayerInventory",function(blackmoney, itemsinv, dinheiro)
		if dinheiro > 0 then
			table.insert(elements2, {
				label = "Dinheiro: "..dinheiro,
				type  = 'item_account',
				value = 'money'
			})
		end
		
		if blackmoney > 0 then
			table.insert(elements2, {
				label = "Dinheiro Sujo: "..blackmoney,
				type  = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #itemsinv, 1 do
			local item = itemsinv[i]

			if item.count > 0 then
				table.insert(elements2, {
					label = item.label .. ' x' .. item.count,
					type  = 'item_standard',
					value = item.name,
					label2 = item.label
				})
			end
		end
		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'kuanaitema',
			{
				title    = "Cofre Menu",
				align    = 'top-left',
				elements = elements2,
			},
			function(data3, menu3)
				menu3.close()
				if data3.current.value == "money" then
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_countcofreq', {
						title = "Quantidade"
					}, function(data4, menu4)
	
						local quantity = tonumber(data4.value)
	
						if quantity == nil then
							ESX.ShowNotification("Quantidade invalida")
						else
							menu4.close()

							TriggerServerEvent("kuana:setmoneycofre", tonumber(data4.value), x, y, z)
						end
						openmenu(x, y, z, h)
					end, function(data4, menu4)
						menu4.close()
						openmenu(x, y, z, h)
					end)
					
				elseif data3.current.value == "black_money" then
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_countcofrew', {
						title = "Quantidade"
					}, function(data4, menu4)
	
						local quantity = tonumber(data4.value)
	
						if quantity == nil then
							ESX.ShowNotification("Quantidade invalida")
						else
							menu4.close()

							TriggerServerEvent("kuana:setblackmoneycofre", tonumber(data4.value), x, y, z)
						end
						openmenu(x, y, z, h)
					end, function(data4, menu4)
						menu4.close()
						openmenu(x, y, z, h)
					end)
				else
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_countcofree', {
						title = "Quantidade"
					}, function(data4, menu4)
	
						local quantity = tonumber(data4.value)
	
						if quantity == nil then
							ESX.ShowNotification("Quantidade invalida")
						else
							menu4.close()

							TriggerServerEvent('kuana:cofreputItem', data3.current.label2, data3.current.value, tonumber(data4.value), x, y, z)
						end
						openmenu(x, y, z, h)
					end, function(data4, menu4)
						menu4.close()
						openmenu(x, y, z, h)
					end)
				end
				
			end,
			function(data3, menu3)
				menu3.close()
				openmenu(x, y, z, h)
				--CurrentAction = 'open_garage_action'
			end
		)	
	end)


end

function openretirar(x, y, z, h)

	local elements2 = {}
	ESX.TriggerServerCallback("kuana:getPlayerInventoryCofre",function(blackmoney, itemscofre, cofremoney)
		if cofremoney > 0 then
			table.insert(elements2, {
				label = "Dinheiro: "..cofremoney,
				type  = 'item_account',
				value = 'money',
				money = cofremoney
			})
		end
		
		if blackmoney > 0 then
			table.insert(elements2, {
				label = "Dinheiro Sujo: "..blackmoney,
				type  = 'item_account',
				value = 'black_money',
				bmoney = blackmoney
			})
		end
		local listarcofreitems = {}
		listarcofreitems = itemscofre
		for _,v in pairs(listarcofreitems) do
			table.insert(elements2, {
				label = v.itemlabel .. ' x' .. v.itemcount,
				type  = 'item_standard',
				value = v.itemname,
				label2 = v.itemlabel
			})
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'kuanaitemm',
			{
				title    = "Cofre Menu",
				align    = 'top-left',
				elements = elements2,
			},
			function(data3, menu3)
				menu3.close()
				if data3.current.value == "money" then
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_countcofrea', {
						title = "Quantidade"
					}, function(data4, menu4)
	
						local quantity = tonumber(data4.value)
	
						if quantity == nil then
							ESX.ShowNotification("Quantidade invalida")
							openretirar(x, y, z, h)
						else
							menu4.close()
							
							TriggerServerEvent('kuana:givemoneyplayer', tonumber(data4.value), x, y, z)
							Citizen.Wait(500)
							openretirar(x, y, z, h)
						end
						
					end, function(data4, menu4)
						menu4.close()
						openretirar(x, y, z, h)
					end)
				elseif data3.current.value == "black_money" then
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_countcofres', {
						title = "Quantidade"
					}, function(data4, menu4)
	
						local quantity = tonumber(data4.value)
	
						if quantity == nil then
							ESX.ShowNotification("Quantidade invalida")
						else
							menu4.close()

							TriggerServerEvent('kuana:givemoneybplayer', tonumber(data4.value), x, y, z)
							Citizen.Wait(500)
							openretirar(x, y, z, h)
						end
					end, function(data4, menu4)
						menu4.close()
						openretirar(x, y, z, h)
					end)
				else
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_countcofred', {
						title = "Quantidade"
					}, function(data4, menu4)
	
						local quantity = tonumber(data4.value)
	
						if quantity == nil then
							ESX.ShowNotification("Quantidade invalida")
						else
							menu4.close()

							TriggerServerEvent('kuana:cofretakeItem', data3.current.label2, data3.current.value, tonumber(data4.value), x, y, z)

							Citizen.Wait(500)
							openretirar(x, y, z, h)
						end
					end, function(data4, menu4)
						menu4.close()
						openretirar(x, y, z, h)
					end)
				end
			end,
			function(data3, menu3)
				menu3.close()
				openmenu(x, y, z, h)
				--CurrentAction = 'open_garage_action'
			end
		)	
	end, x, y, z)

end

RegisterNetEvent('kuana:usarcofre')
AddEventHandler('kuana:usarcofre', function()
	local playerPed = PlayerPedId()
	local x, y, z = table.unpack(GetEntityCoords(playerPed))
	local h = GetEntityHeading(playerPed)

	local zz = z - 1
	local portaid5 = 0
	local corpoid5 = 0

	ESX.Game.SpawnObject("bkr_prop_biker_safebody_01a", {
		x = x,
		y = y,
		z = zz
	}, function(obj5)
		FreezeEntityPosition(obj5, true)
		SetEntityHeading(obj5, GetEntityHeading(playerPed) + 180.0)
		corpoid5 = obj5
	end)

	local xx = x
	local yy = y
	local zz = zz + 0.1

	ESX.Game.SpawnObject("bkr_prop_biker_safedoor_01a", {
		x = xx,
		y = yy,
		z = zz
	}, function(obj6)
		FreezeEntityPosition(obj6, true)
		SetEntityHeading(obj6, GetEntityHeading(playerPed) + 180.0)
		portaid5 = obj6
	end)

	ESX.TriggerServerCallback("kuana:cofrespawned",function(indexcofre, identifiercofre)
		table.insert( Cofres, {id = indexcofre, owner = identifiercofre, x = x, y = y, z = z, h = h, money = 0, porta = portaid5, corpo = corpoid5})
		TriggerServerEvent("kuana:spawnanothercofre", x, y, z, h, indexcofre, identifiercofre)
	end, x, y, z, h)
end)

RegisterNetEvent('kuana:spawnanothercofre')
AddEventHandler('kuana:spawnanothercofre', function(x, y, z, h, indexcofre, identifiercofre)
	local playerPed = PlayerPedId()

	local zz = z - 1
	local corpoid2 = 0

	ESX.Game.SpawnObject("bkr_prop_biker_safebody_01a", {
		x = x,
		y = y,
		z = zz
	}, function(obj3)
		FreezeEntityPosition(obj3, true)
		SetEntityHeading(obj3, GetEntityHeading(playerPed) + 180.0)
		corpoid2 = obj3
	end)

	local xx = x
	local yy = y
	local zz = zz + 0.1
	local portaid2 = 0

	ESX.Game.SpawnObject("bkr_prop_biker_safedoor_01a", {
		x = xx,
		y = yy,
		z = zz
	}, function(obj2)
		FreezeEntityPosition(obj2, true)
		SetEntityHeading(obj2, GetEntityHeading(playerPed) + 180.0)
		portaid2 = obj2
	end)

	table.insert( Cofres, {id = indexcofre, owner = identifiercofre, x = x, y = y, z = z, h = h, money = 0, porta = portaid2, corpo = corpoid2})
end)


function DrawText3D(x, y, z, text, scale)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
	SetTextScale(scale, scale)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry("STRING")
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 255)
	SetTextOutline()
	AddTextComponentString(text)
	DrawText(_x, _y)
	local factor = (string.len(text)) / 270
	DrawRect(_x, _y + 0.015, 0.005 + factor, 0.03, 31, 31, 31, 155)
end


