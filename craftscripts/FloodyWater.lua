--[[
	Floody simulator craftscript for WorldEdit (Cuberite)

	Permission needed for this script is "worldedit.scripting.execute" (By default) and "worldedit.craftscript.FloodyWater".
	Usage: Select the region you want water to be simulated with the wand and then execute this script.
]]--


local a_Player, a_Split = ...

-- Check if the player has the right permission
if (not a_Player:HasPermission("worldedit.craftscript.FloodyWater")) then
	a_Player:SendMessage(cChatColor.Rose .. "You don't have permission to use this script.")
	return true
end

local PlayerState = GetPlayerState(a_Player)

-- Check if the selected region is valid.
if (not PlayerState.Selection:IsValid()) then
	a_Player:SendMessage(cChatColor.Rose .. "Please select a region first.")
	return true
end

local SrcCuboid = PlayerState.Selection:GetSortedCuboid()
local World = a_Player:GetWorld()

-- Check if other plugins might want to block this action.
if (CallHook("OnAreaChanging", SrcCuboid, a_Player, World, "craftscript.FloodyWater")) then
	return true
end





------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------
-- Helper Functions

-- IsWater returns true if the given blocktype is water.
local function IsWater(a_BlockType)
	if (
		(a_BlockType == E_BLOCK_WATER) or
		(a_BlockType == E_BLOCK_STATIONARY_WATER)
	) then
		return true
	end
	return false
end





-- IsWashAble returns true if the given blocktype is a block that water can wash away.
local g_IsWashAble = table.todictionary{
	E_BLOCK_AIR,
	E_BLOCK_BROWN_MUSHROOM,
	E_BLOCK_CACTUS,
	E_BLOCK_COBWEB,
	E_BLOCK_CROPS,
	E_BLOCK_DEAD_BUSH,
	E_BLOCK_LILY_PAD,
	E_BLOCK_RAIL,
	E_BLOCK_REDSTONE_TORCH_OFF,
	E_BLOCK_REDSTONE_TORCH_ON,
	E_BLOCK_REDSTONE_WIRE,
	E_BLOCK_RED_MUSHROOM,
	E_BLOCK_RED_ROSE,
	E_BLOCK_SNOW,
	E_BLOCK_SUGARCANE,
	E_BLOCK_TALL_GRASS,
	E_BLOCK_TORCH,
	E_BLOCK_YELLOW_FLOWER,
	E_BLOCK_TALL_GRASS,
	E_BLOCK_BIG_FLOWER,
}





local g_PossibleFlowCoordinates = {
	{x = -1, z =  0},
	{x =  1, z =  0},
	{x =  0, z = -1},
	{x =  0, z =  1},
}

-- End of helper functions.
---------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------





local BlockArea = cBlockArea()
BlockArea:Read(World, SrcCuboid, cBlockArea.baTypes + cBlockArea.baMetas)

PlayerState.UndoStack:PushUndoFromCuboid(World, SrcCuboid, "craftscript.FloodyWater")

local SizeX, SizeY, SizeZ = BlockArea:GetCoordRange()
local Cuboid = cCuboid(
	Vector3i(0, 0, 0),
	Vector3i(SizeX, SizeY, SizeZ)
)
local ins = table.insert

-- Find all the waterblocks that are currently in the area.
local WaterBlocks = {}
for X = 0, SizeX do
	for Y = 0, SizeY do
		for Z = 0, SizeZ do
			if (IsWater(BlockArea:GetRelBlockType(X, Y, Z))) then
				ins(WaterBlocks, {x = X, y = Y, z = Z})
			end
		end
	end
end


while (WaterBlocks[1]) do
	local OldWaterBlocks = WaterBlocks
	WaterBlocks = {}

	for Idx, Coord in ipairs(OldWaterBlocks) do
		if (Cuboid:IsInside(Coord.x, Coord.y - 1, Coord.z) and g_IsWashAble[BlockArea:GetRelBlockType(Coord.x, Coord.y - 1, Coord.z)] or IsWater(BlockArea:GetRelBlockType(Coord.x, Coord.y - 1, Coord.z))) then
			BlockArea:SetRelBlockTypeMeta(Coord.x, Coord.y - 1, Coord.z, E_BLOCK_WATER, 8)
			ins(WaterBlocks, {x = Coord.x, y = Coord.y - 1, z = Coord.z})
		else
			local Meta = BlockArea:GetRelBlockMeta(Coord.x, Coord.y, Coord.z)
			if (Meta ~= 7) then -- Higher then 7 isn't possible, and we already checked down.
				for Idx, RelCoords in ipairs(g_PossibleFlowCoordinates) do
					local X, Y, Z = Coord.x + RelCoords.x, Coord.y, Coord.z + RelCoords.z
					if (Cuboid:IsInside(X, Y, Z) and g_IsWashAble[BlockArea:GetRelBlockType(X, Y, Z)]) then
						BlockArea:SetRelBlockTypeMeta(X, Y, Z, E_BLOCK_WATER, (Meta == 8 and 1) or Meta + 1)
						ins(WaterBlocks, {x = X, y = Y, z = Z})
					end
				end
			end
		end
	end
end


BlockArea:Write(World, SrcCuboid.p1.x, SrcCuboid.p1.y, SrcCuboid.p1.z, cBlockArea.baTypes + cBlockArea.baMetas)
CallHook("OnAreaChanged", SrcCuboid, a_Player, World, "craftscript.FloodyWater")

return true
