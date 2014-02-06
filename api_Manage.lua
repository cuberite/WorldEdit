

--- Registers a function from an external plugin that will be called for each operation in the specified world
-- Returns true to signalize call success to the caller
-- Callbacks should have the following signature:
--   function(a_MinX, a_MaxX, a_MinY, a_MaxY, a_MinZ, a_MaxZ, a_Player, a_World, a_Operation)
-- The callback should return true to abort the operation, false to continue.
function RegisterAreaCallback(a_PluginName, a_FunctionName, a_WorldName)
	-- Check the parameters for validity:
	if (
		(type(a_PluginName)   ~= "string") or (a_PluginName   == "") or
		(type(a_FunctionName) ~= "string") or (a_FunctionName == "") or
		(type(a_WorldName)    ~= "string") or (a_WorldName    == "")
	) then
		LOGWARNING("[WorldEdit] Invalid callback registration parameters.")
		LOGWARNING("  RegisterAreaCallback() was called with params " ..
			tostring(a_PluginName   or "<nil>") .. ", " ..
			tostring(a_FunctionName or "<nil>") .. ", " ..
			tostring(a_WorldName    or "<nil>")
		)
		return false
	end
	
	-- Insert the callback into the callback table:
	table.insert(ExclusionAreaPlugins[a_WorldName], {PluginName = a_PluginName, FunctionName = a_FunctionName})
	return true
end





--- Registers a function from an external plugin that will be called for each time a player tries to select an new selection point.
-- It returns true to signalize call success to the caller
-- Callbacks should have the following signature:
--   function(a_Player, a_PosX, a_PosY, a_PosZ, a_PointNr)
-- a_PointNr can be 0 for Left click or 1 for right click.
-- The callback should return true to abort the operation, or false to continue.
function RegisterPlayerSelectingPoint(a_PluginName, a_FunctionName)
	-- Check the parameters.
	if (
		(type(a_PluginName)   ~= "string") or (a_PluginName   == "") or
		(type(a_FunctionName) ~= "string") or (a_FunctionName == "")
	) then
		LOGWARNING("[WorldEdit] Invalid callback registration parameters.")
		LOGWARNING("  RegisterCallback() was called with params " ..
			tostring(a_PluginName   or "<nil>") .. ", " ..
			tostring(a_FunctionName or "<nil>") .. ", "
		)
		return false
	end
	
	-- Insert the callback into the table.
	table.insert(PlayerSelectPointHooks, {PluginName = a_PluginName, FunctionName = a_FunctionName})
	return true
end
