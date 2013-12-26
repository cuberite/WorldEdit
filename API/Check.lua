function CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	local Region = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Region:Sort()
	for Key, Value in pairs(ExclusionArea) do
		if Value[1]:DoesIntersect(Region) then
			return true
		end
	end
	return false
end