
-- CraftScripts.lua

-- Implements the cCraftScript class representing a script for a single player.





-- Only logs when debugging for craftscripts is enabled
local function LOGSCRIPTERROR(a_Msg)
	if (not g_Config.Scripting.Debug) then
		return
	end
	
	LOGERROR(a_Msg)
end





-- All the variables in _G that a craftscript isn't allowed to use.
local g_BlockedFunctions = table.todictionary{
	"rawset",
	"rawget",
	"setfenv",
	"io",
	"os",
	"debug",
	"cFile",
	"loadstring",
	"loadfile",
	"load",
	"dofile",
	"ExecuteString",
	"_G",
	"cPluginManager",
}





local g_CraftScriptEnvironment = setmetatable({}, {
		__index = function(_, a_Key)
			if (g_BlockedFunctions[a_Key]) then
				local ScriptInfo = debug.getinfo(2)
				error("Craftscript tried to use blocked variable at line " .. ScriptInfo.currentline .. " in file " .. ScriptInfo.short_src)
				return nil
			end
			return _G[a_Key]
		end
	}
)





--- Class for storing a players selected script
cCraftScript = {}





function cCraftScript:new(a_Obj)
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cCraftScript)
	self.__index = self
	
	-- Initialize the object members:
	a_Obj.SelectedScript = nil
	
	return a_Obj;
end





function cCraftScript:SelectScript(a_ScriptName)
	local Path = cPluginManager:GetCurrentPlugin():GetLocalFolder() .. "/craftscripts/" .. a_ScriptName .. ".lua"
	if (not cFile:IsFile(Path)) then
		return false, "The script does not exist."
	end
	
	local Function, Err = loadfile(Path)
	if (not Function) then
		LOGSCRIPTERROR(Err)
		return false, "There is an issue in the scripts code."
	end
	
	-- Make sure the craftscript can't break code by overlapping our global variables and functions
	setfenv(Function, g_CraftScriptEnvironment)
	
	self.SelectedScript = Function
	return true
end





function cCraftScript:Execute(a_Player, a_Split)
	if (not self.SelectedScript) then
		return false, "There is no script selected."
	end
	
	-- Limit the execution time of the script if configured
	if (g_Config.Scripting.MaxExecutionTime > 0) then
		local TimeLimit = os.clock() + g_Config.Scripting.MaxExecutionTime
		debug.sethook(function()
			if (TimeLimit < os.clock()) then
				debug.sethook()
				error("Time limit exceeded. Max time is: " .. g_Config.Scripting.MaxExecutionTime .. " seconds")
			end
		end, "", 100000)
	end
	
	-- Execute the craftscript
	local Succes, Err = pcall(self.SelectedScript, a_Player, a_Split)
	
	-- Remove the timelimit.
	debug.sethook()
	
	if (not Succes) then
		LOGSCRIPTERROR(Err)
		return false, "Something went wrong while running the script."
	end
	
	return true
end




