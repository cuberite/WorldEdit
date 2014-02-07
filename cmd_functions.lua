-------------------------------------------------
---------------CREATEWALLSFUNCTION---------------
-------------------------------------------------
function HandleCreateWalls(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- Get the right X, Y and Z coordinates
	if CheckIfInsideAreas(OneX, TwoX, OneY, TwoY, OneZ, TwoZ, Player, World, "walls") then -- Check if the region intersects with any of the areas.
		return false
	end
	
	local PlayerName = Player:GetName()
	
	LastCoords[PlayerName] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. World:GetName()
	PersonalUndo[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	PersonalBlockArea[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	local Blocks = (2 * (PersonalBlockArea[PlayerName]:GetSizeX() - 1 + PersonalBlockArea[PlayerName]:GetSizeZ() - 1) * PersonalBlockArea[PlayerName]:GetSizeY()) -- Calculate the amount if blocks that are going to change
	if Blocks == 0 then -- if the wall is 1x1x1 then the amout of blocks changed are 1
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[PlayerName]:GetSizeX() - 1
	local YY = PersonalBlockArea[PlayerName]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[PlayerName]:GetSizeZ() - 1
	
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:Write(World, OneX, OneY, OneZ) -- Write the region into the world
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return Blocks
end


-------------------------------------------------
---------------CREATEFACESFUNCTION---------------
-------------------------------------------------
function HandleCreateFaces(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- get the coordinates
	
	if CheckIfInsideAreas(OneX, TwoX, OneY, TwoY, OneZ, TwoZ, Player, World, "faces") then -- Check if the region intersects with any of the areas.
		return false
	end
	
	local PlayerName = Player:GetName()
	
	LastCoords[PlayerName] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. World:GetName()
	PersonalUndo[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	PersonalBlockArea[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- read the area
	local Blocks = (2 * (PersonalBlockArea[PlayerName]:GetSizeX() - 1 + PersonalBlockArea[PlayerName]:GetSizeZ() - 1) * PersonalBlockArea[PlayerName]:GetSizeY()) -- calculate the amount of changed blocks.
	if Blocks == 0 then
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[PlayerName]:GetSizeX() - 1
	local YY = PersonalBlockArea[PlayerName]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[PlayerName]:GetSizeZ() - 1
	
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta) -- Walls
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, Y, Y, Z, ZZ, 3, BlockType, BlockMeta) -- Floor
	PersonalBlockArea[PlayerName]:FillRelCuboid(X, XX, YY, YY, Z, ZZ, 3, BlockType, BlockMeta) -- Ceiling

	PersonalBlockArea[PlayerName]:Write(World, OneX, OneY, OneZ) -- write the area in the world.
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return Blocks
end


------------------------------------------------
------------------FILLFUNCTION------------------
------------------------------------------------
function HandleFillSelection(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player)
	
	if CheckIfInsideAreas(OneX, TwoX, OneY, TwoY, OneZ, TwoZ, Player, World, "fill") then -- Check if the region intersects with any of the areas.
		return false
	end
	
	local PlayerName = Player:GetName()
	
	LastCoords[PlayerName] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. World:GetName()
	PersonalUndo[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	PersonalBlockArea[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- read the area
	PersonalBlockArea[PlayerName]:Fill(3, BlockType, BlockMeta) -- fill the area with the right blocks
	PersonalBlockArea[PlayerName]:Write(World, OneX, OneY, OneZ) -- write the area in the world
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return GetSize(Player)
end


-------------------------------------------------
-----------------REPLACEFUNCTION-----------------
-------------------------------------------------
function HandleReplaceSelection(Player, World, ChangeBlockType, ChangeBlockMeta, ToChangeBlockType, ToChangeBlockMeta, TypeOnly)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player)
	
	if CheckIfInsideAreas(OneX, TwoX, OneY, TwoY, OneZ, TwoZ, Player, World, "replace") then -- Check if the region intersects with any of the areas.
		return false
	end
	
	local Blocks = 0
	local PlayerName = Player:GetName()
	
	LastCoords[PlayerName] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	PersonalBlockArea[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- Read the area
	
	local XSize = PersonalBlockArea[PlayerName]:GetSizeX() - 1
	local YSize = PersonalBlockArea[PlayerName]:GetSizeY() - 1
	local ZSize = PersonalBlockArea[PlayerName]:GetSizeZ() - 1
	for X=0, XSize do
		for Y=0, YSize do
			for Z=0, ZSize do
				if PersonalBlockArea[PlayerName]:GetRelBlockType(X, Y, Z) == ChangeBlockType then -- if the blocktype is the same as the block that needs to change then
					if PersonalBlockArea[PlayerName]:GetRelBlockMeta(X, Y, Z) == ChangeBlockMeta or (TypeOnly) then -- check if the blockmeta is the same as the meta that has to change
						PersonalBlockArea[PlayerName]:SetRelBlockType(X, Y, Z, ToChangeBlockType) -- change the block
						PersonalBlockArea[PlayerName]:SetRelBlockMeta(X, Y, Z, ToChangeBlockMeta) -- change the meta
						Blocks = Blocks + 1 -- add a 1 to the amount of changed blocks.
					end
				end
			end
		end
	end
	PersonalBlockArea[PlayerName]:Write(World, OneX, OneY, OneZ) -- write the area into the world.
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return Blocks
end


-------------------------------------------
------------RIGHTCLICKCOMPASS--------------
-------------------------------------------
function RightClickCompass(Player, World)
	local Teleported = false
	local WentThroughBlock = false
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if BlockType ~= E_BLOCK_AIR then
				WentThroughBlock = true
			else
				if WentThroughBlock then
					if BlockType == E_BLOCK_AIR and World:GetBlock(X, Y - 1, Z) ~= E_BLOCK_AIR then
						Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
						Teleported = true
						return true
					else
						for y = Y, 1, -1 do
							if World:GetBlock(X, y, Z) ~= E_BLOCK_AIR then
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

	local Start = EyePos + LookVector + LookVector;
	local End = EyePos + LookVector * 75
	
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	if not Teleported then
		Player:SendMessage(cChatColor.Rose .. "Nothing to pass through!")
	end
end


------------------------------------------
------------LEFTCLICKCOMPASS--------------
------------------------------------------
function LeftClickCompass(Player, World)
	local HasHit = false
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if BlockType ~= E_BLOCK_AIR and not g_BlockOneHitDig[BlockType] then
				for y = Y, World:GetHeight(X, Z) + 1 do
					if World:GetBlock(X, y, Z) == E_BLOCK_AIR then
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
	
	local Start = EyePos + LookVector + LookVector;
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
	local Start = EyePos + LookVector + LookVector;
	local End = EyePos + LookVector * 150
	
	if cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z) then
		return false
	end
	return true, hpos
end