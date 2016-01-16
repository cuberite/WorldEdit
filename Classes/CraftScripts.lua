
-- CraftScripts.lua

-- Implements the cCraftScript class representing a script for a single player.





-- Only logs when debugging for craftscripts is enabled
local function LOGSCRIPTERROR(a_Msg)
	if (not g_Config.Scripting.Debug) then
		return
	end
	
	LOGERROR(a_Msg)
end





-- All the functions that a craftscript isn't allowed to use.
local g_BlockedFunctions = table.todictionary{
	"rawset",
	"setfenv",
	"io",
	"os",
}





local g_CraftScriptEnvironment = setmetatable({}, {
		__index = function(_, a_Key)
			if (g_BlockedFunctions[a_Key]) then
				error("CraftScript tried to use blocked function: " .. a_Key)
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
	
	local Succes, Err = pcall(self.SelectedScript, a_Player, a_Split)
	if (not Succes) then
		LOGSCRIPTERROR(Err)
		return false, "Something went wrong while running the script."
	end
	
	return true
end




