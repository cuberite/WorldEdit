
-- api_Manage.lua

-- Implements functions that can be called by external plugins to manipulate WorldEdit state





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
		LOGWARNING("  RegisterPlayerSelectingPoint() was called with params " ..
			tostring(a_PluginName   or "<nil>") .. ", " ..
			tostring(a_FunctionName or "<nil>")
		)
		return false
	end
	
	-- Insert the callback into the table.
	table.insert(PlayerSelectPointHooks, {PluginName = a_PluginName, FunctionName = a_FunctionName})
	return true
end





--- Sets the player's selection to the specified cuboid.
-- Returns true on success, false on failure.
function SetPlayerCuboidSelection(a_Player, a_Cuboid)
	-- Check the params:
	if (
		(tolua.type(a_Player) ~= "cPlayer") or
		(tolua.type(a_Cuboid) ~= "cCuboid")
	) then
		LOGWARNING("[WorldEdit] Invalid SetPlayerCuboidSelection API function parameters.")
		LOGWARNING("  SetPlayerCuboidSelection() was called with param types \"" ..
			tolua.type(a_Player) .. "\" (\"cPlayer\" wanted) and \"" ..
			tolua.type(a_Cuboid) .. "\" (\"cCuboid\" wanted)."
		)
		return false
	end
	
	-- Set the selection, both points:
	local State = GetPlayerState(a_Player)
	State.Selection:SetFirstPoint(a_Cuboid.p1.x, a_Cuboid.p1.y, a_Cuboid.p1.z)
	State.Selection:SetSecondPoint(a_Cuboid.p2.x, a_Cuboid.p2.y, a_Cuboid.p2.z)
	return true
end





--- Sets the specified corner-point of the player's cuboid selection to the specified Vector3i coord.
-- Returns true if successful, false if selection not cuboid / other error
function SetPlayerCuboidSelectionPoint(a_Player, a_PointNumber, a_CoordVector)
	-- Check the params:
	if (
		(tolua.type(a_Player)      ~= "cPlayer") or
		(tonumber(a_PointNumber)   == nil)  or
		(tolua.type(a_CoordVector) ~= "Vector3i")
	) then
		LOGWARNING("[WorldEdit] Invalid SetPlayerCuboidSelectionPoint API function parameters.")
		LOGWARNING("  SetPlayerCuboidSelection() was called with param types \"" ..
			tolua.type(a_Player) .. "\" (\"cPlayer\" wanted), \"" ..
			type(a_PointNumber) .. "\" (\"number\" wanted) and \"" ..
			tolua.type(a_CoordVector) .. "\" (\"cVector3i\" wanted)."
		)
		return false
	end
	
	-- Set the specified selection point:
	local State = GetPlayerState(a_Player)
	if (tonumber(a_PointNumber) == 1) then
		State.Selection:SetFirstPoint(a_CoordVector)
	elseif (tonumber(a_PointNumber) == 2) then
		State.Selection:SetSecondPoint(a_CoordVector)
	else
		LOGWARNING("[WorldEdit] Invalid SetPlayerCuboidSelectionPoint API function parameters.")
		LOGWARNING("  SetPlayerCuboidSelection() was called with invalid point number " .. a_PointNumber)
		return false
	end
	return true
end





--- If the player's selection is a cuboid (as oposed to sphere / cylinder / ...), returns true;
-- Returns false if player's selection is not a cuboid
function IsPlayerSelectionCuboid(a_Player)
	-- Current WE version has only cuboid selections
	return true
end





--- If the player's selection is a cuboid, sets a_CuboidToSet to the selection cuboid and returns true
-- Returns false if player's selection is not a cuboid.
-- Note that we can't return a cCuboid instance - it would be owned by this plugin's Lua state and it could
-- delete it at any time, making the variable in the other state point to bad memory, crashing the server.
function GetPlayerCuboidSelection(a_Player, a_CuboidToSet)
	-- Check the params:
	if (
		(tolua.type(a_Player)      ~= "cPlayer") or
		(tolua.type(a_CuboidToSet) ~= "cCuboid")
	) then
		LOGWARNING("[WorldEdit] Invalid SetPlayerCuboidSelection API function parameters.")
		LOGWARNING("  SetPlayerCuboidSelection() was called with param types \"" ..
			tolua.type(a_Player) .. "\" (\"cPlayer\" wanted) and \"" ..
			tolua.type(a_CuboidToSet) .. "\" (\"cCuboid\" wanted)."
		)
		return false
	end
	
	-- Set the output cuboid to the selection:
	local State = GetPlayerState(a_Player)
	a_CuboidToSet:Assign(State.Selection.Cuboid)
	return true
end




