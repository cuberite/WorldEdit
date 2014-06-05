local LEAVES_CHECK_DISTANCE = 6

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
if not(CheckAreaCallbacks(SrcCuboid, a_Player, World, "craftscript.FloodyWater")) then
	return true
end

local BlockArea = cBlockArea()
BlockArea:Read(World, SrcCuboid, cBlockArea.baTypes)

local SizeX, SizeY, SizeZ = BlockArea:GetSize()
SizeX, SizeY, SizeZ = SizeX - 1, SizeY - 1, SizeZ - 1

local Leaves = {}

for X=0, SizeX do
	for Y=0, SizeY do
		for Z=0, SizeZ do
			local BlockType = BlockArea:GetRelBlockType(X, Y, Z)
			if (
				(BlockType == E_BLOCK_LEAVES) or
				(BlockType == E_BLOCK_NEW_LEAVES)
			) then
				table.insert(Leaves, {x = X + SrcCuboid.p1.x,y = Y + SrcCuboid.p1.y,z = Z + SrcCuboid.p1.z})
			end
		end
	end
end


for Idx, Coord in ipairs(Leaves) do
	local BlockArea = cBlockArea()
	BlockArea:Read(
		World,
		Coord.x - LEAVES_CHECK_DISTANCE, Coord.x + LEAVES_CHECK_DISTANCE,
		Coord.y - LEAVES_CHECK_DISTANCE, Coord.y + LEAVES_CHECK_DISTANCE,
		Coord.z - LEAVES_CHECK_DISTANCE, Coord.z + LEAVES_CHECK_DISTANCE,
		cBlockArea.baTypes
	)
	
	for Y=Coord.y - LEAVES_CHECK_DISTANCE, Coord.y + LEAVES_CHECK_DISTANCE do
		for Z=Coord.z - LEAVES_CHECK_DISTANCE, Coord.z + LEAVES_CHECK_DISTANCE do
			for X=Coord.x - LEAVES_CHECK_DISTANCE, Coord.x + LEAVES_CHECK_DISTANCE do
				local BlockType = BlockArea:GetBlockType(X, Y, Z)
				if (
					(BlockType ~= E_BLOCK_LEAVES) and
					(BlockType ~= E_BLOCK_LOG) and
					(BlockType ~= E_BLOCK_NEW_LEAVES) and
					(BlockType ~= E_BLOCK_NEW_LOG)
				) then
					BlockArea:SetBlockType(X, Y, Z, E_BLOCK_AIR)
				end
			end
		end
	end
	
	BlockArea:SetBlockType(Coord.x, Coord.y, Coord.z, E_BLOCK_SPONGE)
	
	local function PROCESS_NEIGHBOR(a_X, a_Y, a_Z, a_I)
		local BlockType = BlockArea:GetBlockType(a_X, a_Y, a_Z)
		if (
			(BlockType == E_BLOCK_LEAVES) or
			(BlockType == E_BLOCK_NEW_LEAVES)
		) then
			BlockArea:SetBlockType(a_X, a_Y, a_Z, E_BLOCK_SPONGE + a_I + 1)
		elseif (
			(BlockType == E_BLOCK_LOG) or
			(BlockType == E_BLOCK_NEW_LOG)
		) then
			return true
		end
	end
		
	local function HasNearLog()
		for I=0, LEAVES_CHECK_DISTANCE do
			for Y=Coord.y - I, Coord.y + I do
				for Z=Coord.z - I, Coord.z + I do
					for X=Coord.x - I, Coord.x + I do
						if (BlockArea:GetBlockType(X, Y, Z) == E_BLOCK_SPONGE + I) then
							if (PROCESS_NEIGHBOR(X - 1, Y, Z, I)) then
								return true
							elseif (PROCESS_NEIGHBOR(X + 1, Y, Z, I)) then
								return true
							elseif (PROCESS_NEIGHBOR(X, Y, Z - 1, I)) then
								return true
							elseif (PROCESS_NEIGHBOR(X, Y, Z + 1, I)) then
								return true
							elseif (PROCESS_NEIGHBOR(X, Y + 1, Z, I)) then
								return true
							elseif (PROCESS_NEIGHBOR(X, Y - 1, Z, I)) then
								return true
							end
						end
					end
				end
			end
		end
		return false
	end
	
	if (not HasNearLog()) then
		World:DigBlock(Coord.x, Coord.y, Coord.z)
	end
end

return true