addEvent("onResourceDownloaded",true)
addEvent("onPlayerSubmitLogin",true)
addEvent("onPlayerSubmitSignup",true)
addEvent("onClientScreenSizeChange",true)
addEvent("onClientEnter",true)

--TODO: Blips,Scoreboard,In-Water Timer

WOT = {
	isGameStarted = false, -- Is the players playing?
	GT = { --Game Timer Table/Class
		_t = false, --The timer
		executes = 0, --How much times did this timer execute?
		isOn = function() --Checks if timer is on
			if not WOT.GT._t then return false --Is the timer set?
			elseif not (WOT.GT._t).valid then return false --Is the timer valid?
			else return true --No more methods to check, just say it's on
			end
		end,
		create = function(_i,_func) --Creates a timer
			_func = _func or _onExecute --Checks if a function is declared and sets a default function
			if WOT.GT.isOn() then --Checks if a timer is already running
				--outputDebug()
				outputChatBox("Timer already running!") --Let the user know
				return false --end the create transaction
			end
			WOT.GT._t = Timer(_func,_i,0) --Creates a timer
		end,
		destroy = function() --Destroys a timer
			if not WOT.GT.isOn() then --Checks if a timer is not running
				--[[outputDebug()]]
				outputChatBox("Timer not running!") --Let the user know
				return false--end the destroy transaction
			end
			WOT.GT._t:destroy() --destroy the timer
			WOT.GT._t = false
			executes = 0
		end
	},
	ready = {} --Players that's ready
}
teamHandler = {
	teams = {
		{
			Team("Blue",0,0,255),
			score = 0
		},
		{
			Team("Red",255,0,0),
			score = 0
		}	
	}
}
mapHandler = {
	map = false,
	mapName = false,
	spawns = {},
	maps = {}
}

--Game Timer
function _lT() --Lobby Timer
	WOT.GT.executes = WOT.GT.executes - 1
	resourceRoot:setData("WOT.GT",WOT.GT.executes)
	if WOT.GT.executes <= 0 then
		WOT.GT.destroy()
		startGame()
	end
end
addEventHandler("onResourceStart",resourceRoot,function()
	setGameType("Tank Warfare")
	--Check if anyone's logged in
	for _,p in ipairs(getElementsByType("player"))do
		if not p:getAccount().guest then
			p:logOut()
			p:fadeCamera(false)
		end
		WOT.ready[p] = false
	end
	
	--Timer for starting game
	WOT.GT.executes = 30
	WOT.GT.create(1000,_lT)
	--lets show the lobby
	resourceRoot:setData("WOT.lobby",true)
	resourceRoot:setData("WOT.game",false)
	resourceRoot:setData("WOT.GT",WOT.GT.executes)
	
	--Get Compatible Maps
	for _,m in ipairs(getResources())do
		if m:getInfo("type") == "map" and m:getInfo("gamemodes") == "WOT" then
			table.insert(mapHandler.maps,m)
		end
	end
end)
--[[addEventHandler("onResourceStop",resourceRoot,function()
	resourceRoot:removeData("WOT.lobby")
	resourceRoot:removeData("WOT.game")
	resourceRoot:removeData("WOT.GT")
	resourceRoot:removeData("WOT.Team1")
	resourceRoot:removeData("WOT.Team2")
	root:removeData("WOT.MapData")
	for _,p in ipairs(getElementsByType("player"))do
		if p:getData("WOT.Vehicle") then
			p:removeData("WOT.Vehicle")
		end
	end
end)]]

