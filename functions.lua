
-- functions.lua

-- Contains global functions.





-- Creates tables used to manage players actions or plugins
function InitializeTables()
	LeftClickCompassUsed = {}
	cRoot:Get():ForEachWorld(
		function(World)
			g_ExclusionAreaPlugins[World:GetName()] = {}
		end
	)
end





-- Returns the block type (and block meta) from a string. This can be something like "1", "1:0", "stone" and "stone:0"
function GetBlockTypeMeta(a_BlockString)
	local BlockID = tonumber(a_BlockString)
	
	-- Check if it was a normal number
	if (BlockID) then
		return BlockID, 0, true
	end
	
	-- Check if it was a name.
	local Item = cItem()
	if (not StringToItem(a_BlockString, Item)) then
		return false
	else
		return Item.m_ItemType, Item.m_ItemDamage
	end
	
	-- Check if it was an BlockType + Meta
	local Block = StringSplit(a_BlockString, ":")		
	if (not tonumber(Block[1])) then
		return false
	else
		if (not Block[2]) then
			return Block[1], 0
		else
			return Block[1], Block[2]
		end
	end
end





-- Rounds the number.
function math.round(a_GivenNumber)
	assert(type(a_GivenNumber) == 'number')
	
	local Number, Decimal = math.modf(a_GivenNumber)
	if Decimal >= 0.5 then
		return math.ceil(a_GivenNumber)
	else
		return Number
	end
end





-- Returns true if the given table is an array, otherwise it returns false
function table.isarray(a_Table)
	local i = 0
	for _, t in pairs(a_Table) do
		i = i + 1
		if (not rawget(a_Table, i)) then
			return false
		end
	end
	
	return true
end





-- Merges all values (except arrays) from a_DstTable into a_SrcTable if the key doesn't exist in a_SrcTable
function table.merge(a_SrcTable, a_DstTable)
	for Key, Value in pairs(a_DstTable) do
		if (not a_SrcTable[Key]) then
			a_SrcTable[Key] = Value
		elseif ((type(Value) == "table") and (type(a_SrcTable[Key]) == "table")) then
			if (not table.isarray(a_SrcTable[Key])) then
				table.merge(a_SrcTable[Key], Value)
			end
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
function CountBlocks(a_PlayerState, a_Player, a_World, a_BlockTable)
	-- Read the area:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	-- Replace the blocks:
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	local NumBlocks = 0
	
	for X = 0, XSize do
		for Y = 0, YSize do
			for Z = 0, ZSize do
				local BlockType, BlockMeta = Area:GetRelBlockTypeMeta(X, Y, Z)
				if (a_BlockTable[BlockType] and (a_BlockTable[BlockType].TypeOnly or a_BlockTable[BlockType].BlockMeta == BlockMeta)) then
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
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "walls")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "walls")

	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	
	-- Read the area into a cBlockArea
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	
	local NumDstBlocks = #a_DstBlockTable
	
	-- Place the walls
	for Y = 0, YSize do
		for X = 0, XSize do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, 0, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, ZSize, Block.BlockType, Block.BlockMeta)
		end
		
		-- The X for loop already did the 0 coordinate and ZSize so we don't have to do that here
		for Z = 1, ZSize - 1 do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(0, Y, Z, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(XSize, Y, Z, Block.BlockType, Block.BlockMeta)
		end
	end

	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	-- Calculate the number of changed blocks:
	local VolumeIncluding = (XSize + 1) * (YSize + 1) * (ZSize + 1)  -- Volume of the cuboid INcluding the walls
	local VolumeExcluding = (XSize - 1) * (YSize + 1) * (ZSize - 1)  -- Volume of the cuboid EXcluding the walls
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
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "faces")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "faces")

	-- Fill the faces:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	
	-- Read the area into a cBlockArea
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	
	local NumDstBlocks = #a_DstBlockTable
	
	-- Place the walls
	for Y = 0, YSize do
		for X = 0, XSize do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, 0, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(X, Y, ZSize, Block.BlockType, Block.BlockMeta)
		end
		
		-- The X for loop already did the 0 coordinate and ZSize so we don't have to do that here
		for Z = 1, ZSize - 1 do
			local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(0, Y, Z, Block.BlockType, Block.BlockMeta)
			
			Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
			Area:SetRelBlockTypeMeta(XSize, Y, Z, Block.BlockType, Block.BlockMeta)
		end
	end
	
	-- Place the ceiling and floor
	for Y = 0, YSize, ((YSize == 0 and 1) or YSize) do
		for X = 0, XSize do
			for Z = 0, ZSize do
				local Block = a_DstBlockTable[math.random(1, NumDstBlocks)]
				Area:SetRelBlockTypeMeta(X, Y, Z, Block.BlockType, Block.BlockMeta)
			end
		end
	end
	
	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	-- Calculate the number of changed blocks:
	local VolumeIncluding = (XSize + 1) * (YSize + 1) * (ZSize + 1)  -- Volume of the cuboid INcluding the faces
	local VolumeExcluding = (XSize - 1) * (YSize - 1) * (ZSize - 1)  -- Volume of the cuboid EXcluding the faces
	if (VolumeExcluding < 0) then
		VolumeExcluding = 0
	end
	return VolumeIncluding - VolumeExcluding
