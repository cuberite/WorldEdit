
-- Region.lua

-- Implements the command handler that changes the world in a selection/region





function HandleAddLeavesCommand(a_Split, a_Player)
	-- //addleaves <LeafType>

	-- Parse the LeafType:
	local LeafType = a_Split[2]
	local LeafBlockType = 0
	local LeafBlockMeta = 0
	if (LeafType == "oak") then
		LeafBlockType = E_BLOCK_LEAVES
		LeafBlockMeta = 0
	elseif ((LeafType == "pine") or (LeafType == "spruce") or (LeafType == "conifer")) then
		LeafBlockType = E_BLOCK_LEAVES
		LeafBlockMeta = 1
	elseif (LeafType == "birch") then
		LeafBlockType = E_BLOCK_LEAVES
		LeafBlockMeta = 2
	elseif (LeafType == "jungle") then
		LeafBlockType = E_BLOCK_LEAVES
		LeafBlockMeta = 3
	elseif (LeafType == "acacia") then
		LeafBlockType = E_BLOCK_NEW_LEAVES
		LeafBlockMeta = 0
	elseif ((LeafType == "darkoak") or (LeafType == "dark")) then
		LeafBlockType = E_BLOCK_NEW_LEAVES
		LeafBlockMeta = 1
	else
		a_Player:SendMessage(cChatColor.Rose .. "Unknown leaf type: " .. (LeafType or "<no argument>").. ".")
		return true
	end

	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	-- Check with other plugins if the operation is okay:
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if (CallHook("OnAreaChanging", SrcCuboid, a_Player, World, "addleaves")) then
		return
	end

	-- Push an undo snapshot:
	State.UndoStack:PushUndoFromCuboid(World, SrcCuboid, "addleaves")

	-- Read the selected cuboid into a cBlockArea:
	local BA = cBlockArea()
	BA:Read(World, SrcCuboid)
	local MaxX, MaxY, MaxZ = BA:GetSize()
	MaxX = MaxX - 1
	MaxY = MaxY - 1
	MaxZ = MaxZ - 1

	-- Create an image for the leaves to be added at each log:
	--[[
	The image is like this:
	level 0 and 1:
	.xxx.
	xxxxx
	xxxxx
	xxxxx
	.xxx.

	level 2:
	.....
	..x..
	.xxx.
	..x..
	.....
	--]]
	local LeavesImg = cBlockArea()
	LeavesImg:Create(5, 3, 5)
	LeavesImg:FillRelCuboid(0, 4, 0, 1, 0, 4, cBlockArea.baTypes + cBlockArea.baMetas, LeafBlockType, LeafBlockMeta)
	LeavesImg:SetRelBlockType(0, 0, 0, 0)
	LeavesImg:SetRelBlockType(4, 0, 0, 0)
	LeavesImg:SetRelBlockType(0, 0, 4, 0)
	LeavesImg:SetRelBlockType(4, 0, 4, 0)
	LeavesImg:SetRelBlockType(0, 1, 0, 0)
	LeavesImg:SetRelBlockType(4, 1, 0, 0)
	LeavesImg:SetRelBlockType(0, 1, 4, 0)
	LeavesImg:SetRelBlockType(4, 1, 4, 0)
	LeavesImg:SetRelBlockTypeMeta(1, 2, 2, LeafBlockType, LeafBlockMeta)
	LeavesImg:SetRelBlockTypeMeta(2, 2, 1, LeafBlockType, LeafBlockMeta)
	LeavesImg:SetRelBlockTypeMeta(3, 2, 2, LeafBlockType, LeafBlockMeta)
	LeavesImg:SetRelBlockTypeMeta(2, 2, 3, LeafBlockType, LeafBlockMeta)
	LeavesImg:SetRelBlockTypeMeta(2, 2, 2, LeafBlockType, LeafBlockMeta)

	-- Process the block area - add leaves next to all log blocks:
	local LogBlock = E_BLOCK_LOG
	local NewLogBlock = E_BLOCK_NEW_LOG
	for y = 0, MaxY do
		for z = 0, MaxZ do
			for x = 0, MaxX do
				local BlockType = BA:GetRelBlockType(x, y, z)
				if ((BlockType == LogBlock) or (BlockType == NewLogBlock)) then
					BA:Merge(LeavesImg, x - 2, y, z - 2, cBlockArea.msFillAir)
				end
			end
		end
	end

	-- Write the block area back to world:
	BA:Write(World, BA:GetOrigin())

	-- Notify the other plugins of the change
	CallHook("OnAreaChanged", SrcCuboid, a_Player, World, "addleaves")
	return true
end





