function CheckIfInsideAreas(a_MinX, a_MaxX, a_MinY, a_MaxY, a_MinZ, a_MaxZ, a_Player, a_World, a_Operation)
	for Key, Value in pairs(ExclusionArea[a_World:GetName()]) do
		if Value.Plugin:Call(Value.FunctionName, a_MinX, a_MaxX, a_MinY, a_MaxY, a_MinZ, a_MaxZ, a_Player, a_World, a_Operation) then
			return true
		end
	end
	return false
end