-- @author Jaysds1

--- Game Class

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
Game = class(function(g)
	g.started = false
	g.ready = {}
end)

function Game:isStarted()
	return self.started
end

function Game:setStarted(started)
	if(type(started)~="boolean")then
		error("Game:Set Started - Not a boolean type")
		return false
	end
	self.started = started
	return true
end

function Game:setReady(p,r)
	if(p.type~="player" or type(r)~="boolean")then
		error("Game:Set Ready - Not a valid player or 'ready' boolean")
		return false
	end
	ready[p] = r
	return true
end

function Game:getReady(p)
	if(p.type~="player")then
		error("Game:Get Ready - Not a valid player")
		return false
	end
	return ready[p]
end

function Game:getAllReady()
	local r
	for i,p in ipairs(self.ready)do
		if(self.ready[p] == true)then r[p] = true end
	end
	return r
end