function HandleEllipsoidCommand(a_Split, a_Player)
	-- //ellipsoid [-h] <block>

	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	local BlockTypeIndex = 2
	local Hollow = false

	-- Check for hollow flag
	if (a_Split[2] == "-h") then
		Hollow = true
		BlockTypeIndex = 3
	end

	-- Check the params:
	if (a_Split[BlockTypeIndex] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //ellipsoid [-h] <BlockType>")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local DstBlockTable, ErrBlock = GetBlockDst(a_Split[BlockTypeIndex], a_Player)
	if not(DstBlockTable) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. ErrBlock .. "'.")
		return true
	end

	local Cuboid = State.Selection:GetSortedCuboid()
	local NumAffectedBlocks = CreateSphereInCuboid(a_Player, Cuboid, DstBlockTable, Hollow)

	a_Player:SendMessage(cChatColor.LightPurple .. NumAffectedBlocks .. " block(s) have been created")
	return true
end





function HandleFacesCommand(a_Split, a_Player)
	-- //faces <blocktype>

	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //faces <BlockType>")
		return true
	end

	local BlockTable, ErrBlock = GetBlockDst(a_Split[2], a_Player)
	if (not BlockTable) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown block: '" .. ErrBlock .. "'.")
		return true
	end

	-- Fill the selection:
	local NumBlocks = FillFaces(State, a_Player, a_Player:GetWorld(), BlockTable)
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end





