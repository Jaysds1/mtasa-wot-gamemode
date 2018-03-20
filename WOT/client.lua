--[[addEventHandler("onClientResourceStart",resourceRoot,function(res)
	if res ~= resource then return end
	triggerServerEvent("onResourceDownloaded",localPlayer)
end)]]
------------------------------------------------------------------------
addEvent("onClientLoginReturn",true)
addEvent("onClientSignupReturn",true)
addEvent("setClientScreenSize",true)

sw,sh = guiGetScreenSize() --The actual screen size
local rel = false --Relative Co-ordinates
local color = {
	black = tocolor(0,0,0),
	white = tocolor(255,255,255),
	grey = tocolor(127.5,127.5,127.5),
	red = tocolor(255,0,0),
	green = tocolor(0,255,0),
	blue = tocolor(0,0,255)
}

GuiLabel(sw-90,sh-30,90,15,"World Of Tanks",rel) --WOT Fine Print
toggleControl("enter_exit",false) -- Leaving the tank is prohibitted

--Main Menu-------------------------------------------------------------
local mm = {"mm1","mm2","mm3","mm4"}
local MM = math.random(#mm)
local mAlpha = 255 --Visibility of Enter Label
function MainMenu()
	dxDrawImage(0,0,sw,sh,"images/"..mm[MM]..".jpg")
	dxDrawRectangle(0,(sh/2)+40,sw,60,tocolor(0,0,0,100))
	dxDrawText("ENTER",(sw/2) - 60,(sh/2) + 45,60,50,tocolor(255,255,255,mAlpha),3)
	mAlpha = mAlpha - 10
	if mAlpha <= 0 then
		mAlpha = 255
	end
end
addEventHandler("onClientRender",root,MainMenu)
function mmKey(b,p)
	if b~="enter" or not p then return end
	removeEventHandler("onClientRender",root,MainMenu)
	removeEventHandler("onClientKey",root,mmKey)
	triggerServerEvent("onClientEnter",localPlayer)
	if resourceRoot:getData("WOT.lobby") then
		showChat(true)
		addEventHandler("onClientRender",root,_players)
	end
end

--Login System----------------------------------------------------------
local x,y = sw/2 - 200,sh/2 - 150
local login = {}
function login_win()
	dxDrawRectangle(x,y,400,300,color.grey)
end
login.label_user = GuiLabel(x + 10,y + 30,150,15,"Username:",rel)
login.label_pass = GuiLabel(x + 10,y + 60,150,15,"Password:",rel)
login.info = GuiLabel(x + 50,y + 5,300,15,"Please Login!",rel)
login.user = GuiEdit(x + 170,y + 30,150,20,"",rel)
login.pass = GuiEdit(x + 170,y + 60,150,20,"",rel)
login.pass:setMasked(true)
login.pass:setMaxLength(30)
login.submit = GuiButton(x + 150,y + 120,100,30,"Signin",rel)
login.signup = GuiButton(x + 150,y + 170,100,30,"Signup",rel)
showCursor(true)
showChat(false)
addEventHandler("onClientRender",root,login_win)

function account_listener(b) -- GUI Button Listener
	if b ~= "left" then return end
	local u,p = login.user.text,login.pass.text
	if source == login.submit then --Signin was clicked
		if u == "" or u:len()<=1 or p == "" or p:len()<=1 then
			login.info:setText("Please type in your username and password!")
		else
			triggerServerEvent("onPlayerSubmitLogin",localPlayer,u,p)
		end
	elseif source == login.signup then --Signup was clicked
		if u == "" or u:len()<=1 or p == "" or p:len()<=1 then
			login.info:setText("Please type in a username and password!")
		else
			triggerServerEvent("onPlayerSubmitSignup",localPlayer,u,p)
		end
	end
end
addEventHandler("onClientGUIClick",guiRoot,account_listener)
function lginKey(b,p) --Login Key Listener
	if b~="enter" or not p then return end
	triggerEvent("onClientGUIClick",login.submit,"left")
end
addEventHandler("onClientKey",root,lginKey)

function lginInfo() --Info Label Listener
	Timer(function() login.info:setText("") end,1500,1)
end
addEventHandler("onClientGUIChanged",login.info,lginInfo)

addEventHandler("onClientLoginReturn",root,function(suc,inf) --Triggered when login is attempted
	local r,g,b = 255, 0, 0
	if suc then --If the account exists
		r,g = 0,255
		Timer( --2.5sec to remove the login window
			function()
				removeEventHandler("onClientGUIChanged",login.info,lginInfo)
				local guis = {login.label_user,login.label_pass,login.info,login.user,login.pass,login.submit}
				if login.signup.visible then table.insert(guis,login.signup) end
				for _,gui in ipairs(guis)do
					gui:destroy()
				end
				removeEventHandler("onClientRender",root,login_win)
				addEventHandler("onClientKey",root,mmKey) --Enable 'enter' button
			end
		,2500,1)
		showCursor(false)
		removeEventHandler("onClientKey",root,lginKey)
	end
	login.info:setColor(r,g,b)
	login.info:setText(inf)
	triggerEvent("onClientGUIChanged",login.info)
end)
addEventHandler("onClientSignupReturn",root,function(suc,inf) --Triggered when signup is attempted
	local r,g,b = 255,0,0
	if suc then --if the account was created
		r,g = 0,255
		login.signup:destroy() --Remove button
	end
	login.info:setColor(r,g,b)
	login.info:setText(inf)
	triggerEvent("onClientGUIChanged",login.info)
end)

--Lobby----------------------------------------------------------
function _players()
	local x,y = sw/2 + 250,0
	dxDrawRectangle(x,y,x-250,sh,tocolor(127.5,127.5,127.5,150))
	dxDrawText("Players:",x + 10,y + 50,250,150,color.green,2)
	for i,p in ipairs(getElementsByType("player"))do --Show players in lobby
		dxDrawText(p.name,x + 10,y + ( i * 150),250,25,color.white,1.5)
	end
	dxDrawText(resourceRoot:getData("WOT.GT").." secs",x + 10,sh - 50,100,50,color.red,1.5) --Time left to start playing
end

--In-Game--------------------------------------------------------
local w = -1 --In-Water Timer
function _gameState()
	local x,y = sw/2 - 150,0
	--Team Scores
	dxDrawRectangle(x,y,300,50,tocolor(0,0,0,150))
	dxDrawText(resourceRoot:getData("WOT.Team1"),x + 10,y + 5,50,100,tocolor(0,0,255,150),2)
	dxDrawText(resourceRoot:getData("WOT.Team2"),x + 270,y + 5,50,100,tocolor(255,0,0,150),2)
	
	--Game Timer Display
	local t = resourceRoot:getData("WOT.GT")
	local mins,secs = 0,0
	if t > 60 then
		mins = math.floor(t/60)
		secs = t - (math.floor(t/60)*60)
	else
		secs = t
	end
	if mins > 0 and mins < 10 then
		mins = "0"..mins
	end
	if secs > 0 and secs < 10 then
		secs = "0"..secs
	end
	dxDrawText(mins..":"..secs,x + 125,y + 5,100,100,tocolor(255,255,255,150),1.5)
	
	if localPlayer.inVehicle then
		x,y = sw-200,sh-150
		--Vehicle Health Display
		dxDrawRectangle(x,y,150,30,color.black)
		local h = (localPlayer.vehicle.health - 250)/750*100
		dxDrawRectangle(x+2,y+2,h+45,25,color.red)
		local c
		if math.floor(h) > 70 then
			c = color.green
		elseif math.floor(h) > 40 then
			c = color.blue
		else
			c = color.red
		end
		dxDrawText(math.floor(h).."%",x + 50,y + 5,35,30,c,1.5)
		--Is vehicle in the water
		if (localPlayer.vehicle):isInWater() then
			if w == -1 then w = 10 end
			dxDrawText(w,sw/2 - 50,sh/2 - 50,100,100,color.blue,2.5)
		elseif w ~= -1 then
			w = -1
		end
	end
end

local _t --In-Water Timer Timer
addEventHandler("onClientElementDataChange",root,function(d)
	if d=="WOT.lobby" then
		if source:getData(d) then
			showChat(true)
			addEventHandler("onClientRender",root,_players)
			--Camera.fade(true)
			-- Camera.setInterior(1)
			-- Camera.setMatrix(1378.1,-15.40,1008.99,1401.3,-15.5,1003.9)
		else
			removeEventHandler("onClientRender",root,_players)
			-- Camera.setInterior(0)
		end
	elseif d=="WOT.game" then
		if source:getData(d) then
			addEventHandler("onClientRender",root,_gameState)
			_t = Timer(function()
				if w ~= -1 then
					w = w - 1
				end
				if w == 0 then
					(localPlayer.vehicle):blow()
				end
			end, 1000,0)
		else
			removeEventHandler("onClientRender",root,_gameState)
			_t:destroy()
			_t = nil
		end
	end
end)
--ScoreBoard----------------------------------------------------------