end





--- Fills the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillSelection(a_PlayerState, a_Player, a_World, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "fill")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "fill")

	-- Fill the selection:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	
	Area:Create(MaxX - MinX + 1, MaxY - MinY + 1, MaxZ - MinZ + 1)
	
	local SizeX, SizeY, SizeZ = Area:GetSize()
	SizeX, SizeY, SizeZ = SizeX - 1, SizeY - 1, SizeZ - 1

	local BlockTable = CalculateBlockChances(a_DstBlockTable)

	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				local RandomNumber = math.random()
				for Idx, Value in ipairs(BlockTable) do
					if (RandomNumber <= Value.Chance) then
						Area:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
						break
					end
				end
			end
		end
	end
	
	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	return (MaxX - MinX + 1) * (MaxY - MinY + 1) * (MaxZ - MinZ + 1)
end





--- Replaces the specified blocks in the selection stored in the specified cPlayerState
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
-- If a_TypeOnly is set, the block meta is ignored will be replaced
function ReplaceSelection(a_PlayerState, a_Player, a_World, a_SrcBlockTable, a_DstBlockTable)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "replace")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "replace")

	-- Read the area to be replaced:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	-- Read percents from the DstBlock table
	local MaxChance = 0
	for Idx, Value in ipairs(a_DstBlockTable) do
		MaxChance = MaxChance + Value.Chance
	end
	
	local BlockTable = {}
	local Temp = 0
	for Idx, Value in ipairs(a_DstBlockTable) do
		Temp = Temp + Value.Chance / MaxChance
		table.insert(BlockTable, {BlockType = Value.BlockType, BlockMeta = Value.BlockMeta, Chance = Temp})
	end
	
	-- Replace the blocks:
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	local NumBlocks = 0
	
	for X = 0, XSize do
		for Y = 0, YSize do
			for Z = 0, ZSize do
				local BlockType, BlockMeta = Area:GetRelBlockTypeMeta(X, Y, Z)
				if (a_SrcBlockTable[BlockType] and (a_SrcBlockTable[BlockType].TypeOnly or a_SrcBlockTable[BlockType].SrcBlockMeta == BlockMeta)) then
					local RandomNumber = math.random()
					for Idx, Value in ipairs(BlockTable) do
						if (RandomNumber <= Value.Chance) then
							Area:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
							NumBlocks = NumBlocks + 1
							break
						end
					end
				end
			end
		end
	end
	
	-- Write the area back to world:
	Area:Write(a_World, MinX, MinY, MinZ)
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	return NumBlocks
end




