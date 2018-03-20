-- @author Jaysds1

--- Top GameTimer Class

--- Copy of MTA Built-in outputDebugString function
-- This allows a shorter function name to be called other than calling outputDebugString
-- again and again; and it's easier to remember!
--
-- @tparam string _s the string to output
-- @treturn boolean whether the output was successful (true or false)
-- @usage error("Example")
local error = function(_s)
	if not _s or type(_s) ~= "number" then return false end
	return outputDebugString(_s,1)
end

MapHandler = class(function(mh)
	mh.maps = {}
	mh.map = false
	mh.name = ""
	mh.spawns = {}
end)

function MapHandler:addMap(m)
	if(m.type~="resource")then
		error("MapHandler:Add - Invalid resource")
		return false
	end
	table.insert(self.maps,m)
	return true
end

function MapHandler:getMaps(i)
	if(type(i)~="number")then
		error("MapHandler:Get Map - Invalid index number")
		return false
	elseif(i < 0 or i > #self.maps)then
		error("MapHandler:Get Map - Index number does not exist")
		return false
	end
	return self.maps[i]
end

function MapHandler:setMap(m)
	if(m.type~="resource")then
		error("MapHandler:Set Map - Invalid resource")
		return false
	end
	self.map = m
	return true
end
function MapHandler:getMap()
	return self.map
end

function MapHandler:setName(n)
	if(type(n)~="string")then
		error("MapHandler:Set Name - Invalid map name")
		return false
	end
	self.name = n
	setMapName(n)
	return true
end
function MapHandler:getName()
	return self.name
end

function MapHandler:addSpawn(s)
	table.insert(self.spawns,s)
	return true
end
function MapHandler:getSpawn(i)
	if(type(i)~="number")then
		error("MapHandler:Get Spawn - Invalid index number")
		return false
	elseif(i < 0 or i > #self.spawns)then
		error("MapHandler:Get Spawn - Index number does not exist")
		return false
	end
	return self.spawns[i]
end