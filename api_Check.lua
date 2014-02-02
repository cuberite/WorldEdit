function CheckIfInsideAreas(a_MinX, a_MaxX, a_MinY, a_MaxY, a_MinZ, a_MaxZ, a_Player, a_World, a_Operation)
	for Key, Value in ipairs(ExclusionAreaPlugins[a_World:GetName()]) do
		if Value.Plugin:Call(Value.FunctionName, a_MinX, a_MaxX, a_MinY, a_MaxY, a_MinZ, a_MaxZ, a_Player, a_World, a_Operation) then
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
		return CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, Player, World, Operation)
	end
	
	return Object
end