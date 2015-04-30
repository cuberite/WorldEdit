
--- Called before each operation to check with the callbacks whether other plugins allow the operation
-- Returns true if the operation is to be aborted, false to continue
function CheckIfInsideAreas(a_MinX, a_MaxX, a_MinY, a_MaxY, a_MinZ, a_MaxZ, a_Player, a_World, a_Operation)
	for idx, callback in ipairs(g_ExclusionAreaPlugins[a_World:GetName()]) do
		local res = cPluginManager:CallPlugin(callback.PluginName, callback.FunctionName, a_MinX, a_MaxX, a_MinY, a_MaxY, a_MinZ, a_MaxZ, a_Player, a_World, a_Operation)
		if (res) then
			-- The plugin wants to abort the operation
			return true
		end
	end
	return false
end






--- Called before each operation to check with the callbacks whether other plugins allow the operation
-- Returns false if the operation is to be aborted, true to continue
-- Uses a sorted cCuboid for the affected region coords
function CheckAreaCallbacks(a_Cuboid, a_Player, a_World, a_Operation)
	assert(tolua.type(a_Cuboid) == "cCuboid")
	
	for idx, callback in ipairs(g_ExclusionAreaPlugins[a_World:GetName()]) do
		local res = cPluginManager:CallPlugin(
			callback.PluginName, callback.FunctionName,
			a_Cuboid.p1.x, a_Cuboid.p2.x,
			a_Cuboid.p1.y, a_Cuboid.p2.y,
			a_Cuboid.p1.z, a_Cuboid.p2.z,
			a_Player, a_World, a_Operation
		)
		if (res) then
			-- The callback wants to abort the operation
			return false
		end
	end
	return true
end





function GetMultipleBlockChanges(MinX, MaxX, MinZ, MaxZ, Player, World, Operation)
	local MinY = 256
	local MaxY = 0
	local Object = {}
	function Object:SetY(Y)
		if Y < MinY then
			MinY = Y
		elseif Y > MaxY then
			MaxY = Y
		end
	end
	
	function Object:Flush()
		return CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, Player, World, Operation)
	end
	
	return Object
end





function CheckIfAllowedToChangeSelection(a_Player, a_PosX, a_PosY, a_PosZ, a_PointNr)
	for idx, callback in ipairs(g_PlayerSelectPointHooks) do
		local res = cPluginManager:CallPlugin(callback.PluginName, callback.FunctionName, a_Player, a_PosX, a_PosY, a_PosZ, a_PointNr)
		if (res) then
			-- The plugin wants to abort the operation.
			return true
		end
	end
	return false
end
