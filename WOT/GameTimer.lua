-- @author Jaysds1

--- Top GameTimer Class
GameTimer = {
	local _t = false, -- the timer for MTA built-in function (setTimer aka Timer)
	local executes = 0 -- executes the times the timer has been executed
}
GameTimer.__index = GameTimer
setmetatable(GameTimer,{
	__call = function(cls,...)
		return cls.new(...)
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

--- Default GameTimer constructor
-- Creates a whole new class for a new GameTimer
--
-- @tparam int _i the number of ms(milliseconds) to count down from
-- @param _func the function to execute after ms is done
-- @return the new GameTimer created
-- @usage GameTimer(500)
-- @usage GameTimer(500,function()end)
function GameTimer.new(_i,_func)
	if not _i then
		error("No time set for timer or !")
		return false
	elseif not _i > 0 then
		error("Time must be greater than 0ms")
		return false
	end
	_func = _func or _onExecute
	local self = setmetatable({},GameTimer)
	self._t = Timer(_func,_i,0)
	return self
end

--- Destroy GameTimer
-- Destroys the game timer used and ends the class GameTimer
--
-- @treturn boolean whether everything was successfully destroyed (true or false)
-- @usage GameTimer.destroy()
function GameTimer.destroy()
	if self._t == false or not self.isOn() then
		error("No timer running")
		return false
	end
	self._t.destroy()
	self._t = false
	self.executes = 0
	self = nil
	return true
end

--- Checks GameTimer
-- Checks whether the game timer is still running or valid
--
-- @treturn boolean whether the game timer is running or valid (true or false)
-- @usage GameTimer.isOn()
function GameTimer.isOn()
	if not self._t then return false
	elseif not self._t.valid then return false
	else return true
	end
end

--- Reset GameTimer
-- This will reset the game timer
--
-- @treturn boolean whether the game timer was reset or not (true or false)
-- @usage GameTimer.reset()
function GameTimer.reset()
	if self._t == false or not self.isOn() then
		error("No timer running")
		return false
	end
	return self._t:reset()
end