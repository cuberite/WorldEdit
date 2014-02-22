
-- cmd_functions.lua

-- Implements the helper functions that do the actual filling / replacing / blocktracing work





--- Fills the walls of the selection stored in the specified cPlayerState with the specified block type
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
function FillWalls(a_PlayerState, a_Player, a_World, a_BlockType, a_BlockMeta)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "walls")) then
		return
	end
	
	-- Push an Undo onto the stack:
	a_PlayerState:PushUndoInSelection(a_World, "walls")

	-- Fill the walls:
	local Area = cBlockArea()
	local MinX, MaxX = a_PlayerState.Selection:GetXCoordsSorted()
	local MinY, MaxY = a_PlayerState.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = a_PlayerState.Selection:GetZCoordsSorted()
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	Area:FillRelCuboid(0,     XSize, 0,     YSize, 0,     0,     cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- XY wall at MinZ
	Area:FillRelCuboid(0,     XSize, 0,     YSize, ZSize, ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- XY wall at MaxZ
	Area:FillRelCuboid(0,     0,     0,     YSize, 0,     ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- YZ wall at MinX
	Area:FillRelCuboid(XSize, XSize, 0,     YSize, 0,     ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- YZ wall at MinX
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
function FillFaces(a_PlayerState, a_Player, a_World, a_BlockType, a_BlockMeta)
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
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	Area:FillRelCuboid(0,     XSize, 0,     YSize, 0,     0,     cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- XY wall at MinZ
	Area:FillRelCuboid(0,     XSize, 0,     YSize, ZSize, ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- XY wall at MaxZ
	Area:FillRelCuboid(0,     0,     0,     YSize, 0,     ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- YZ wall at MinX
	Area:FillRelCuboid(XSize, XSize, 0,     YSize, 0,     ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- YZ wall at MinX
	Area:FillRelCuboid(0,     XSize, 0,     0,     0,     ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- XZ floor
	Area:FillRelCuboid(0,     XSize, YSize, YSize, 0,     ZSize, cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)  -- XZ ceiling
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
function FillSelection(a_PlayerState, a_Player, a_World, a_BlockType, a_BlockMeta)
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
	Area:Fill(cBlockArea.baTypes + cBlockArea.baMetas, a_BlockType, a_BlockMeta)
	Area:Write(a_World, MinX, MinY, MinZ)
	Area:Clear()
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	return (MaxX - MinX + 1) * (MaxY - MinY + 1) * (MaxZ - MinZ + 1)
end





--- Replaces the specified blocks in the selection stored in the specified cPlayerState
-- Returns the number of blocks changed, or no value if disallowed
-- The original contents are pushed onto PlayerState's Undo stack
-- If a_TypeOnly is set, the block meta is ignored and conserved
function ReplaceSelection(a_PlayerState, a_Player, a_World, a_SrcBlockType, a_SrcBlockMeta, a_DstBlockType, a_DstBlockMeta, a_TypeOnly)
	-- Check with other plugins if the operation is okay:
	if not(CheckAreaCallbacks(a_PlayerState.Selection:GetSortedCuboid(), a_Player, a_World, "replace")) then -- Check if the region intersects with any of the areas.
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
	
	-- Replace the blocks:
	local XSize = MaxX - MinX
	local YSize = MaxY - MinY
	local ZSize = MaxZ - MinZ
	local NumBlocks = 0
	if (a_TypeOnly) then
		for X = 0, XSize do
			for Y = 0, YSize do
				for Z = 0, ZSize do
					if (Area:GetRelBlockType(X, Y, Z) == a_SrcBlockType) then
						Area:SetRelBlockType(X, Y, Z, a_DstBlockType)
						NumBlocks = NumBlocks + 1
					end
				end
			end
		end
	else
		for X = 0, XSize do
			for Y = 0, YSize do
				for Z = 0, ZSize do
					local BlockType, BlockMeta = Area:GetRelBlockTypeMeta(X, Y, Z)
					if ((BlockType == a_SrcBlockType) and (BlockMeta == a_SrcBlockMeta)) then
						Area:SetRelBlockTypeMeta(X, Y, Z, a_DstBlockType, a_DstBlockMeta)
						NumBlocks = NumBlocks + 1
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





-------------------------------------------
------------RIGHTCLICKCOMPASS--------------
-------------------------------------------
function RightClickCompass(Player)
	local World = Player:GetWorld()
	local Teleported = false
	local WentThroughBlock = false
	
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if not g_BlockTransparent[BlockType] then
				WentThroughBlock = true
			else
				if WentThroughBlock then
					if BlockType == E_BLOCK_AIR and g_BlockIsSolid[World:GetBlock(X, Y - 1, Z)] then
						Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
						Teleported = true
						return true
					else
						for y = Y, 1, -1 do
							if g_BlockIsSolid[World:GetBlock(X, y, Z)] then
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
	local End = EyePos + LookVector * 75
	
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
	
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if BlockType ~= E_BLOCK_AIR and not g_BlockOneHitDig[BlockType] then
				local IsValid, WorldHeight = World:TryGetHeight(X, Z)
				for y = Y, WorldHeight + 1 do
					if not g_BlockIsSolid[World:GetBlock(X, y, Z)] then
						Y = y
						break
					end
				end
				Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
				HasHit = true
				return true
			end
		end
	};
	
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()
	
	local Start = EyePos
	local End = EyePos + LookVector * 75
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	return HasHit
end


------------------------------------------------
------------------HPOSSELECT--------------------
------------------------------------------------
function HPosSelect(Player, World)
	local hpos = nil
	local Callbacks = {
	OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
		if BlockType ~= E_BLOCK_AIR and not g_BlockOneHitDig[BlockType] then
			hpos = Vector3i(X, Y, Z)
			return true
		end
	end
	};
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()
	local Start = EyePos
	local End = EyePos + LookVector * 150
	
	if cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z) then
		return false
	end
	return true, hpos
end




