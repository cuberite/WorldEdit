
-- Selection.lua

-- Implements handlers for the selection-related commands





function HandleChunkCommand(a_Split, a_Player)
	-- //chunk
	
	-- Find the chunk boundaries.
	local ChunkX = a_Player:GetChunkX()
	local ChunkZ = a_Player:GetChunkZ()
	local MinX = ChunkX * 16
	local MinZ = ChunkZ * 16
	local MaxX = MinX + 15
	local MaxZ = MinZ + 15

	-- Update selection.
	local State = GetPlayerState(a_Player)
	State.Selection:SetFirstPoint(MinX, 0, MinZ)
	State.Selection:SetSecondPoint(MaxX, 255, MaxZ)
	
	-- Notify the player about the selection.
	State.Selection:NotifySelectionChanged()
	a_Player:SendMessage(cChatColor.LightPurple .. "Chunk selected: " .. ChunkX .. ", " .. ChunkZ)
	
	return true
end





function HandleCountCommand(a_Split, a_Player)
	-- //count <blocktype>
	
	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //count <BlockType>")
		return true
	end
	
	-- Retrieve the blocktypes from the params:
	local Mask, ErrBlock = cMask:new(a_Split[2])
	if not(Mask) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown block type: '" .. ErrBlock .. "'.")
		return true
	end
	
	-- Count the blocks:
	local NumBlocks = CountBlocksInCuboid(a_Player:GetWorld(), State.Selection:GetSortedCuboid(), Mask)
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Counted: " .. NumBlocks)
	return true
end





function HandleDeselectCommand(a_Split, a_Player)
	-- //desel
	
	local State = GetPlayerState(a_Player)
	State.Selection:Deselect()
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Selection cleared.")
	return true
end





function HandleDistrCommand(a_Split, a_Player)
	-- //distr
	
	-- TODO: -d option that separates data values.
	
	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No selection set")
		return true
	end
	
	-- Get selection information.
	local World = a_Player:GetWorld()
	local Area = cBlockArea()
	Area:Read(World, State.Selection:GetSortedCuboid())
	local SizeX, SizeY, SizeZ = Area:GetCoordRange()
	
	-- Count the blocks.
	local TotalCount = Area:GetVolume()
	local BlockCounts = {}
	
	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				local BlockType = Area:GetRelBlockType(X, Y, Z)
				BlockCounts[BlockType] = (BlockCounts[BlockType] or 0) + 1
			end
		end
	end
	
	-- Generate the output.
	-- Sort records by count.
	local SortedBlockCounts, Index = {}, 1
	for BlockType, BlockCount in pairs(BlockCounts) do
		SortedBlockCounts[Index] = {Type = BlockType, Count = BlockCount}
		Index = Index + 1
	end
	table.sort(SortedBlockCounts, function(Block1, Block2) return Block1.Count < Block2.Count end)
	
	-- Display them.
	a_Player:SendMessage(cChatColor.LightPurple .. "# total blocks: " .. TotalCount)
	for _, Block in ipairs(SortedBlockCounts) do
		local BlockName = ItemTypeToString(Block.Type)
		local Perc = 100 * Block.Count / TotalCount
		local Line = string.format("% 7d (%.3f%%) %s #%d", Block.Count, Perc, BlockName, Block.Type)
		a_Player:SendMessage(cChatColor.LightPurple .. Line)
	end
	
	return true
end