function HandleLeafDecayCommand(a_Split, a_Player)
	-- //leafdecay

	local LEAVES_CHECK_DISTANCE = 6
	local PlayerState = GetPlayerState(a_Player)

	-- Check if the selected region is valid.
	if (not PlayerState.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	local SrcCuboid = PlayerState.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()

	-- Check if other plugins might want to block this action.
	if (CallHook("OnAreaChanging", SrcCuboid, a_Player, World, "leafdecay")) then
		return true
	end

	SrcCuboid:Expand(
		LEAVES_CHECK_DISTANCE, LEAVES_CHECK_DISTANCE,
		LEAVES_CHECK_DISTANCE, LEAVES_CHECK_DISTANCE,
		LEAVES_CHECK_DISTANCE, LEAVES_CHECK_DISTANCE
	)

	local BA = cBlockArea()
	BA:Read(World, SrcCuboid)

	local BA2 = cBlockArea()
	BA2:CopyFrom(BA)

	local SizeX, SizeY, SizeZ = BA:GetSize()
	SizeX, SizeY, SizeZ = SizeX - 1, SizeY - 1, SizeZ - 1

	local function ProcessLeaf(a_X, a_Y, a_Z, a_I)
		local BlockType = BA:GetRelBlockType(a_X, a_Y, a_Z)
		if ((BlockType == E_BLOCK_LEAVES) or (BlockType == E_BLOCK_NEW_LEAVES)) then
			BA:SetRelBlockType(a_X, a_Y, a_Z, E_BLOCK_SPONGE)
		else
			return
		end

		local I = a_I - 1
		if (I == 0) then
			return
		end

		ProcessLeaf(a_X - 1, a_Y, a_Z, I)
		ProcessLeaf(a_X + 1, a_Y, a_Z, I)
		ProcessLeaf(a_X, a_Y - 1, a_Z, I)
		ProcessLeaf(a_X, a_Y + 1, a_Z, I)
		ProcessLeaf(a_X, a_Y, a_Z - 1, I)
		ProcessLeaf(a_X, a_Y, a_Z + 1, I)
	end


	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				local BlockType = BA:GetRelBlockType(X, Y, Z)
				if ((BlockType == E_BLOCK_LOG) or (BlockType == E_BLOCK_NEW_LOG)) then
					ProcessLeaf(X - 1, Y, Z, LEAVES_CHECK_DISTANCE)
					ProcessLeaf(X + 1, Y, Z, LEAVES_CHECK_DISTANCE)
					ProcessLeaf(X, Y - 1, Z, LEAVES_CHECK_DISTANCE)
					ProcessLeaf(X, Y + 1, Z, LEAVES_CHECK_DISTANCE)
					ProcessLeaf(X, Y, Z - 1, LEAVES_CHECK_DISTANCE)
					ProcessLeaf(X, Y, Z + 1, LEAVES_CHECK_DISTANCE)
				end
			end
		end
	end

	SizeX, SizeY, SizeZ = SizeX - LEAVES_CHECK_DISTANCE, SizeY - LEAVES_CHECK_DISTANCE, SizeZ - LEAVES_CHECK_DISTANCE
	local NumChangedBlocks = 0
	for X = LEAVES_CHECK_DISTANCE, SizeX do
		for Y = LEAVES_CHECK_DISTANCE, SizeY do
			for Z = LEAVES_CHECK_DISTANCE, SizeZ do
				local BlockType = BA:GetRelBlockType(X, Y, Z)
				if ((BlockType == E_BLOCK_LEAVES) or (BlockType == E_BLOCK_NEW_LEAVES)) then
					BA2:SetRelBlockTypeMeta(X, Y, Z, E_BLOCK_AIR, 0)
					NumChangedBlocks = NumChangedBlocks + 1
				end
			end
		end
	end

	BA2:Write(World, SrcCuboid.p1)

	-- Notify the changes to other plugins
	CallHook("OnAreaChanged", SrcCuboid, a_Player, World, "leafdecay")

	a_Player:SendMessage(cChatColor.LightPurple .. "Removed " .. NumChangedBlocks .. " leaf block(s)")
	return true
end





function HandleMirrorCommand(a_Split, a_Player)
	-- //mirror <plane>

	-- Check params:
	local MirrorFn
	local Plane = a_Split[2]
	if ((Plane == "xy") or (Plane == "yx")) then
		MirrorFn = cBlockArea.MirrorXY
	elseif ((Plane == "xz") or (Plane == "zx")) then
		MirrorFn = cBlockArea.MirrorXZ
	elseif ((Plane == "yz") or (Plane == "zy")) then
		MirrorFn = cBlockArea.MirrorYZ
	else
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //mirror <plane>")
		a_Player:SendMessage(cChatColor.Rose .. "  plane can be one of: xy, xz, yx, yz, zx, zy")
		return true
	end

	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region selected")
		return true
	end

	-- Check with other plugins if the operation is okay:
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if (CallHook("OnAreaChanging", SrcCuboid, a_Player, World, "mirror")) then
		return
	end

	-- Push the selection to the undo stack:
	State:PushUndoInSelection(World, "mirror " .. Plane)

	-- Mirror the selection:
	local Area = cBlockArea()
	local Selection = cCuboid(State.Selection.Cuboid)  -- Make a copy of the selection cuboid
	Selection:Sort()
	Area:Read(World, Selection)
	MirrorFn(Area)
	Area:Write(World, Selection.p1)

	-- Notify other plugins of the change in the world
	CallHook("OnAreaChanged", SrcCuboid, a_Player, World, "mirror")

	-- Notify of success:
	a_Player:SendMessage(cChatColor.Rose .. "Selection mirrored")
	return true
end





function HandleStackCommand(a_Split, a_Player)
	-- //stack [Amount] [Direction]

	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	if (a_Split[2] ~= nil) and (tonumber(a_Split[2]) == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //stack [Blocks] [Direction]")
		return true
	end

	-- The amount of time the selection should be stacked
	local NumStacks = a_Split[2] or 1 -- Use the given amount or 1 if nil
	local Direction = string.lower(a_Split[3] or ((a_Player:GetPitch() > 70) and "down") or ((a_Player:GetPitch() < -70) and "up") or "forward")

	local SelectionCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()

	-- Read the selection
	local BA = cBlockArea()
	BA:Read(World, SelectionCuboid)

	local VectorDirection = Vector3i()
	local LookDirection = math.round((a_Player:GetYaw() + 180) / 90)

	-- Find the proper direction and set the VectorDirection using it.
	if (Direction == "up") then
		VectorDirection.y = BA:GetSizeY()
	elseif (Direction == "down") then
		VectorDirection.y = -BA:GetSizeY()
	elseif (Direction == "left") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			VectorDirection.x = BA:GetSizeY()
		elseif (LookDirection == E_DIRECTION_EAST) then
			VectorDirection.z = -BA:GetSizeZ()
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			VectorDirection.x = -BA:GetSizeX()
		elseif (LookDirection == E_DIRECTION_WEST) then
			VectorDirection.z = BA:GetSizeZ()
		end
	elseif (Direction == "right") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			VectorDirection.x = -BA:GetSizeX()
		elseif (LookDirection == E_DIRECTION_EAST) then
			VectorDirection.z = BA:GetSizeZ()
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			VectorDirection.x = BA:GetSizeX()
		elseif (LookDirection == E_DIRECTION_WEST) then
			VectorDirection.z = BA:GetSizeZ()
		end
	elseif (Direction == "south") then
		VectorDirection.z = BA:GetSizeZ()
	elseif (Direction == "east") then
		VectorDirection.x = BA:GetSizeX()
	elseif (Direction == "north") then
		VectorDirection.z = -BA:GetSizeZ()
	elseif (Direction == "west") then
		VectorDirection.x = -BA:GetSizeY()
	elseif ((Direction == "forward") or (Direction == "me")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			VectorDirection.z = BA:GetSizeZ()
		elseif (LookDirection == E_DIRECTION_EAST) then
			VectorDirection.x = BA:GetSizeX()
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			VectorDirection.z = -BA:GetSizeZ()
		elseif (LookDirection == E_DIRECTION_WEST) then
			VectorDirection.x = -BA:GetSizeX()
		end
	elseif ((Direction == "backwards") or (Direction == "back")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			VectorDirection.z = -BA:GetSizeZ()
		elseif (LookDirection == E_DIRECTION_EAST) then
			VectorDirection.x = -BA:GetSizeX()
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			VectorDirection.z = BA:GetSizeZ()
		elseif (LookDirection == E_DIRECTION_WEST) then
			VectorDirection.x = BA:GetSizeX()
		end
	else
		a_Player:SendMessage(cChatColor.Rose .. "Unknown direction \"" .. Direction .. "\".")
		return true
	end

	-- Create a cuboid that contains the complete area that is going to change
	local UndoStackCuboid = cCuboid(SelectionCuboid)
	UndoStackCuboid.p2 = UndoStackCuboid.p2 + (VectorDirection * NumStacks)
	UndoStackCuboid:Sort()

	-- Check other plugins if they agree
	if (CallHook("OnAreaChanging", UndoStackCuboid, a_Player, World, "stack")) then
		return true
	end

	-- Push the selection that is going to change into the UndoStack
	State.UndoStack:PushUndoFromCuboid(World, UndoStackCuboid)

	-- Stack the selection in the given Direction.
	local Pos = SelectionCuboid.p1 + VectorDirection
	for I=1, NumStacks do
		BA:Write(World, Pos)
		Pos = Pos + VectorDirection
	end

	-- Notify the plugins of the change in the world
	CallHook("OnAreaChanged", UndoStackCuboid, a_Player, World, "stack")

	a_Player:SendMessage(cChatColor.LightPurple .. BA:GetVolume() * VectorDirection:Length() .. " blocks changed. Undo with //undo")
	return true
end





function HandleReplaceCommand(a_Split, a_Player)
	-- //replace <srcblocktype> <dstblocktype>

	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	-- Check the params:
	local SrcBlockMask, SrcBlockErr, DstBlockSrc, DstBlockErr;
	if (a_Split[2] and not a_Split[3]) then
		SrcBlockMask, SrcBlockErr = cMask:new(nil, 0)
		DstBlockSrc, DstBlockErr = GetBlockDst(a_Split[2], a_Player)
	elseif (a_Split[2] and a_Split[3]) then
		SrcBlockMask, SrcBlockErr = cMask:new(a_Split[2])
		DstBlockSrc, DstBlockErr = GetBlockDst(a_Split[3], a_Player)
	else
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //replace <SrcBlockType> <DstBlockType>")
		return true
	end

	if (not SrcBlockMask) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown src block type: '" .. SrcBlockErr .. "'.")
		return true
	end

	if not(DstBlockSrc) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. DstBlockErr .. "'.")
		return true
	end

	-- Replace the blocks:
	local NumBlocks = ReplaceBlocksInCuboid(a_Player, State.Selection:GetSortedCuboid(), SrcBlockMask, DstBlockSrc, "replace")
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end





function HandleSetCommand(a_Split, a_Player)
	-- //set <blocktype>

	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //set <BlockType>")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local DstBlockTable, ErrBlock = GetBlockDst(a_Split[2], a_Player)
	if not(DstBlockTable) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. ErrBlock .. "'.")
		return true
	end

	-- Get the selected region of the player
	local Selection = State.Selection:GetSortedCuboid()

	-- Fill the selection:
	local NumBlocks = SetBlocksInCuboid(a_Player, Selection, DstBlockTable, "fill")
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end





function HandleVMirrorCommand(a_Split, a_Player)
	-- //vmirror

	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region selected")
		return true
	end

	-- Check with other plugins if the operation is okay:
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if (CallHook("OnAreaChanging", SrcCuboid, a_Player, World, "vmirror")) then
		return
	end

	-- Push the selection to the undo stack:
	State:PushUndoInSelection(World, "vmirror")

	-- Vert-mirror the selection:
	local Area = cBlockArea()
	local Selection = cCuboid(State.Selection.Cuboid)  -- Make a copy of the selection cuboid
	Selection:Sort()
	Area:Read(World, Selection)
	Area:MirrorXZ()
	Area:Write(World, Selection.p1)

	-- Notify the plugins of the succes
	CallHook("OnAreaChanged", SrcCuboid, a_Player, World, "vmirror")

	-- Notify the player of success:
	a_Player:SendMessage(cChatColor.LightPurple .. "Selection mirrored")
	return true
end





function HandleWallsCommand(a_Split, a_Player)
	-- //walls <blocktype>

	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end

	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //walls <BlockType>")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local DstBlockTable, ErrBlock = GetBlockDst(a_Split[2], a_Player)
	if not(DstBlockTable) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. ErrBlock .. "'.")
		return true
	end

	-- Fill the selection:
	local NumBlocks = FillWalls(State, a_Player, a_Player:GetWorld(), DstBlockTable)
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end
