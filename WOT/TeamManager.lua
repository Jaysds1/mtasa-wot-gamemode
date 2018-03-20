-- @author Jaysds1

--- Top TeamManager Class

--- All Teams
local Teams = {}

--- Copy of MTA Built-in outputDebugString function
-- This allows a shorter function name to be called other than calling outputDebugString
-- again and again; and it's easier to remember!
--
-- @tparam string _s the string to output
-- @treturn boolean whether the output was successful (true or false)
-- @usage error("Example")
local error = function(_s)
	return outputDebugString(_s,1)
end

--- Create Team
-- When called a team is created
--
-- @tparam string _tn The team name to create
-- @usage TeamManager("Team Name")
TeamManager = class(function(TM,_tn)
	if not _tn or type(_tn) ~= "string" then
		error("Team name must be entered")
		return false
	end
	TM.team = Team(_tn)
	table.insert(Teams,TM)
end)

function TeamManager:setName(_tn)
	if not _tn or type(_tn) ~= "string" then
		error("Team name must be called something")
		return false
	end
	(self.team).name = _tn
end

function TeamManager:setScore(score)
	if type(score) ~= "number" then
		error("Score must be a number")
		return false
	end
	self.score = score
end

function TeamManager:getName()
	return (self.team).name
end
function TeamManager:getScore()
	return self.score
end

function TeamManager:getTeams()
	return Teams
end


--- Set Player Team
-- Gets all the teams and adds the player to the team with the least amount of players or just a random team
--
-- @tparam string _tn The team name to create
-- @usage TeamManager("Team Name")
function TeamManager:setPlayerTeam(p)
	if not p then return false end
	local teams = self.getTeams()
	local tPlayers = {}
	for i,v in ipairs(teams) do
		table.insert(tPlayers, (v.name).players)
	end
	
	table.sort(tPlayers)
	-- adding players to the team with the least amount of players
	if #tPlayers[1] > #tPlayers[2] then
		p:setTeam(teams[1].team)
	elseif #tPlayers[2] > #tPlayers[1] then
		p:setTeam(teams[2].team)
	else
		p:setTeam(teams[math.random(1,2)].team)
	end
	
	teamHandler.spawnPlayer(p)
end


--- Spawn Player
-- Spawns a player into their vehicle and gets them ready for the game
--
-- @tparam string _tn The team name to create
-- @usage TeamManager("Team Name")
function TeamManager:spawnPlayer(p)
	p:spawn(0,0,0)
	local tName = (p.team).name
	local x,y,z = MapManager.getTeamPositions(tName)
	local v = Vehicle(432,x,y,z+0.5)
	p:setData("WOT.Vehicle",v)
	p:warpIntoVehicle(v)
	p:fadeCamera(true,5)
	p:setCameraTarget(p)
	
	p:setHudComponentVisible("all",false)
end


--- Spawn Death
-- Gets the player's vehicle then spawns them into it
--
-- @tparam string _tn The team name to create
-- @usage TeamManager("Team Name")
function TeamManager:spawnDeath()
	local v = source:getData("WOT.Vehicle")
	v:respawn()
	Timer(function(p,v)
		p:spawn(0,0,0)
		p:warpIntoVehicle(v)
	end,1500,1,p,v)
end