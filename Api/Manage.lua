
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





--- Pushes an undo from the current contents of the area
-- a_World is the world where to read the area
-- a_Cuboid is the area's coords (both points are inclusive)
-- a_Description holds the user-visible description of the undo savepoint
-- Assumes that all the chunks for the cuboid are in memory
-- Returns true on success, false and optional message on failure
function WEPushUndo(a_Player, a_World, a_Cuboid, a_Description)
	-- Check the params:
	if (
		(tolua.type(a_Player) ~= "cPlayer") or
		(tolua.type(a_World)  ~= "cWorld")  or
		(tolua.type(a_Cuboid) ~= "cCuboid") or
		(type(a_Description)  ~= "string")
	) then
		LOGWARNING("[WorldEdit] Invalid WEPushUndo API function parameters.")
		LOGWARNING("  WePushUndo() was called with these param types:")
		LOGWARNING("    " .. tolua.type(a_Player) .. " (cPlayer wanted),")
		LOGWARNING("    " .. tolua.type(a_World)  .. " (cWorld  wanted),")
		LOGWARNING("    " .. tolua.type(a_Cuboid) .. " (cCuboid wanted),")
		LOGWARNING("    " .. type(a_Description)  .. " (string  wanted),")
		return false, "bad params"
	end
	
	-- Push the undo:
	local State = GetPlayerState(a_Player)
	return State.UndoStack:PushUndoFromCuboid(a_World, a_Cuboid, a_Description)
end





--- Pushes an undo from the current contents of the area
-- a_World is the world where to read the area
-- a_Cuboid is the area's coords (both points are inclusive)
-- a_Description holds the user-visible description of the undo savepoint
-- Will load all chunks required for the operation asynchronously
-- When the undo gets pushed (or an error is detected preventing the push),
-- the a_CallbackFunctionName is called in a_CallbackPluginName
-- The callback receives two params, IsSuccess (bool) and FailureMessage (string or nil)
-- Returns true on success, false and optional message on early failure
function WEPushUndoAsync(a_Player, a_World, a_Cuboid, a_Description, a_CallbackPluginName, a_CallbackFunctionName)
	-- Check the params:
	if (
		(tolua.type(a_Player)         ~= "cPlayer") or
		(tolua.type(a_World)          ~= "cWorld")  or
		(tolua.type(a_Cuboid)         ~= "cCuboid") or
		(type(a_Description)          ~= "string") or
		(type(a_CallbackPluginName)   ~= "string") or
		(type(a_CallbackFunctionName) ~= "string")
	) then
		LOGWARNING("[WorldEdit] Invalid WEPushUndoAsync() API function parameters.")
		LOGWARNING("  WePushUndo() was called with these param types:")
		LOGWARNING("    " .. tolua.type(a_Player)         .. " (cPlayer wanted),")
		LOGWARNING("    " .. tolua.type(a_World)          .. " (cWorld  wanted),")
		LOGWARNING("    " .. tolua.type(a_Cuboid)         .. " (cCuboid wanted),")
		LOGWARNING("    " .. type(a_Description)          .. " (string  wanted),")
		LOGWARNING("    " .. type(a_CallbackPluginName)   .. " (string  wanted),")
		LOGWARNING("    " .. type(a_CallbackFunctionName) .. " (string  wanted),")
		return false, "bad params"
	end
	
	-- if the input cuboid isn't sorted, create a sorted copy:
	if not(a_Cuboid:IsSorted()) then
		a_Cuboid = cCuboid(a_Cuboid)
		a_Cuboid:Sort()
	end
	
	-- Create a callback for the ChunkStay:
	local State = GetPlayerState(a_Player)  -- a_Player may be deleted in the meantime, but the State table won't
	local OnAllChunksAvailable = function()
		local IsSuccess, Msg = State.UndoStack:PushUndoFromCuboid(a_World, a_Cuboid, a_Description)
		cPluginManager:CallPlugin(a_CallbackPluginName, a_CallbackFunctionName, IsSuccess, Msg)
	end
	
	-- Get a list of chunks that need to be present:
	local Chunks = ListChunksForCuboid(a_Cuboid)
	
	-- Initiate a ChunkStay operation, pushing the undo when all the chunks are available
	a_World:ChunkStay(Chunks, nil, OnAllChunksAvailable)
	return true
end




