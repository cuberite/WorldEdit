
-- CraftScripts.lua

-- Implements the cCraftScript class representing a script for a single player.





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
	local Path = cPluginManager:GetCurrentPlugin():GetLocalDirectory() .. "/craftscripts/" .. a_ScriptName .. ".lua"
	if (not cFile:Exists(Path)) then
		return false, "The script does not exist."
	end
	
	local Function, Err = loadfile(Path)
	if (not Function) then
		return false, "There is an issue in the scripts code."
	end
	
	self.SelectedScript = Function
	return true
end





function cCraftScript:Execute(a_Player, a_Split)
	if (not self.SelectedScript) then
		return false, "There is no script selected."
	end
	
	local Succes = pcall(self.SelectedScript, a_Player, a_Split)
	if (not Succes) then
		return false, "Something went wrong while running the script."
	end
	
	return true
end




