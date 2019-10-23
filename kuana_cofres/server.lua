ESX = nil

-- ESX
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('cofre', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('kuana:usarcofre', source)
end)

ESX.RegisterServerCallback('kuana:cofrespawned', function (source, cb, x, y, z, h)
	local _source = source 
	local xPlayer = ESX.GetPlayerFromId(_source)
	xPlayer.removeInventoryItem('cofre', 1)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	MySQL.Async.execute('INSERT INTO cofres (owner, x, y, z, h, money, black_money) VALUES (@owner, @xx, @yy, @zz, @hh, @money, @bmoney)',
	{
		['@owner']   = xPlayer.identifier,
		["@xx"] = x,
		["@yy"] = y,
		["@zz"] = z,
		["@hh"] = h,
		["@money"] = 0,
		["@bmoney"] = 0
	}, function (rowsChanged)
		TriggerClientEvent('esx:showNotification', _source, "~y~Colocou~w~ um ~g~cofre~w~ no chao.")
	end)
	Citizen.Wait(1000)
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})

	cb(idcofre, xPlayer.identifier)
end)

RegisterNetEvent('kuana:cofreputItem')
AddEventHandler('kuana:cofreputItem', function(labelitem, iditem, quantidade, x, y, z)
	local _source = source 
	local xPlayer = ESX.GetPlayerFromId(_source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local checkitem = MySQL.Sync.fetchScalar("SELECT itemcount FROM cofre_items WHERE cofrename = @cofrename and itemname = @itemname", {['@cofrename'] = idcofre, ['@itemname'] = iditem})
	if xPlayer.getInventoryItem(iditem).count >= quantidade then
		xPlayer.removeInventoryItem(iditem, quantidade)
		if checkitem == nil then
			MySQL.Async.execute('INSERT INTO cofre_items (cofrename, itemname, itemlabel, itemcount) VALUES (@cofrename, @itemname, @itemlabel, @itemcount)',
			{
				['@cofrename'] = idcofre,
				["@itemname"] = iditem,
				["@itemlabel"] = labelitem,
				["@itemcount"] = quantidade
			}, function (rowsChanged)
				TriggerClientEvent('esx:showNotification', _source, "~y~Colocou~w~ um ~g~cofre~w~ no chao.")
			end)
		else
			MySQL.Async.execute("UPDATE cofre_items SET itemcount = @itemcount WHERE cofrename = @cofrename",
				{
					["@itemcount"] = checkitem + quantidade,
					["@cofrename"] = idcofre
				}
			)
		end
	else
		TriggerClientEvent('esx:showNotification', _source, "Tu ~r~nao~w~ tens essa ~y~quantia~w~.")
	end
end)

RegisterNetEvent('kuana:cofretakeItem')
AddEventHandler('kuana:cofretakeItem', function(labelitem, iditem, quantidade, x, y, z)
	local _source = source 
	local xPlayer = ESX.GetPlayerFromId(_source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local checkitem = MySQL.Sync.fetchScalar("SELECT itemcount FROM cofre_items WHERE cofrename = @cofrename and itemname = @itemname", {['@cofrename'] = idcofre, ['@itemname'] = iditem})
	local checkdel = checkitem - quantidade
	if checkitem >= quantidade then
		if checkdel ~= 0 then
			xPlayer.addInventoryItem(iditem, quantidade)
			MySQL.Async.execute("UPDATE cofre_items SET itemcount = @itemcount WHERE cofrename = @cofrename",
				{
					["@itemcount"] = checkitem - quantidade,
					["@cofrename"] = idcofre
				}
			)
		else
			xPlayer.addInventoryItem(iditem, quantidade)
			MySQL.Async.execute('DELETE FROM cofre_items WHERE cofrename = @cofrename AND itemname = @itemname',
			{
				["@cofrename"] = idcofre,
				["@itemname"] = iditem
			})
		end
	else
		TriggerClientEvent('esx:showNotification', _source, "Tu ~r~nao~w~ tens essa ~y~quantia~w~.")
	end
end)

RegisterNetEvent('kuana:setmoneycofre')
AddEventHandler('kuana:setmoneycofre', function(quantidade, x, y, z)
	local _source = source 
	local xPlayer = ESX.GetPlayerFromId(_source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	local moneyatual = xPlayer.getMoney()
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local cofremoney = MySQL.Sync.fetchScalar("SELECT money FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local checkmoney = moneyatual - quantidade 
	if checkmoney >= 0 then
		xPlayer.removeMoney(quantidade)
	
		MySQL.Async.execute("UPDATE cofres SET money = @money WHERE cofrename = @cofrename",
			{
				["@money"] = cofremoney + quantidade,
				["@cofrename"] = idcofre
			}
		)
	else
		TriggerClientEvent('esx:showNotification', _source, "Tu ~r~nao~w~ tens essa ~y~quantia~w~.")
	end
end)

RegisterNetEvent('kuana:spawnanothercofret')
AddEventHandler('kuana:spawnanothercofret', function(x, y, z, h, idcrf, owner)
	TriggerClientEvent("kuana:spawnanothercofre", -1, x, y, z, h, idcrf, owner)
end)

RegisterNetEvent('kuana:setblackmoneycofre')
AddEventHandler('kuana:setblackmoneycofre', function(quantidade, x, y, z)
	local _source = source 
	local xPlayer = ESX.GetPlayerFromId(_source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	local moneyatual = xPlayer.getAccount("black_money").money
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local cofremoney = MySQL.Sync.fetchScalar("SELECT black_money FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local checkmoney = moneyatual - quantidade 
	if checkmoney >= 0 then
		xPlayer.removeAccountMoney("black_money", quantidade)
	
		MySQL.Async.execute("UPDATE cofres SET black_money = @black_money WHERE cofrename = @cofrename",
			{
				["@black_money"] = cofremoney + quantidade,
				["@cofrename"] = idcofre
			}
		)
	else
		TriggerClientEvent('esx:showNotification', _source, "Tu ~r~nao~w~ tens essa ~y~quantia~w~.")
	end
end)

RegisterNetEvent('kuana:givemoneyplayer')
AddEventHandler('kuana:givemoneyplayer', function(quantidade, x, y, z)
	local _source = source 
	local xPlayer = ESX.GetPlayerFromId(_source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	local cofremoney = MySQL.Sync.fetchScalar("SELECT money FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local checkmoney = cofremoney - quantidade
	if checkmoney >= 0 then
		xPlayer.addMoney(quantidade)
		
		MySQL.Async.execute("UPDATE cofres SET money = @money WHERE cofrename = @cofrename",
			{
				["@money"] = cofremoney - quantidade,
				["@cofrename"] = idcofre
			}
		)
	else
		TriggerClientEvent('esx:showNotification', _source, "Tu ~r~nao~w~ tens essa ~y~quantia~w~ no cofre.")
	end
end)

RegisterNetEvent('kuana:givemoneybplayer')
AddEventHandler('kuana:givemoneybplayer', function(quantidade, x, y, z)
	local _source = source 
	local xPlayer = ESX.GetPlayerFromId(_source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	local cofremoney = MySQL.Sync.fetchScalar("SELECT black_money FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	xPlayer.addAccountMoney("black_money", quantidade)
	
	MySQL.Async.execute("UPDATE cofres SET black_money = @black_money WHERE cofrename = @cofrename",
		{
			["@black_money"] = cofremoney - quantidade,
			["@cofrename"] = idcofre
		}
	)
end)

ESX.RegisterServerCallback("kuana:getPlayerInventory", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
	local blackMoney = xPlayer.getAccount("black_money").money
	local dinheiro = xPlayer.getMoney()
    local items = xPlayer.inventory

    cb(blackMoney, items, dinheiro)
end)

ESX.RegisterServerCallback("kuana:getPlayerInventoryCofre", function(source, cb, x, y, z)
    local xPlayer = ESX.GetPlayerFromId(source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	z = math.floor(z * 100) / 100
	local listaitems = {}
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local moneycofre = MySQL.Sync.fetchScalar("SELECT money FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	local blackMoney = MySQL.Sync.fetchScalar("SELECT black_money FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
	MySQL.Async.fetchAll("SELECT * FROM cofre_items WHERE cofrename = @cofrename", {['@cofrename'] = idcofre}, function(data) 
		for _,v in pairs(data) do
			table.insert(listaitems, {cofrename = idcofre, itemname = v.itemname, itemlabel = v.itemlabel, itemcount = v.itemcount})
		end
		cb(blackMoney, listaitems, moneycofre)
	end)
    
end)


ESX.RegisterServerCallback('kuana:checkinfoplus', function (source, cb, x, y)
	local xPlayer = ESX.GetPlayerFromId(source)
	x = math.floor(x * 100) / 100
	y = math.floor(y * 100) / 100
	local idcofre = MySQL.Sync.fetchScalar("SELECT cofrename FROM cofres WHERE x = @xx and y = @yy", {['@yy'] = y, ['@xx'] = x})
  
	cb(idcofre, xPlayer.identifier)
end)

ESX.RegisterServerCallback('kuana:getplayerowner', function (source, cb, owner)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.identifier)
end)

ESX.RegisterServerCallback('kuana:getCofres', function(source, cb)
	local cofres = {}

	MySQL.Async.fetchAll("SELECT * FROM cofres",{}, function(data) 
		for _,v in pairs(data) do
			table.insert(cofres, {id = v.cofrename, owner = v.owner, xx = v.x, yy = v.y, zz = v.z, h = v.h, money = v.money})
		end
		cb(cofres)
	end)
end)

RegisterServerEvent('kuana:deletecofredb')
AddEventHandler('kuana:deletecofredb', function(id)
	MySQL.Async.execute('DELETE FROM cofres WHERE cofrename = @id',
	{
		["@id"] = id
	})
end)

RegisterServerEvent('kuana:deleteallcofre')
AddEventHandler('kuana:deleteallcofre', function(num)
	TriggerClientEvent("kuana:deletecofreall", -1, num)
end)