function startGame()
	resourceRoot:setData("WOT.lobby",false)
	WOT.isGameStarted = true
	
	--Get a map ready
	local map = mapHandler.maps[math.random(#mapHandler.maps)]
	mapHandler.map = map
	mapHandler.mapName = map:getInfo("name")
	map:start()
	setMapName(mapHandler.mapName)
	
	local _d = root:getData("WOT.MapData")
	mapHandler.spawns = _d.teams
	setTime(_d.time[1],_d.time[2])
	setWeather(_d.weather)
	
	for _,p in ipairs(getElementsByType("player"))do
		if WOT.ready[p] == true then
			teamHandler.setPlayerTeam(p)
		end
	end
	for _,v in ipairs(getElementsByType("vehicle"))do
		v.frozen = true
	end
	addEventHandler("onPlayerWasted",root,teamHandler.spawnDeath)
	

	resourceRoot:setData("WOT.Team1",teamHandler.teams[1].score)
	resourceRoot:setData("WOT.Team2",teamHandler.teams[2].score)
	
	--Set up ready timer
	WOT.GT.executes = 15
	resourceRoot:setData("WOT.GT",WOT.GT.executes)
	
	_onExecute = function()
		WOT.GT.executes = WOT.GT.executes - 1
		resourceRoot:setData("WOT.GT",WOT.GT.executes)
		if WOT.GT.executes <= 0 then
			WOT.GT.destroy()
			for _,v in ipairs(getElementsByType("vehicle"))do
				v.frozen = false
			end
			--Set up the length of the game/match
			WOT.GT.executes = 120
			_onExecute = function()
				WOT.GT.executes = WOT.GT.executes - 1
				resourceRoot:setData("WOT.GT",WOT.GT.executes)
				if WOT.GT.executes <= 0 then
					WOT.GT.destroy()
					stopGame()
				end
			end
			WOT.GT.create(1000)
		end
	end
	WOT.GT.create(1000)
	
	resourceRoot:setData("WOT.game",true)
end
function stopGame()
	WOT.isGameStarted = false
	mapHandler.map:stop()
	mapHandler.map = false
	mapHandler.mapName = false
	root:setData("WOT.MapData",false)
	mapHandler.spawns = {}
	setTime(0,0)
	setWeather(0)
	
	removeEventHandler("onPlayerWasted",root,teamHandler.spawnDeath)
	
	local _v = {} --Table of vehicles not being used
	for _,p in ipairs(getElementsByType("player"))do
		if WOT.ready[p] == true then
			--Show player lobby
			p:fadeCamera(false)
			p:setTeam(false)
			if not p.vehicle then --if the player isn't in a vehicle
				local v = p:getData("WOT.Vehicle")
				if v then
					table.insert(_v,v) --insert the players vehicle
				end
			else
				if not p.vehicle:destroy() then --if it can't be destroyed
					p.vehicle:respawn()
					p.vehicle:destroy()
				end
			end
			for _,v in ipairs(_v)do --loop through non-used vehicles
				if v then
					if not v:destroy() then --if it can't be destroyed
						v:respawn()
						v:destroy()
					end
				end
			end
		end
	end
	resourceRoot:setData("WOT.Team1",false)
	resourceRoot:setData("WOT.Team2",false)
	teamHandler.teams[1].score = 0
	teamHandler.teams[2].score = 0
	resourceRoot:setData("WOT.game",false)
	
	--Timer for starting game
	WOT.GT.executes = 30
	WOT.GT.create(1000,_lT)
	--lets show the lobby
	resourceRoot:setData("WOT.lobby",true)
	resourceRoot:setData("WOT.GT",WOT.GT.executes)
end

--Login
addEventHandler("onPlayerSubmitLogin",root,function(u,p)
	if u == "" or p == "" then
		return triggerClientEvent(client,"onClientLoginReturn",client,false,"Please enter your username and password!")
	end
	local acc = Account(u)
	if not acc then
		return triggerClientEvent(client,"onClientLoginReturn",client,false,"Account doesn't exist!")
	end
	if logIn(client,acc,p) then
		triggerClientEvent(client,"onClientLoginReturn",client,true,"You have successfully signed in!")
	else
		triggerClientEvent(client,"onClientLoginReturn",client,false,"Wrong password!")
	end
end)
addEventHandler("onPlayerSubmitSignup",root,function(u,p)
	if u == "" or p == "" then
		return triggerClientEvent(client,"onClientSignupReturn",client,false,"Please enter a username and password!")
	end
	local acc = Account(u)
	if acc then
		return triggerClientEvent(client,"onClientSignupReturn",client,false,"Account exists!")
	end
	acc = addAccount(u,p)
	if acc then
		triggerClientEvent(client,"onClientSignupReturn",client,true,"You have successfully signed up!")
	else
		triggerClientEvent(client,"onClientSignupReturn",client,false,"Something went wrong, please try another username and password!")
	end
end)
addEventHandler("onClientEnter",root,function()
	WOT.ready[source] = true
	if WOT.isGameStarted then
		--lets get this player in the game
		teamHandler.setPlayerTeam(client)
	end
end)

--Team Handler
teamHandler.setPlayerTeam = function(p)
	if not p then return false end
	local teams = teamHandler.teams
	local tPlayers = {teams[1][1].players,teams[2][1].players}
	
	if #tPlayers[1] > #tPlayers[2] then
		p:setTeam(teams[1][1])
	elseif #tPlayers[2] > #tPlayers[1] then
		p:setTeam(teams[2][1])
	else
		p:setTeam(teams[math.random(1,2)][1])
	end
	
	teamHandler.spawnPlayer(p)
end
teamHandler.spawnPlayer = function(p)
	p:spawn(0,0,0)
	local tName = (p.team).name
	local x,y,z = mapHandler.getTeamPositions(tName)
	local v = Vehicle(432,x,y,z+0.5)
	p:setData("WOT.Vehicle",v)
	p:warpIntoVehicle(v)
	p:fadeCamera(true,5)
	p:setCameraTarget(p)
	
	p:setHudComponentVisible("all",false)
end

--Maps
mapHandler.getTeamPositions = function(tName)
	local t = {["Blue"]=1,["Red"]=2}
	local spawns = mapHandler.spawns
	return unpack(spawns[t[tName]][math.random(#spawns[t[tName]])])
end

--In-Game
teamHandler.spawnDeath = function()
	local v = source:getData("WOT.Vehicle")
	v:respawn()
	Timer(function(p,v)
		p:spawn(0,0,0)
		p:warpIntoVehicle(v)
	end,1500,1,p,v)
end
addEventHandler("onPlayerJoin",root,function() WOT.ready[source] = false end)
addEventHandler("onPlayerQuit",root,function()
	WOT.ready[source] = nil
	if WOT.isGameStarted then
		if source.vehicle.blown then
			source.vehicle:respawn()
		end
		source.vehicle:destroy()
	end
end)