-- @author Jaysds1

--- Top TeamManager Class
TeamManager = {
	team = nil, -- MTA Team
	score = 0 -- Team Score
}
TeamManager.__index = TeamManager
setmetatable(TeamManager,{
	__call = function(cls,..)
		return cls.new(..)
	end
})

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
function TeamManager.new(_tn)
	if not _tn then
		error("Team name not entered!")
		return false
	end
	local self = setmetatable({},TeamManager)
	self.team = Team(_tn)
	return self
end