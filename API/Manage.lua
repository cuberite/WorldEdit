function AddExclusionArea(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, WorldName)
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:Sort()
	table.insert(ExclusionArea, {Cuboid, WorldName})
	return #ExclusionArea
end

function DelExclusionArea(ID)
	ExclusionArea[ID] = nil -- We can't use table.remove because all the other ID's would then be mixed up.
end