local LEAVES_CHECK_DISTANCE = 6

local a_Player, a_Split = ...

-- Check if the player has the right permission
if (not a_Player:HasPermission("worldedit.craftscript.LeafDecay")) then
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
if not(CheckAreaCallbacks(SrcCuboid, a_Player, World, "craftscript.LeafDecay")) then
	return true
end

-- SrcCuboid:Expand(
	-- LEAVES_CHECK_DISTANCE, LEAVES_CHECK_DISTANCE,
	-- LEAVES_CHECK_DISTANCE, LEAVES_CHECK_DISTANCE,
	-- LEAVES_CHECK_DISTANCE, LEAVES_CHECK_DISTANCE
-- )

local BA = cBlockArea()
BA:Read(World, SrcCuboid, cBlockArea.baTypes + cBlockArea.baMetas)

local BA2 = cBlockArea()
BA2:CopyFrom(BA)

local SizeX, SizeY, SizeZ = BA:GetSize()
SizeX, SizeY, SizeZ = SizeX - 1, SizeY - 1, SizeZ - 1

local function ProcessLeave(a_X, a_Y, a_Z, a_I)
	local BlockType = BA:GetRelBlockType(a_X, a_Y, a_Z)
	if ((BlockType == E_BLOCK_LEAVES) or (BlockType == E_BLOCK_NEW_LEAVES)) then
		BA:SetRelBlockType(a_X, a_Y, a_Z, E_BLOCK_SPONGE)
	end
	
	local I = a_I - 1
	if (I == 0) then
		return
	end
	
	ProcessLeave(a_X - 1, a_Y, a_Z, I)
	ProcessLeave(a_X + 1, a_Y, a_Z, I)
	ProcessLeave(a_X, a_Y - 1, a_Z, I)
	ProcessLeave(a_X, a_Y + 1, a_Z, I)
	ProcessLeave(a_X, a_Y, a_Z - 1, I)
	ProcessLeave(a_X, a_Y, a_Z + 1, I)
end
	

for X = 0, SizeX do
	for Y = 0, SizeY do
		for Z = 0, SizeZ do
			local BlockType = BA:GetRelBlockType(X, Y, Z)
			if ((BlockType == E_BLOCK_LOG) or (BlockType == E_BLOCK_NEW_LOG)) then
				ProcessLeave(X - 1, Y, Z, LEAVES_CHECK_DISTANCE)
				ProcessLeave(X + 1, Y, Z, LEAVES_CHECK_DISTANCE)
				ProcessLeave(X, Y - 1, Z, LEAVES_CHECK_DISTANCE)
				ProcessLeave(X, Y + 1, Z, LEAVES_CHECK_DISTANCE)
				ProcessLeave(X, Y, Z - 1, LEAVES_CHECK_DISTANCE)
				ProcessLeave(X, Y, Z + 1, LEAVES_CHECK_DISTANCE)
			end
		end
	end
end

for X = 0, SizeX do
	for Y = 0, SizeY do
		for Z = 0, SizeZ do
			local BlockType = BA:GetRelBlockType(X, Y, Z)
			if ((BlockType == E_BLOCK_LEAVES) or (BlockType == E_BLOCK_NEW_LEAVES)) then
				BA2:SetRelBlockTypeMeta(X, Y, Z, E_BLOCK_AIR, 0)
			end
		end
	end
end

BA2:Write(World, SrcCuboid.p1, cBlockArea.baTypes + cBlockArea.baMetas)
return true