RetrieveBlockTypesTemp = {}
function RetrieveBlockTypes(Input)
	if (RetrieveBlockTypesTemp[Input] ~= nil) then
		return RetrieveBlockTypesTemp[Input]
	end
	
	local RawDstBlockTable = StringSplit(Input, ",")
	local BlockTable = {}
	for Idx, Value in ipairs(RawDstBlockTable) do
		-- Block chance
		local Chance = 100
		if (string.find(Value, "%", 1, true) ~= nil) then
			local SplittedValues = StringSplit(Value, "%")
			if (#SplittedValues ~= 2) then
				return false
			end
			Chance = tonumber(SplittedValues[1])
			Value = SplittedValues[2]
			
			if (Chance == nil) then
				return false
			end
		end
		
		local BlockType, BlockMeta, TypeOnly = GetBlockTypeMeta(Value)
		if not(BlockType) then
			return false
		end
		table.insert(BlockTable, {BlockType = BlockType, BlockMeta = BlockMeta, TypeOnly = TypeOnly or false, Chance = Chance})
	end
	
	RetrieveBlockTypesTemp[Input] = BlockTable
	return BlockTable
end





-- Calculate the chances for a block and returns the changed table. It is used for % params.
function CalculateBlockChances(BlockTable)
	local MaxChance = 0
	for Idx, Value in ipairs(BlockTable) do
		MaxChance = MaxChance + Value.Chance
	end
	
	local NewBlockTable = {}
	local Temp = 0
	for Idx, Value in ipairs(BlockTable) do
		Temp = Temp + Value.Chance / MaxChance
		table.insert(NewBlockTable, {BlockType = Value.BlockType, BlockMeta = Value.BlockMeta, Chance = Temp})
	end

	return NewBlockTable
end





-- Returns the coordinates (in a vector) from a block that the player has targeted. Returns nil if not block found.
function GetTargetBlock(a_Player)
	local MaxDistance = 150  -- A max distance of 150 blocks

	local FoundBlock = nil
	local Callbacks = {
		OnNextBlock = function(a_BlockX, a_BlockY, a_BlockZ, a_BlockType, a_BlockMeta)
			if (a_BlockType ~= E_BLOCK_AIR) then
				FoundBlock = { x = a_BlockX, y = a_BlockY, z = a_BlockZ }
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

	return Vector3i(FoundBlock.x, FoundBlock.y, FoundBlock.z)
end





-- Create a sphere at these coordinates. It uses ChunkStay to make sure the chunks are loaded. Returns the affected blocks count.
-- a_Player is the player who wants to place the sphere
-- a_Cuboid is the area where the sphere has to be placed in
-- a_BlockTable is a table containing all the blocks types/(metas) to place
-- a_IsHollow is a bool value if the sphere has to be hollow
-- a_Mask is either nil or a table containing the masked blocks
function CreateSphereInCuboid(a_Player, a_Cuboid, a_BlockTable, a_IsHollow, a_Mask)
	local World = a_Player:GetWorld()
	local ActionName = (a_IsHollow and "hsphere") or "sphere"
	
	-- Check if other plugins agree with the operation:
	if not(CheckAreaCallbacks(a_Cuboid, a_Player, World, ActionName)) then
		return 0
	end
	
	-- Create a table with all the chunks that will be affected
	local AffectedChunks = ListChunksForCuboid(a_Cuboid)

	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, a_Cuboid)

	-- Calculate the chances for all the blocks
	local BlockTable = CalculateBlockChances(a_BlockTable)
	local NumAffectedBlocks = 0
	
	local BlockArea = cBlockArea()
	World:ChunkStay(AffectedChunks, nil,
		function()
			-- Read the area
			BlockArea:Read(World, a_Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)
			
			local Radius = BlockArea:GetSizeX() / 2
			
			NumAffectedBlocks = cShapeGenerator.MakeSphere(BlockArea, BlockTable, Radius, a_IsHollow, a_Mask)

			-- Write the area back to world:
			BlockArea:Write(World, a_Cuboid.p1)
		end
	)
	return NumAffectedBlocks
end





-- Create a cylinder at these coordinates. Returns the affected blocks count.
-- a_Player is the player who wants to place the cylinder
-- a_Cuboid is the area where the cylinder has to be placed in
-- a_BlockTable is a table containing all the blocks types/(metas) to place
-- a_IsHollow is a bool value if the cylinder has to be hollow
-- a_Mask is either nil or a table containing the masked blocks
function CreateCylinderInCuboid(a_Player, a_Cuboid, a_BlockTable, a_IsHollow, a_Mask)
	local World = a_Player:GetWorld()
	
	local ActionName = (a_IsHollow and "hcyl") or "cyl"
	-- Check if other plugins agree with the operation:
	if not(CheckAreaCallbacks(a_Cuboid, a_Player, World, ActionName)) then
		return 0
	end
	
	-- Create a table with all the chunks that will be affected
	local AffectedChunks = ListChunksForCuboid(a_Cuboid)

	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, a_Cuboid)

	-- Calculate the chances for all the blocks
	local BlockTable = CalculateBlockChances(a_BlockTable)
	local NumAffectedBlocks = 0
	
	local BlockArea = cBlockArea()
	World:ChunkStay(AffectedChunks, nil,
		function()
			-- Read the area
			BlockArea:Read(World, a_Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)
			
			local Radius = BlockArea:GetSizeX() / 2
			
			NumAffectedBlocks = cShapeGenerator.MakeCylinder(BlockArea, BlockTable, Radius, a_IsHollow, a_Mask)

			-- Write the area back to world:
			BlockArea:Write(World, a_Cuboid.p1)
		end
	)
	return NumAffectedBlocks
