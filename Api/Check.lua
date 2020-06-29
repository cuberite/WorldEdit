





--- Called before an operation to check whether other plugins allow the operation.
-- returns true to abort operation, returns false to continue.
-- a_HookName is the name of the hook to call. Everything after that are arguments for the hook.
function CallHook(a_HookName, ...)
	assert(g_Hooks[a_HookName] ~= nil)

	for idx, callback in ipairs(g_Hooks[a_HookName]) do
		local res = cPluginManager:CallPlugin(callback.PluginName, callback.CallbackName, ...)
		if (res) then
			-- The callback wants to abort the operation
			return true
		end
	end

	return false
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
		local FinalCuboid = cCuboid(
			Vector3i(MinX, MinY, MinZ),
			Vector3i(MaxX, MaxY, MaxZ)
		)
		return CallHook("OnAreaChanging", FinalCuboid, Player, World, Operation)
	end

	return Object
end