function HandleExpandContractCommand(a_Split, a_Player)
	-- //expand [Amount] [Direction]
	-- //contract [Amount] [Direction]
	
	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	if ((a_Split[1] == "//expand") and (a_Split[2] == "vert")) then
		State.Selection.Cuboid.p1.y = 0
		State.Selection.Cuboid.p2.y = 255
		State.Selection:NotifySelectionChanged()

		a_Player:SendMessage(cChatColor.LightPurple .. "Expanded the selection from top to bottom.")
		a_Player:SendMessage(cChatColor.LightPurple .. "Selection is now " .. State.Selection:GetSizeDesc())
		return true
	end
	
	if (a_Split[2] ~= nil) and (tonumber(a_Split[2]) == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: " .. a_Split[1] .. " [Blocks] [Direction]")
		return true
	end
	
	local NumBlocks = a_Split[2] or 1 -- Use the given amount or 1 if nil
	local Direction = string.lower(a_Split[3] or ((a_Player:GetPitch() > 70) and "down") or ((a_Player:GetPitch() < -70) and "up") or "forward")
	local SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ = 0, 0, 0, 0, 0, 0
	local LookDirection = math.round((a_Player:GetYaw() + 180) / 90)
	
	if ((Direction == "up") or (Direction == "u")) then
		AddMaxY = NumBlocks
	elseif ((Direction == "down") or (Direction == "d")) then
		SubMinY = NumBlocks
	elseif (Direction == "left") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			AddMaxX = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			SubMinZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			SubMinX = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			AddMaxZ = NumBlocks
		end
	elseif (Direction == "right") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			SubMinX = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			AddMaxZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			AddMaxX = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			SubMinZ = NumBlocks
		end
	elseif (Direction == "south") then
		AddMaxZ = NumBlocks
	elseif (Direction == "east") then
		AddMaxX = NumBlocks
	elseif (Direction == "north") then
		SubMinZ = NumBlocks
	elseif (Direction == "west") then
		SubMinX = NumBlocks
	elseif ((Direction == "forward") or (Direction == "me")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			AddMaxZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			AddMaxX = NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			SubMinZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			SubMinX = NumBlocks
		end
	elseif ((Direction == "backwards") or (Direction == "back")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			SubMinZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			SubMinX = NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			AddMaxZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			AddMaxX = NumBlocks
		end
	elseif (Direction == "walls") then
		AddMaxX = NumBlocks
		AddMaxZ = NumBlocks
		SubMinX = NumBlocks
		SubMinZ = NumBlocks
	elseif ((Direction == "all") or (Direction == "faces")) then
		AddMaxX = NumBlocks
		AddMaxY = NumBlocks
		AddMaxZ = NumBlocks
		SubMinX = NumBlocks
		SubMinY = NumBlocks
		SubMinZ = NumBlocks
	else
		a_Player:SendMessage(cChatColor.Rose .. "Unknown direction \"" .. Direction .. "\".")
		return true
	end
	
	if (a_Split[1] == "//contract") then
		SubMinX, AddMaxX = -AddMaxX, -SubMinX
		SubMinY, AddMaxY = -AddMaxY, -SubMinY
		SubMinZ, AddMaxZ = -AddMaxZ, -SubMinZ
	end

	-- Expand or contract the region
	State.Selection:Expand(SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ)
	a_Player:SendMessage(cChatColor.LightPurple .. a_Split[1]:sub(3, -1):ucfirst() .. "ed the selection.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Selection is now " .. State.Selection:GetSizeDesc())
	return true
end





function HandleHPosCommand(a_Split, a_Player)
	-- //hpos1
	-- //hpos2
	
	-- Get the block the player is looking at
	local TargetBlock, BlockFace = GetTargetBlock(a_Player)
	if (not TargetBlock) then
		return true
	end
	
	-- Determine the name of the point. If the command is //pos1 then "First", otherwise it's the second point
	local PointName = (a_Split[1] == "//hpos1") and "First" or "Second"
	
	local State = GetPlayerState(a_Player)
	
	-- Select the block:
	local Succes, Msg = State.Selection:SetPos(TargetBlock.x, TargetBlock.y, TargetBlock.z, BlockFace, PointName)
	a_Player:SendMessage(Msg)
	return true
end





function HandlePosCommand(a_Split, a_Player)
	-- //pos1
	-- //pos2
	
	-- Determine the name of the point. If the command is //pos1 then "First", otherwise it's the second point
	local PointName = (a_Split[1] == "//pos1") and "First" or "Second"
	local State = GetPlayerState(a_Player)
	local Pos = a_Player:GetPosition():Floor()
	local Succes, Msg = State.Selection:SetPos(Pos.x, Pos.y, Pos.z, BLOCK_FACE_TOP, PointName, true)
	
	-- We can assume that the action was a succes, since all the given parameters are known to be valid.
	a_Player:SendMessage(cChatColor.LightPurple .. Msg)
	return true
end





function HandleShiftCommand(a_Split, a_Player)
	-- //shift [Amount] [Direction]
	
	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	if (a_Split[2] ~= nil) and (tonumber(a_Split[2]) == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //shift [Blocks] [Direction]")
		return true
	end
	
	local NumBlocks = a_Split[2] or 1 -- Use the given amount or 1 if nil
	local Direction = string.lower(a_Split[3] or ((a_Player:GetPitch() > 70) and "down") or ((a_Player:GetPitch() < -70) and "up") or "forward")
	local X, Y, Z = 0, 0, 0
	local LookDirection = math.round((a_Player:GetYaw() + 180) / 90)
	
	if (Direction == "up") then
		Y = NumBlocks
	elseif (Direction == "down") then
		Y = -NumBlocks
	elseif (Direction == "left") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			X = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			Z = -NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			X = -NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			Z = NumBlocks
		end
	elseif (Direction == "right") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			X = -NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			Z = NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			X = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			Z = -NumBlocks
		end
	elseif (Direction == "south") then
		Z = NumBlocks
	elseif (Direction == "east") then
		X = NumBlocks
	elseif (Direction == "north") then
		Z = -NumBlocks
	elseif (Direction == "west") then
		X = -NumBlocks
	elseif ((Direction == "forward") or (Direction == "me")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			Z = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			X = NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			Z = -NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			X = -NumBlocks
		end
	elseif ((Direction == "backwards") or (Direction == "back")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			Z = -NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			X = -NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			Z = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			X = NumBlocks
		end
	else
		a_Player:SendMessage(cChatColor.Rose .. "Unknown direction \"" .. Direction .. "\".")
		return true
	end
	
	State.Selection:Move(X, Y, Z)
	a_Player:SendMessage(cChatColor.LightPurple .. "Region shifted.")
	return true
end





function HandleShrinkCommand(a_Split, a_Player)
	-- //shrink
	
	local State = GetPlayerState(a_Player)
	
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local BlockArea = cBlockArea()
	BlockArea:Read(a_Player:GetWorld(), SrcCuboid)
	local MinRelX, MinRelY, MinRelZ, MaxRelX, MaxRelY, MaxRelZ = BlockArea:GetNonAirCropRelCoords()
	
	-- Set the new points. This will not take the previous points in account. (For example p1 and p2 could get switched)
	State.Selection:SetFirstPoint(SrcCuboid.p1.x + MinRelX, SrcCuboid.p1.y + MinRelY, SrcCuboid.p1.z + MinRelZ)
	State.Selection:SetSecondPoint(SrcCuboid.p1.x + MaxRelX, SrcCuboid.p1.y + MaxRelY, SrcCuboid.p1.z + MaxRelZ)
	
	-- Send the change of the selection to the client
	State.Selection:NotifySelectionChanged()
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Region shrunk")
	return true
end





function HandleSizeCommand(a_Split, a_Player)
	-- //size
	
	local State = GetPlayerState(a_Player)
	if (not State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Please select a region first")
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "The selection size is " .. State.Selection:GetSizeDesc() .. ".")
	return true
end