end





-------------------------------------------
------------RIGHTCLICKCOMPASS--------------
-------------------------------------------
function RightClickCompass(Player)
	local World = Player:GetWorld()
	local Teleported = false
	local WentThroughBlock = false
	
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if (not cBlockInfo:IsTransparent(BlockType)) then
				WentThroughBlock = true
			else
				if (WentThroughBlock) then
					if (
						(BlockType == E_BLOCK_AIR) and
						(World:GetBlock(X, Y + 1, Z) == E_BLOCK_AIR) and
						(cBlockInfo:IsSolid(World:GetBlock(X, Y - 1, Z)) or Player:IsFlying())
					) then
						Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
						Teleported = true
						return true
					else
						for y = Y, 1, -1 do
							if cBlockInfo:IsSolid(World:GetBlock(X, y, Z)) then
								Player:TeleportToCoords(X + 0.5, y + 1, Z + 0.5)
								Teleported = true
								return true
							end
						end
					end
				end
			end
		end;
	};
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()	

	local Start = EyePos
	local End = EyePos + LookVector * g_Config.NavigationWand.MaxDistance
	
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	if not Teleported then
		Player:SendMessage(cChatColor.Rose .. "Nothing to pass through!")
	end
end


------------------------------------------
------------LEFTCLICKCOMPASS--------------
------------------------------------------
function LeftClickCompass(Player)
	local World = Player:GetWorld()
	local HasHit = false
	
	-- Remember the coords of the last checked block:
	local LastX = Player:GetPosX()
	local LastY = Player:GetPosY()
	local LastZ = Player:GetPosZ()
	
	-- Callback that checks whether the block on the traced line is non-solid:
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if BlockType ~= E_BLOCK_AIR and not cBlockInfo:IsOneHitDig(BlockType) then
				local IsValid, WorldHeight = World:TryGetHeight(X, Z)
				for y = Y, WorldHeight + 1 do
					if not cBlockInfo:IsSolid(World:GetBlock(X, y, Z)) then
						Y = y
						break
					end
				end
				Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
				HasHit = true
				return true
			end
			LastX = X
			LastY = Y
			LastZ = Z
		end
	};
	
	-- Trace the line from the player's eyes in their look direction:
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()
	local Start = EyePos
	local End = EyePos + LookVector * g_Config.NavigationWand.MaxDistance
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	
	-- If no block has been hit, teleport the player to the last checked block location (known non-solid):
	if not(HasHit) then
		if (g_Config.NavigationWand.TeleportNoHit) then
			Player:TeleportToCoords(LastX + 0.5, LastY, LastZ + 0.5)
		else
			Player:SendMessage(cChatColor.Rose .. "No block in sight (or too far)!")
		end
	end
	
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




