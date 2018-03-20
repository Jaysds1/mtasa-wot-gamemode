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

--- Default GameTimer constructor
-- Creates a whole new class for a new GameTimer
--
-- @tparam int _i the number of ms(milliseconds) to count down from
-- @param _func the function to execute after ms is done
-- @return the new GameTimer created
-- @usage GameTimer(500)
-- @usage GameTimer(500,function()end)
GameTimer = class(function(GT,_i,_func)
	if not _i or type(_i) ~= "number" then
		error("Time interval must be a number!")
		return false
	elseif _i <= 0 then
		error("Time must be greater than 0ms")
		return false
	end
	_func = _func or _onExecute
	GT._t = Timer(_func,_i,0)
end)

--- Destroy GameTimer
-- Destroys the game timer used and ends the class GameTimer
--
-- @treturn boolean whether everything was successfully destroyed (true or false)
-- @usage GameTimer.destroy()
function GameTimer:destroy()
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
function GameTimer:isOn()
	if not self._t or not self._t.valid then return false
	else return true
	end
end

--- Reset GameTimer
-- This will reset the game timer
--
-- @treturn boolean whether the game timer was reset or not (true or false)
-- @usage GameTimer.reset()
function GameTimer:reset()
	if self._t == false or not self.isOn() then
		error("No timer running")
		return false
	end
	return self._t:reset()
end