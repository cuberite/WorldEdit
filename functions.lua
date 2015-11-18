
-- functions.lua

-- Contains global functions.





-- Returns the block type (and block meta) from a string. This can be something like "1", "1:0", "stone" and "stone:0".
-- If a string with a percentage sign is given it will take the second half of the string (With "40%1:0" it uses only "1:0")
function GetBlockTypeMeta(a_BlockString)
	if (a_BlockString:find("%%")) then
		local ItemInfo = StringSplit(a_BlockString, "%")
		if (#ItemInfo ~= 2) then
			return false
		end
		
		a_BlockString = ItemInfo[2]
	end
	
	local BlockID = tonumber(a_BlockString)
	
	-- Check if it was a normal number
	if (BlockID) then
		return BlockID, 0, true
	end
	
	-- Check for block meta
	local HasMeta = string.find(a_BlockString, ":")

	-- Check if it was a name.
	local Item = cItem()
	if (not StringToItem(a_BlockString, Item)) then
		return false
	else
		if (HasMeta) then
			return Item.m_ItemType, Item.m_ItemDamage
		else
			return Item.m_ItemType, 0, true
		end
	end
end





-- Loads all the files in a folder with the lua or luac extension
function dofolder(a_Path)
	for Idx, FileName in ipairs(cFile:GetFolderContents(a_Path)) do
		local FilePath = a_Path .. "/" .. FileName
		if (cFile:IsFile(FilePath) and FileName:match("%.lua[c]?$")) then
			dofile(FilePath)
		end
	end
end





--- Returns a table of chunk coords for all chunks that insersect the given cuboid
-- The table is formatted for cWorld:ChunkStay():
-- { {Chunk1X, Chunk1z}, {Chunk2x, Chunk2z}, ... }
-- Assumes that the cuboid is sorted
function ListChunksForCuboid(a_Cuboid)
	-- Check the params:
	assert(tolua.type(a_Cuboid) == "cCuboid")
	
	-- Get the min / max chunk coords:
	local MinChunkX = math.floor(a_Cuboid.p1.x / 16)
	local MinChunkZ = math.floor(a_Cuboid.p1.z / 16)
	local MaxChunkX = math.floor((a_Cuboid.p2.x + 15.5) / 16)
	local MaxChunkZ = math.floor((a_Cuboid.p2.z + 15.5) / 16)
	
	-- Create the coords table:
	local res = {}
	local idx = 1
	for x = MinChunkX, MaxChunkX do for z = MinChunkZ, MaxChunkZ do
		res[idx] = {x, z}
		idx = idx + 1
	end end
	
	return res
end





--- Gets the number of blocks in that region.
function CountBlocksInCuboid(a_World, a_Cuboid, a_Mask)
	-- Make sure the cuboid is sorted
	if (not a_Cuboid:IsSorted()) then
		a_Cuboid:Sort()
	end
	
	-- Read the area:
	local Area = cBlockArea()
	Area:Read(a_World, a_Cuboid)
	
	-- Replace the blocks:
	local SizeX, SizeY, SizeZ = Area:GetCoordRange()
	local NumBlocks = 0
	
	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				if (a_Mask:Contains(Area:GetRelBlockTypeMeta(X, Y, Z))) then
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end
	
	return NumBlocks
end




--- Fills the walls of the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillWalls(a_PlayerState, a_Player, a_World, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if (CallHook("OnAreaChanging", a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "walls")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "walls")

	local Area = cBlockArea()
	local SrcCuboid = a_PlayerState.Selection:GetSortedCuboid()
	
	-- Read the area into a cBlockArea
	Area:Read(a_World, SrcCuboid, cBlockArea.baTypes + cBlockArea.baMetas)
	local SizeX, SizeY, SizeZ = Area:GetCoordRange()
	
	-- Place the walls
	for Y = 0, SizeY do
		for X = 0, SizeX do
			Area:SetRelBlockTypeMeta(X, Y, 0, a_DstBlockTable:Get(X, Y, 0))
			Area:SetRelBlockTypeMeta(X, Y, SizeZ, a_DstBlockTable:Get(X, Y, SizeZ))
		end
		
		-- The X for loop already did the 0 coordinate and ZSize so we don't have to do that here
		for Z = 1, SizeZ - 1 do
			Area:SetRelBlockTypeMeta(0, Y, Z, a_DstBlockTable:Get(0, Y, Z))
			Area:SetRelBlockTypeMeta(SizeX, Y, Z, a_DstBlockTable:Get(SizeX, Y, Z))
		end
	end

	Area:Write(a_World, SrcCuboid.p1)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(SrcCuboid.p1.x - 1, SrcCuboid.p2.x + 1, SrcCuboid.p1.y - 1, SrcCuboid.p2.y + 1, SrcCuboid.p1.z - 1, SrcCuboid.p2.z + 1)
	
	CallHook("OnAreaChanged", a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "walls")
	
	-- Calculate the number of changed blocks:
	local VolumeIncluding = (SizeX + 1) * (SizeY + 1) * (SizeZ + 1)  -- Volume of the cuboid INcluding the walls
	local VolumeExcluding = (SizeX - 1) * (SizeY + 1) * (SizeZ - 1)  -- Volume of the cuboid EXcluding the walls
	if (VolumeExcluding < 0) then
		VolumeExcluding = 0
	end
	return VolumeIncluding - VolumeExcluding
end





--- Fills the faces of the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillFaces(a_PlayerState, a_Player, a_World, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if (CallHook("OnAreaChanging", a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "faces")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "faces")

	-- Fill the faces:
	local Area = cBlockArea()
	local SrcCuboid = a_PlayerState.Selection:GetSortedCuboid()
	
	-- Read the area into a cBlockArea
	Area:Read(a_World, SrcCuboid, cBlockArea.baTypes + cBlockArea.baMetas)
	local SizeX, SizeY, SizeZ = Area:GetCoordRange()
	
	-- Place the walls
	for Y = 0, SizeY do
		for X = 0, SizeX do
			Area:SetRelBlockTypeMeta(X, Y, 0, a_DstBlockTable:Get(X, Y, 0))
			Area:SetRelBlockTypeMeta(X, Y, SizeZ, a_DstBlockTable:Get(X, Y, SizeZ))
		end
		
		-- The X for loop already did the 0 coordinate and ZSize so we don't have to do that here
		for Z = 1, SizeZ - 1 do
			Area:SetRelBlockTypeMeta(0, Y, Z, a_DstBlockTable:Get(0, Y, Z))
			Area:SetRelBlockTypeMeta(SizeX, Y, Z, a_DstBlockTable:Get(SizeX, Y, Z))
		end
	end
	
	-- Place the ceiling and floor
	for Y = 0, SizeY, ((SizeY == 0 and 1) or SizeY) do
		for X = 0, SizeX do
			for Z = 0, SizeZ do
				Area:SetRelBlockTypeMeta(X, Y, Z, a_DstBlockTable:Get(X, Y, Z))
			end
		end
	end
	
	Area:Write(a_World, SrcCuboid.p1)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(SrcCuboid.p1.x - 1, SrcCuboid.p2.x + 1, SrcCuboid.p1.y - 1, SrcCuboid.p2.y + 1, SrcCuboid.p1.z - 1, SrcCuboid.p2.z + 1)
	
	CallHook("OnAreaChanged", a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "faces")
	
	-- Calculate the number of changed blocks:
	local VolumeIncluding = (SizeX + 1) * (SizeY + 1) * (SizeZ + 1)  -- Volume of the cuboid INcluding the faces
	local VolumeExcluding = (SizeX - 1) * (SizeY - 1) * (SizeZ - 1)  -- Volume of the cuboid EXcluding the faces
	if (VolumeExcluding < 0) then
		VolumeExcluding = 0
	end
	return VolumeIncluding - VolumeExcluding
end





--- Fills the cuboid with the specified blocks
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function SetBlocksInCuboid(a_Player, a_Cuboid, a_DstBlockTable, a_Action)
	-- If no action was given we use "fill" as a default.
	a_Action = a_Action or "fill"
	
	-- Make sure the cuboid is sorted
	if (not a_Cuboid:IsSorted()) then
		a_Cuboid:Sort()
	end
	
	local World = a_Player:GetWorld()
	
	-- Check with other plugins if the operation is okay:
	if (CallHook("OnAreaChanging", a_Cuboid, a_Player, World, a_Action)) then
		return
	end
	
	-- Get the player state of the player
	local State = GetPlayerState(a_Player)
	
	-- Push an Undo onto the stack:
	State:PushUndoInSelection(World, a_Cuboid)
	
	-- Create a cBlockArea using the sizes of the cuboid
	local Area = cBlockArea()
	Area:Create(a_Cuboid:DifX() + 1, a_Cuboid:DifY() + 1, a_Cuboid:DifZ() + 1)
	local SizeX, SizeY, SizeZ = Area:GetCoordRange()

	-- Fill the selection:
	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				Area:SetRelBlockTypeMeta(X, Y, Z, a_DstBlockTable:Get(X, Y, Z))
			end
		end
	end
	
	-- Write the area in the world
	Area:Write(World, a_Cuboid.p1)
	Area:Clear()
	
	-- Notify the simulators
	World:WakeUpSimulatorsInArea(a_Cuboid.p1.x, a_Cuboid.p2.x, a_Cuboid.p1.y, a_Cuboid.p2.y, a_Cuboid.p1.z, a_Cuboid.p2.z)
	
	-- Notify the plugins
	CallHook("OnAreaChanged", a_Cuboid, a_Player, World, a_Action)
	
	return a_Cuboid:GetVolume()
end





--- Replaces the specified blocks in the selection stored in the specified cPlayerState
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function ReplaceBlocksInCuboid(a_Player, a_Cuboid, a_Mask, a_DstBlockTable, a_Action)
	local State = GetPlayerState(a_Player)
	local World = a_Player:GetWorld()
	
	-- Check with other plugins if the operation is okay:
	if (CallHook("OnAreaChanging", a_Cuboid, a_Player, World, a_Action)) then
		return
	end
	
	-- Push an Undo onto the stack:
	State.UndoStack:PushUndoFromCuboid(World, a_Cuboid)

	-- Read the area to be replaced:
	local Area = cBlockArea()
	Area:Read(World, a_Cuboid)
	
	-- Replace the blocks:
	local SizeX, SizeY, SizeZ = Area:GetCoordRange()
	local NumBlocks = 0
	
	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				if (a_Mask:Contains(Area:GetRelBlockTypeMeta(X, Y, Z))) then
					Area:SetRelBlockTypeMeta(X, Y, Z, a_DstBlockTable:Get(X, Y, Z))
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end
	
	-- Write the area back to world:
	Area:Write(World, a_Cuboid.p1)
	
	CallHook("OnAreaChanged", a_Cuboid, a_Player, World, a_Action)
	World:WakeUpSimulatorsInArea(a_Cuboid.p1.x, a_Cuboid.p2.x, a_Cuboid.p1.y, a_Cuboid.p2.y, a_Cuboid.p1.z, a_Cuboid.p2.z)
	
	return NumBlocks
end





local RetrieveBlockTypesTemp = {}
function RetrieveBlockTypes(Input)
	if (RetrieveBlockTypesTemp[Input] ~= nil) then
		return RetrieveBlockTypesTemp[Input]
	end
	
	local RawDstBlockTable = StringSplit(Input, ",")
	local BlockTable = {}
	for Idx, Value in ipairs(RawDstBlockTable) do
		-- Block chance
		local Chance = 1
		if (string.find(Value, "%", 1, true) ~= nil) then
			local SplittedValues = StringSplit(Value, "%")
			if (#SplittedValues ~= 2) then
				return false
			end
			Chance = tonumber(SplittedValues[1])
			Value = SplittedValues[2]
			
			if (Chance == nil) then
				return false, Value
			end
		end
		
		local BlockType, BlockMeta, TypeOnly = GetBlockTypeMeta(Value)
		if not(BlockType) then
			return false, Value
		end
		table.insert(BlockTable, {BlockType = BlockType, BlockMeta = BlockMeta, TypeOnly = TypeOnly or false, Chance = Chance})
	end
	
	RetrieveBlockTypesTemp[Input] = BlockTable
	return BlockTable
end





-- Chooses the best block destination class from the string. If only one block is set it uses the cConstantBlockTypeSource class, and if multiple are used it uses cRandomBlockTypeSource.
-- If the string is #clipboard or #copy it returns cClipboardBlockTypeSource.
function GetBlockDst(a_Blocks, a_Player)
	local Handler, Error
	
	if (a_Blocks:sub(1, 1) == "#") then
		if ((a_Blocks ~= "#clipboard") and (a_Blocks ~= "#copy")) then
			return false, "#clipboard or #copy is acceptable for patterns starting with #"
		end
		
		Handler, Error = cClipboardBlockTypeSource:new(a_Player)
	end
	
	if (not Handler and not Error) then
		local NumBlocks = #StringSplit(a_Blocks, ",")
		if (NumBlocks == 1) then
			Handler, Error = cConstantBlockTypeSource:new(a_Blocks)
		else
			Handler, Error = cRandomBlockTypeSource:new(a_Blocks)
		end
	end
	
	if (Error) then
		return false, Error
	end
	
	if (a_Player and not a_Player:HasPermission("worldedit.anyblock")) then
		local DoesContain, DisallowedBlock = Handler:Contains(g_Config.Limits.DisallowedBlocks)
		if (DoesContain) then
			return false, DisallowedBlock .. " isn't allowed"
		end
	end
	
	return Handler
end





-- Returns the coordinates (in a vector) from a block that the player has targeted. Returns nil if not block found.
function GetTargetBlock(a_Player)
	local MaxDistance = 150  -- A max distance of 150 blocks

	local FoundBlock = nil
	local BlockFace = BLOCK_FACE_NONE
	local Callbacks = {
		OnNextBlock = function(a_BlockX, a_BlockY, a_BlockZ, a_BlockType, a_BlockMeta, a_BlockFace)
			if (a_BlockType ~= E_BLOCK_AIR) then
				FoundBlock = { x = a_BlockX, y = a_BlockY, z = a_BlockZ }
				BlockFace = a_BlockFace
				return true
			end
		end
	};

	local EyePos = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	LookVector:Normalize()

	local Start = EyePos + LookVector + LookVector
	local End = EyePos + LookVector * MaxDistance

	local HitNothing = cLineBlockTracer.Trace(a_Player:GetWorld(), Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	if (HitNothing) then
		-- No block found
		return nil
	end

	return Vector3i(FoundBlock.x, FoundBlock.y, FoundBlock.z), BlockFace
end





-- Create a sphere at these coordinates. It uses ChunkStay to make sure the chunks are loaded. Returns the affected blocks count.
-- a_Player is the player who wants to place the sphere
-- a_Cuboid is the area where the sphere has to be placed in
-- a_BlockTable is a table containing all the blocks types/(metas) to place
-- a_IsHollow is a bool value if the sphere has to be hollow
-- a_Mask is either nil or a table containing the masked blocks
-- TODO: When generating above or under the chunks the affected blocks aren't right.
function CreateSphereInCuboid(a_Player, a_Cuboid, a_BlockTable, a_IsHollow, a_Mask)
	local World = a_Player:GetWorld()
	local ActionName = (a_IsHollow and "hsphere") or "sphere"
	
	-- Check if other plugins agree with the operation:
	if (CallHook("OnAreaChanging", a_Cuboid, a_Player, World, ActionName)) then
		return 0
	end
	
	if (not a_Cuboid:IsSorted()) then
		a_Cuboid:Sort()
	end
	
	-- Create a table with all the chunks that will be affected
	local AffectedChunks = ListChunksForCuboid(a_Cuboid)
	
	-- Variable that contains the ammount of blocks that have changed.
	local NumAffectedBlocks = 0
	
	-- If the Y values are below 0 or above 255 we have to cut it off.
	local CutBottom, CutTop = (a_Cuboid.p1.y > 0) and 0 or -a_Cuboid.p1.y, (a_Cuboid.p2.y < 255) and 0 or (a_Cuboid.p2.y - 255)
	a_Cuboid:ClampY(0, 255)
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, a_Cuboid)
	
	local BlockArea = cBlockArea()
	World:ChunkStay(AffectedChunks, nil,
		function()
			-- Read the area
			BlockArea:Read(World, a_Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)
			
			-- Add the missing layers so that the sphere generator generates a proper sphere.
			BlockArea:Expand(0, 0, CutBottom, CutTop, 0, 0)
			
			-- Create the sphere in the blockarea
			NumAffectedBlocks = cShapeGenerator.MakeSphere(BlockArea, a_BlockTable, a_IsHollow, a_Mask)
			
			-- Remove the layers that are above or under the minimum or maximum Y coordinates.
			BlockArea:Crop(0, 0, CutBottom, CutTop, 0, 0)

			-- Write the area back to world:
			BlockArea:Write(World, a_Cuboid.p1)
		end
	)
	
	CallHook("OnAreaChanged", a_Cuboid, a_Player, World, ActionName)
	return NumAffectedBlocks
end





-- Create a cylinder at these coordinates. Returns the affected blocks count.
-- a_Player is the player who wants to place the cylinder
-- a_Cuboid is the area where the cylinder has to be placed in
-- a_BlockTable is a table containing all the blocks types/(metas) to place
-- a_IsHollow is a bool value if the cylinder has to be hollow
-- a_Mask is either nil or a table containing the masked blocks
-- TODO: When generating above or under the chunks the affected blocks aren't right.
function CreateCylinderInCuboid(a_Player, a_Cuboid, a_BlockTable, a_IsHollow, a_Mask)
	local World = a_Player:GetWorld()
	local ActionName = (a_IsHollow and "hcyl") or "cyl"
	
	-- Check if other plugins agree with the operation:
	if (CallHook("OnAreaChanging", a_Cuboid, a_Player, World, ActionName)) then
		return 0
	end
	
	if (not a_Cuboid:IsSorted()) then
		a_Cuboid:Sort()
	end
	
	-- Create a table with all the chunks that will be affected
	local AffectedChunks = ListChunksForCuboid(a_Cuboid)

	-- If the Y values are below 0 or above 255 we have to cut it off.
	local CutBottom, CutTop = (a_Cuboid.p1.y > 0) and 0 or -a_Cuboid.p1.y, (a_Cuboid.p2.y < 255) and 0 or (a_Cuboid.p2.y - 255)
	a_Cuboid:ClampY(0, 255)
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, a_Cuboid)

	-- Variable that contains the ammount of blocks that have changed.
	local NumAffectedBlocks = 0
	
	local BlockArea = cBlockArea()
	World:ChunkStay(AffectedChunks, nil,
		function()
			-- Read the area
			BlockArea:Read(World, a_Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)
			
			-- Add the missing layers so that the sphere generator generates a proper sphere.
			BlockArea:Expand(0, 0, CutBottom, CutTop, 0, 0)
			
			-- Create the cylinder in the blockarea
			NumAffectedBlocks = cShapeGenerator.MakeCylinder(BlockArea, a_BlockTable, a_IsHollow, a_Mask)

			-- Remove the layers that are above or under the minimum or maximum Y coordinates.
			BlockArea:Crop(0, 0, CutBottom, CutTop, 0, 0)
			
			-- Write the area back to world:
			BlockArea:Write(World, a_Cuboid.p1)
		end
	)
	
	CallHook("OnAreaChanged", a_Cuboid, a_Player, World, ActionName)
	return NumAffectedBlocks
end





-- Teleports a player in the direction he's looking to the first non-solid block it finds IF it went through at least one solid block.
-- returns true if teleported, otherwise it returns false.
function RightClickCompass(a_Player)
	local World = a_Player:GetWorld()
	local FreeSpot = nil
	local WentThroughBlock = false
	
	local Callbacks = {
		OnNextBlock = function(a_X, a_Y, a_Z, a_BlockType, a_BlockMeta)
			if (cBlockInfo:IsSolid(a_BlockType)) then
				-- The trace went through a solid block. We have to remember it, because we only teleport if the trace went through at least one solid block.
				WentThroughBlock = true
				return false
			end
			
			if (not WentThroughBlock) then
				-- The block isn't solid, but we didn't go through a solid block yet. Bail out.
				return false
			end
			
			-- Found a block that is not a solid block, but it already went through a solid block.
			FreeSpot = Vector3i(a_X, a_Y, a_Z)
			return true
		end;
	};
	
	local EyePos = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	LookVector:Normalize()	
	
	-- Start the trace at the position of the eyes
	local Start = EyePos
	local End = EyePos + LookVector * g_Config.NavigationWand.MaxDistance
	
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	
	if (not FreeSpot) then
		a_Player:SendMessage(cChatColor.Rose .. "Nothing to pass through!")
		return false
	end
	
	-- Teleport the player to the first solid block below the found coordinates
	for y = FreeSpot.y, 0, -1 do
		if (cBlockInfo:IsSolid(World:GetBlock(FreeSpot.x, y, FreeSpot.z))) then
			a_Player:TeleportToCoords(FreeSpot.x + 0.5, y + 1, FreeSpot.z + 0.5)
			return true
		end
	end
	
	-- No solid block below the found coordinates was found. Don't teleport the player at all.
	return false
end





-- Teleports a player in the direction he's looking at, to the first solid block in the trace, and then the first non-solid block above that.
-- returns true if the player is teleported, returns false otherwise.
function LeftClickCompass(a_Player)
	local World = a_Player:GetWorld()
	
	-- The first solid block to be found in the trace
	local BlockPos = false
	
	-- Callback that checks whether the block on the traced line is non-solid:
	local Callbacks = {
		OnNextBlock = function(a_X, a_Y, a_Z, a_BlockType, a_BlockMeta)
			if (not cBlockInfo:IsSolid(a_BlockType)) then
				return false
			end
			
			BlockPos = Vector3i(a_X, a_Y, a_Z)
			return true
		end
	};
	
	-- Trace the line from the player's eyes in their look direction:
	local EyePos = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	LookVector:Normalize()
	
	local Start = EyePos
	local End = EyePos + LookVector * g_Config.NavigationWand.MaxDistance
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	
	-- If no block has been hit, teleport the player to the last checked block location (known non-solid):
	if (not BlockPos) then
		-- If configurated teleport the player to the last coordinates, otherwise send a message that it's too far.
		if (g_Config.NavigationWand.TeleportNoHit) then
			a_Player:TeleportToCoords(End.x + 0.5, End.y, End.z + 0.5)
		else
			a_Player:SendMessage(cChatColor.Rose .. "No block in sight (or too far)!")
		end
		
		return g_Config.NavigationWand.TeleportNoHit
	end
	
	local IsValid, Height = World:TryGetHeight(BlockPos.x, BlockPos.z)
	if (not IsValid) then
		return false
	end
	
	-- Find a block that isn't solid. The first one we find we teleport the player to.
	for Y = BlockPos.y, Height do
		if (not cBlockInfo:IsSolid(World:GetBlock(BlockPos.x, Y, BlockPos.z))) then
			a_Player:TeleportToCoords(BlockPos.x + 0.5, Y, BlockPos.z + 0.5)
			return true
		end
	end
	
	-- No non-solid block was found. This can happen when for example the highest block is 255.
	a_Player:TeleportToCoords(BlockPos.x + 0.5, Height + 1, BlockPos.z + 0.5)
	return true
end





--- Traces blocks in a line-of-sight of the player until it hits a non-air non-1-hit-dig block
-- Returns the coords of the block as a table {x = ..., y = ..., z = ... }
-- If nothing is hit within the specified distance, returns nil
function HPosSelect(a_Player, a_MaxDistance)
	assert(tolua.type(a_Player) == "cPlayer")
	a_MaxDistance = a_MaxDistance or 150
	
	-- Prepare the vectors to be used for the tracing:
	local Start = a_Player:GetEyePosition()
	local LookVector = a_Player:GetLookVector()
	LookVector:Normalize()
	local End = Start + LookVector * a_MaxDistance
	
	-- The callback checks the blocktype of the hit, saves coords if true hit and aborts:
	local hpos = nil
	local Callbacks =
	{
		OnNextBlock = function(a_X, a_Y, a_Z, a_BlockType, a_BlockMeta)
			if ((a_BlockType ~= E_BLOCK_AIR) and not(cBlockInfo:IsOneHitDig(a_BlockType))) then
				hpos = {x = a_X, y = a_Y, z = a_Z }
				return true
			end
		end
	}
	
	-- Trace:
	if (cLineBlockTracer.Trace(a_Player:GetWorld(), Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)) then
		-- Nothing reached within the distance, return nil for failure
		return nil
	end
	return hpos
end




