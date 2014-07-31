
-- cmd_AlterLandscape.lua

-- Implements the commands and functions for altering the landscape





--- Common code for RemoveAbove and RemoveBelow
-- Checks with plugins if the operation is allowed
-- Pushes the column in Undo stack
-- Removes the blocks
-- a_Cuboid is expected to be sorted
-- Returns true if successful, false if not
function RemoveColumnPart(a_Player, a_Cuboid, a_OperationName, a_UndoName)
	assert(tolua.type(a_Player) == "cPlayer")
	assert(tolua.type(a_Cuboid) == "cCuboid")
	assert(type(a_OperationName) == "string")
	assert(type(a_UndoName) == "string")
	
	-- Check if other plugins allow the operation:
	local World = a_Player:GetWorld()
	if not(CheckAreaCallbacks(a_Cuboid, a_Player, World, a_OperationName)) then
		return false
	end
	
	-- Push in Undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, a_Cuboid, a_UndoName)
	
	-- Clear the blocks by writing an empty cBlockArea over them:
	local Area = cBlockArea()
	Area:Create(a_Cuboid:DifX() + 1, a_Cuboid:DifY() + 1, a_Cuboid:DifZ() + 1, cBlockArea.baTypes + cBlockArea.baMetas)
	Area:Write(World, a_Cuboid.p1)
	Area:Clear()
	return true
end





function HandleRemoveBelowCommand(a_Split, a_Player)
	-- //removebelow
	
	local X = math.floor(a_Player:GetPosX())
	local Y = math.floor(a_Player:GetPosY())
	local Z = math.floor(a_Player:GetPosZ())
	local Cuboid = cCuboid(X, 1, Z, X, Y, Z)
	
	if (RemoveColumnPart(a_Player, Cuboid, "removebelow", "//removebelow")) then
		a_Player:SendMessage(cChatColor.LightPurple .. Y + 1 .. " block(s) have been removed.")
	end
	return true
end





function HandleRemoveAboveCommand(a_Split, a_Player)
	-- //removeabove
	local X = math.floor(a_Player:GetPosX())
	local Y = math.floor(a_Player:GetPosY())
	local Z = math.floor(a_Player:GetPosZ())
	
	-- Try to determine the world height at this column:
	local IsValid, WorldHeight = a_Player:GetWorld():TryGetHeight(X, Z)
	if not(IsValid) then
		a_Player:SendMessage(cChatColor.LightPurple .. "0 block(s) have been removed.")
		return true
	end

	-- Remove the blocks:
	local Cuboid = cCuboid(X, Y, Z, X, WorldHeight, Z)
	if (RemoveColumnPart(a_Player, Cuboid, "removeabove", "//removeabove")) then
		a_Player:SendMessage(cChatColor.LightPurple .. WorldHeight - Y + 1 .. " block(s) have been removed.")
	end
	return true
end





-----------------------------------------------
---------------------DRAIN---------------------
-----------------------------------------------
function HandleDrainCommand(a_Split, a_Player)
	-- Check the radius parameter:
	local Radius = tonumber(a_Split[2])
	if (Radius == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //drain <radius>")
		return true
	end
	
	-- Check if other plugins allow the operation:
	local X = math.floor(a_Player:GetPosX())
	local Y = math.floor(a_Player:GetPosY())
	local Z = math.floor(a_Player:GetPosZ())
	local Cuboid = cCuboid(X - Radius, Y - Radius, Z - Radius, X + Radius, Y + Radius, Z + Radius)
	Cuboid:ClampY(0, 255)
	if not(CheckAreaCallbacks(Cuboid, a_Player, a_Player:GetWorld(), "drain")) then
		return true
	end
	
	-- TODO: Do a proper areafill algorithm (BFS / DFS) to replace only the connected bodies of fluid,
	-- instead of replacing everything in the area
	
	-- Push the area to Undo stack:
	local State = GetPlayerState(a_Player)
	local World = a_Player:GetWorld()
	State.UndoStack:PushUndoFromCuboid(World, Cuboid, "drain")
	
	-- Process the area around the player using a cBlockArea:
	local BlockArea = cBlockArea()
	BlockArea:Read(World, Cuboid)
	local NumBlocks = 0
	for y = 0, BlockArea:GetSizeY() - 1 do
		for z = 0, BlockArea:GetSizeZ() - 1 do
			for x = 0, BlockArea:GetSizeX() - 1 do
				local BlockType = BlockArea:GetRelBlockType(x, y, z)
				if ((BlockType == E_BLOCK_WATER) or (BlockType == E_BLOCK_STATIONARY_WATER)) then
					BlockArea:SetRelBlockType(x, y, z, 0) -- set the block to air
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end
	BlockArea:Write(World, Cuboid.p1)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) changed.")
	return true
end





------------------------------------------------
-------------------EXTINGUISH-------------------
------------------------------------------------
function HandleExtinguishCommand(Split, Player)
	if Split[2] == nil then
		Player:SendMessage(cChatColor.Rose .. "usage: /ex [Radius]")
		return true
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage(cChatColor.Rose .. 'Number expected; string "' .. Split[2] .. '" given')
		return true
	else
		Radius = tonumber(Split[2])
	end
	local MinX = math.floor(Player:GetPosX()) - Radius
	local MinY = math.floor(Player:GetPosY()) - Radius
	local MinZ = math.floor(Player:GetPosZ()) - Radius
	local MaxX = math.floor(Player:GetPosX()) + Radius
	local MaxY = math.floor(Player:GetPosY()) + Radius
	local MaxZ = math.floor(Player:GetPosZ()) + Radius
	
	if CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, Player, Player:GetWorld(), "extinguish") then
		return true
	end
	
	local BlockArea = cBlockArea()
	BlockArea:Read(Player:GetWorld(), MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	for X=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			for Z=0, BlockArea:GetSizeZ() - 1 do
				if BlockArea:GetRelBlockType(X, Y, Z) == 51 then
					BlockArea:SetRelBlockType(X, Y, Z, 0)
				end
			end
		end
	end
	BlockArea:Write(Player:GetWorld(), MinX, MinY, MinZ)
	return true
end


-------------------------------------------------
----------------------GREEN----------------------
-------------------------------------------------
function HandleGreenCommand(Split, Player)
	if tonumber(Split[2]) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//green <radius>")
		return true
	else
		Radius = tonumber(Split[2]) -- set the radius to the given radius
	end
	
	local World = Player:GetWorld()
	local MinX = math.floor(Player:GetPosX()) - Radius
	local MaxX = math.floor(Player:GetPosX()) + Radius
	local MinZ = math.floor(Player:GetPosZ()) - Radius
	local MaxZ = math.floor(Player:GetPosZ()) + Radius
	local YCheck = GetMultipleBlockChanges(MinX, MaxX, MinZ, MaxZ, Player, World, "green")
	local PossibleBlockChanges = {}
	
	for x=MinX, MaxX do
		for z=MinZ, MaxZ do
			local IsValid, y = World:TryGetHeight(x, z)
			if IsValid then
				YCheck:SetY(y)
				if World:GetBlock(x, y, z) == E_BLOCK_DIRT then -- if the block is dirt
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_GRASS})
				end
			end
		end
	end
	
	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(value.X, value.Y, value.Z, value.BlockType, 0)
		end
		Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. " surfaces greened.")
	end
	return true
end


------------------------------------------------
----------------------SNOW----------------------
------------------------------------------------
function HandleSnowCommand(Split, Player)	
	if tonumber(Split[2]) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//snow <radius>")
		return true
	else
		Radius = tonumber(Split[2]) -- set the radius to the given radius
	end
	
	local World = Player:GetWorld() -- Get the world the player is in
	local MinX = math.floor(Player:GetPosX()) - Radius
	local MaxX = math.floor(Player:GetPosX()) + Radius
	local MinZ = math.floor(Player:GetPosZ()) - Radius
	local MaxZ = math.floor(Player:GetPosZ()) + Radius
	local YCheck = GetMultipleBlockChanges(MinX, MaxX, MinZ, MaxZ, Player, World, "snow")
	local PossibleBlockChanges = {}
	
	for x=MinX, MaxX do
		for z=MinZ, MaxZ do
			local IsValid, y = World:TryGetHeight(x, z)
			if IsValid then
				YCheck:SetY(y)
				if World:GetBlock(x, y , z) == E_BLOCK_STATIONARY_WATER then -- check if the block is water
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_ICE})
				elseif World:GetBlock(x, y , z) == E_BLOCK_LAVA then -- check if the block is lava
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_OBSIDIAN})
				else
					if cBlockInfo:IsSnowable(World:GetBlock(x, y, z)) then
						table.insert(PossibleBlockChanges, {X = x, Y = y + 1, Z = z, BlockType = E_BLOCK_SNOW})
					end
				end
			end
		end
	end
	
	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(value.X, value.Y, value.Z, value.BlockType, 0)
		end
		Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. " surfaces covered. Let is snow~")
	end
	return true
end


------------------------------------------------
----------------------THAW----------------------
------------------------------------------------
function HandleThawCommand(Split, Player)
	if tonumber(Split[2]) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//thaw <radius>")
		return true
	else
		Radius = tonumber(Split[2]) -- set the radius to the given radius
	end
	
	local World = Player:GetWorld() -- Get the world the player is in
	local MinX = math.floor(Player:GetPosX()) - Radius
	local MaxX = math.floor(Player:GetPosX()) + Radius
	local MinZ = math.floor(Player:GetPosZ()) - Radius
	local MaxZ = math.floor(Player:GetPosZ()) + Radius
	local YCheck = GetMultipleBlockChanges(MinX, MaxX, MinZ, MaxZ, Player, World, "thaw")
	local PossibleBlockChanges = {}
	
	for x=MinX, MaxX do
		for z=MinZ, MaxZ do
			local IsValid, y = World:TryGetHeight(x, z)
			if IsValid then
				YCheck:SetY(y)
				if World:GetBlock(x, y, z) == E_BLOCK_SNOW then -- check if the block is snow
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_AIR})
				elseif World:GetBlock(x, y, z) == E_BLOCK_ICE then -- check if the block is ice
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_WATER})
				end
			end
		end
	end
	
	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(value.X, value.Y, value.Z, value.BlockType, 0)
		end
		Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. "  surfaces thawed")
	end
	return true
end


-----------------------------------------------
-------------------BIOMELIST-------------------
-----------------------------------------------
function HandleBiomeListCommand(Split, Player)
	if Split[2] == nil then -- if there was no page given then the page is 1
		Split[2] = 1 
	end
	if tonumber(Split[2]) == 1 then -- Page 1
		Player:SendMessage(cChatColor.Green .. "Page 1")
		Player:SendMessage("Ocean")
		Player:SendMessage("Plains")
		Player:SendMessage("Desert")
		Player:SendMessage("Extreme_Hills")
		Player:SendMessage("Forest")
		Player:SendMessage("Taiga")
		Player:SendMessage("Swampland")
		Player:SendMessage("River")
	elseif tonumber(Split[2]) == 2 then -- Page 2
		Player:SendMessage(cChatColor.Green .. "Page 2")
		Player:SendMessage("Hell")
		Player:SendMessage("Sky")
		Player:SendMessage("FrozenOcean")
		Player:SendMessage("FrozenRiver")
		Player:SendMessage("Ice_Plains")
		Player:SendMessage("Ice_Mountains")
		Player:SendMessage("MushroomIsland")
		Player:SendMessage("MushroomIslandShore")
	elseif tonumber(Split[2]) == 3 then -- Page 3
		Player:SendMessage(cChatColor.Green .. "Page 3")
		Player:SendMessage("Beach")
		Player:SendMessage("DesertHills")
		Player:SendMessage("ForestHills")
		Player:SendMessage("TaigaHills ")
		Player:SendMessage("Extreme_Hills_Edge")
		Player:SendMessage("Jungle")
		Player:SendMessage("JungleHills")
	else
		Player:SendMessage("/biomelist [1-3]") -- the page was not valid
	end
	return true
end


------------------------------------------------
--------------------SETBIOME--------------------
------------------------------------------------
function HandleSetBiomeCommand(Split, Player)
	local function SendWrongArguments(Reason)
		Player:SendMessage(cChatColor.Rose .. Reason .. " arguments.")
		Player:SendMessage(cChatColor.Rose .. "//setbiome [-p] <biome>")
		Player:SendMessage(cChatColor.Rose .. "") -- Extra space
		Player:SendMessage(cChatColor.Rose .. "Sets the biome of the region.")
		Player:SendMessage(cChatColor.Rose .. "By default sets the biome in your selected area.")
		Player:SendMessage(cChatColor.Rose .. "-p sets biome in the column you are currently standing in.")
	end
	
	if #Split == 1 then
		SendWrongArguments("Too few")
		return true
	end
	
	if #Split > 3 then
		SendWrongArguments("Too many")
		return true
	end
	
	local World = Player:GetWorld()
	local PosX = math.floor(Player:GetPosX())
	local PosZ = math.floor(Player:GetPosZ())
	
	if #Split == 3 then
		if Split[2] ~= "-p" then
			SendWrongArguments("Too many")
			return true
		end
		
		local NewBiome = StringToBiome(Split[3])
		if NewBiome == biInvalidBiome then
			Player:SendMessage(cChatColor.Rose .. "Unknown biome type: '" .. Split[3] .. "'.")
			return true
		end
		
		World:SetAreaBiome(PosX, PosX, PosZ, PosZ, NewBiome)
		Player:SendMessage(cChatColor.LightPurple .. "Biome changed to " .. Split[3] .. " at your current location.")
		return true
	elseif #Split == 2 then
		local NewBiome = StringToBiome(Split[2])
		if NewBiome == biInvalidBiome then
			Player:SendMessage(cChatColor.Rose .. "Unknown " .. Split[2] .. " biome type.")
			return true
		end
		
		local State = GetPlayerState(Player)
		if not(State.Selection:IsValid()) then
			Player:SendMessage(cChatColor.Rose .. "You need to select a region first.")
			return true
		end
		local MinX, MaxX = State.Selection:GetXCoordsSorted()
		local MinZ, MaxZ = State.Selection:GetZCoordsSorted()
			
		World:SetAreaBiome(MinX, MaxX, MinZ, MaxZ, NewBiome)
		Player:SendMessage(cChatColor.LightPurple .. "Biome changed to " .. Split[2] .. ". " .. (1 + MaxX - MinX) * (1 + MaxZ - MinZ) .. " columns affected.")
		return true
	end
	return true
end



------------------------------------------------
--------------------PUMPKINS--------------------
------------------------------------------------
function HandlePumpkinsCommand(Split, Player)
	if Split[2] == nil then
		Radius = 10
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage(cChatColor.Rose .. "invaild argument")
		return true
	else
		Radius = Split[2]
	end
	
	local PosX = math.floor(Player:GetPosX())
	local PosZ = math.floor(Player:GetPosZ())
	local World = Player:GetWorld()
	
	local YCheck = GetMultipleBlockChanges(PosX - Radius, PosX + Radius, PosZ - Radius, PosZ + Radius, Player, World, "pumpkins")
	local PossibleBlockChanges = {}
	
	for I=1, Radius * 2 do
		local X = PosX + math.random(-Radius, Radius)
		local Z = PosZ + math.random(-Radius, Radius)
		local IsValid, Y = World:TryGetHeight(X, Z)
		if IsValid then
			Y = Y + 1
			if World:GetBlock(X, Y - 1, Z) == E_BLOCK_GRASS or World:GetBlock(X, Y, Z) - 1 == E_BLOCK_DIRT then
				YCheck:SetY(Y)
				table.insert(PossibleBlockChanges, {X = X, Y = Y, Z = Z, BlockType = E_BLOCK_LOG, BlockMeta = 0})
				for i=1, math.random(1, 6) do
					X = X + math.random(-2, 2)
					Z = Z + math.random(-2, 2)
					Y = World:GetHeight(X, Z) + 1
					YCheck:SetY(Y)
					if World:GetBlock(X, Y - 1, Z) == E_BLOCK_GRASS or World:GetBlock(X, Y, Z) - 1 == E_BLOCK_DIRT then
						table.insert(PossibleBlockChanges, {X = X, Y = Y, Z = Z, BlockType = E_BLOCK_LEAVES, BlockMeta = 0})
					end
				end
				for i=1, math.random(1, 4) do
					X = X + math.random(-2, 2)
					Z = Z + math.random(-2, 2)
					if World:GetBlock(X, Y - 1, Z) == E_BLOCK_GRASS or World:GetBlock(X, Y, Z) - 1 == E_BLOCK_DIRT then
						table.insert(PossibleBlockChanges, {X = X, Y = Y, Z = Z, BlockType = E_BLOCK_PUMPKIN, BlockMeta = math.random(0, 3)})
					end
				end
			end
		end
	end
	
	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(value.X, value.Y, value.Z, value.BlockType, value.BlockMeta)
		end
		Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. " pumpkin patches created")
	end
	return true
end





function HandleSphereCommand(a_Split, a_Player)
	-- //sphere <BlockType> <Radius>
	
	-- Check the params:
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //sphere <BlockType> <Radius>")
		return true
	end
	
	-- Convert the blocktype param:
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	if not(BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown block type: \"" .. a_Split[2] .. "\"")
		return true
	end
	
	-- Convert the Radius param:
	local Radius = tonumber(a_Split[3])
	if not(Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Cannot convert radius \"" .. a_Split[3] .. "\" to a number.")
		return true
	end
	
	-- Check if other plugins agree with the operation:
	local World = a_Player:GetWorld()
	local PosX = math.floor(a_Player:GetPosX())
	local PosY = math.floor(a_Player:GetPosY())
	local PosZ = math.floor(a_Player:GetPosZ())
	local MinX, MaxX, MinY, MaxY, MinZ, MaxZ = PosX - Radius, PosX + Radius, PosY - Radius, PosY + Radius, PosZ - Radius, PosZ + Radius
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)
	if not(CheckAreaCallbacks(Cuboid, a_Player, World, "sphere")) then
		return true
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)
	
	-- Read the current contents of the world:
	local BlockArea = cBlockArea()
	BlockArea:Read(World, Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)

	-- Change blocks inside the sphere:
	local MidPoint = Vector3d(Radius, PosY - MinY, Radius)  -- Midpoint of the sphere, relative to the area
	local NumBlocks = 0
	local SqrRadius = Radius * Radius
	for Y = 0, Cuboid.p2.y - Cuboid.p1.y do  -- The Cuboid has been Y-clamped correctly, take advantage of that
		for Z = 0, 2 * Radius do
			for X = 0, 2 * Radius do
				local Distance = math.floor((MidPoint - Vector3d(X, Y, Z)):SqrLength())
				if (Distance <= SqrRadius) then
					BlockArea:SetRelBlockTypeMeta(X, Y, Z, BlockType, BlockMeta)
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end

	-- Write the area back to world:
	BlockArea:Write(World, MinX, MinY, MinZ)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) were affected.")
	return true
end





function HandleHSphereCommand(a_Split, a_Player)
	-- //hsphere <BlockType> <Radius>
	
	-- Check the number of params:
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //hsphere <BlockType> <Radius>")
		return true
	end
	
	-- Convert the blocktype param:
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	if not(BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown block type: \"" .. a_Split[2] .. "\"")
		return true
	end
	
	-- Convert the Radius param:
	local Radius = tonumber(a_Split[3])
	if not(Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Cannot convert radius \"" .. a_Split[3] .. "\" to a number.")
		return true
	end
	
	-- Check if other plugins agree with the operation:
	local World = a_Player:GetWorld()
	local PosX = math.floor(a_Player:GetPosX())
	local PosY = math.floor(a_Player:GetPosY())
	local PosZ = math.floor(a_Player:GetPosZ())
	local MinX, MaxX, MinY, MaxY, MinZ, MaxZ = PosX - Radius, PosX + Radius, PosY - Radius, PosY + Radius, PosZ - Radius, PosZ + Radius
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)
	if not(CheckAreaCallbacks(Cuboid, a_Player, World, "sphere")) then
		return true
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)
	
	-- Read the current contents of the world:
	local BlockArea = cBlockArea()
	BlockArea:Read(World, Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)

	-- Change blocks inside the sphere:
	local MidPoint = Vector3d(Radius, PosY - MinY, Radius)  -- Midpoint of the sphere, relative to the area
	local NumBlocks = 0
	for Y = 0, Cuboid.p2.y - Cuboid.p1.y do  -- The Cuboid has been Y-clamped correctly, take advantage of that
		for Z = 0, 2 * Radius do
			for X = 0, 2 * Radius do
				local Distance = math.floor((MidPoint - Vector3d(X, Y, Z)):Length())
				if (Distance == Radius) then
					BlockArea:SetRelBlockTypeMeta(X, Y, Z, BlockType, BlockMeta)
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end

	-- Write the area back to world:
	BlockArea:Write(World, MinX, MinY, MinZ)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) were affected.")
	return true
end





function HandlePyramidCommand(a_Split, a_Player)
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "//pyramid <block> <size>")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	if (not BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Block name '" .. a_Split[2] .. "' was not recognized.")
		return true
	end
	
	local Radius = tonumber(a_Split[3])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	
	local Pos = a_Player:GetPosition()
	local MinX, MaxX = Pos.x - Radius, Pos.x + Radius
	local MinY, MaxY = Pos.y, Pos.y + Radius
	local MinZ, MaxZ = Pos.z - Radius, Pos.z + Radius
	
	local World = a_Player:GetWorld()
	
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)
	if not(CheckAreaCallbacks(Cuboid, a_Player, World, "pyramid")) then
		return true
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)
	
	local BlockArea = cBlockArea()
	BlockArea:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	
	local Size = Radius * 2
	local AffectedBlocks = 0
	local Layer = 0
	for Y = 0, BlockArea:GetSizeY() do
		local AffectedSize = Size - Layer * 2
		AffectedBlocks = AffectedBlocks + AffectedSize * AffectedSize
		BlockArea:FillRelCuboid(0 + Layer, Size - Layer, Y, Y, 0 + Layer, Size - Layer, cBlockArea.baTypes + cBlockArea.baMetas, BlockType, BlockMeta)
		Layer = Layer + 1
	end
	
	BlockArea:Write(World, MinX, MinY, MinZ)
	a_Player:SendMessage(cChatColor.LightPurple .. AffectedBlocks .. " block(s) have been created.")
	
	return true
end





function HandleHPyramidCommand(a_Split, a_Player)
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "//pyramid <block> <size>")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	if (not BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Block name '" .. a_Split[2] .. "' was not recognized.")
		return true
	end
	
	local Radius = tonumber(a_Split[3])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	
	local Pos = a_Player:GetPosition()
	local MinX, MaxX = Pos.x - Radius, Pos.x + Radius
	local MinY, MaxY = Pos.y, Pos.y + Radius
	local MinZ, MaxZ = Pos.z - Radius, Pos.z + Radius
	
	local World = a_Player:GetWorld()
	
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)
	if not(CheckAreaCallbacks(Cuboid, a_Player, World, "pyramid")) then
		return true
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)
	
	local BlockArea = cBlockArea()
	BlockArea:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	
	local Size = Radius * 2
	local AffectedBlocks = 0
	local Layer = 0
	for Y = 0, BlockArea:GetSizeY() do
		local AffectedSize = Size - Layer * 2
		AffectedBlocks = AffectedBlocks + AffectedSize * 4
		BlockArea:FillRelCuboid(0 + Layer, Size - Layer, Y, Y, 0 + Layer, 0 + Layer, cBlockArea.baTypes + cBlockArea.baMetas, BlockType, BlockMeta)
		BlockArea:FillRelCuboid(0 + Layer, Size - Layer, Y, Y, Size - Layer, Size - Layer, cBlockArea.baTypes + cBlockArea.baMetas, BlockType, BlockMeta)
		BlockArea:FillRelCuboid(0 + Layer, 0 + Layer, Y, Y, 0 + Layer, Size - Layer, cBlockArea.baTypes + cBlockArea.baMetas, BlockType, BlockMeta)
		BlockArea:FillRelCuboid(Size - Layer, Size - Layer, Y, Y, 0 + Layer, Size - Layer, cBlockArea.baTypes + cBlockArea.baMetas, BlockType, BlockMeta)
		Layer = Layer + 1
	end
	
	BlockArea:Write(World, MinX, MinY, MinZ)
	a_Player:SendMessage(cChatColor.LightPurple .. AffectedBlocks .. " block(s) have been created.")
	
	return true
end





function HandleCylCommand(a_Split, a_Player)
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "//cyl <block> <radius> [height]")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	if (not BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Block name '" .. a_Split[2] .. "' was not recognized.")
		return true
	end
	
	local Radius = tonumber(a_Split[3])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	
	Radius = Round(Radius)
	
	local Height = tonumber(a_Split[4] or 1) - 1
	
	local Pos = a_Player:GetPosition()
	local MinX, MaxX = Pos.x - Radius, Pos.x + Radius
	local MinY, MaxY = Pos.y, Pos.y + Height
	local MinZ, MaxZ = Pos.z - Radius, Pos.z + Radius
	
	local World = a_Player:GetWorld()
	
	if (MinY > 254) then
		a_Player:SendMessage(cChatColor.LightPurple .. "0 block(s) have been created.")
		return true
	elseif (MaxY > 254) then
		MaxY = 254
	end
	
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)
	if not(CheckAreaCallbacks(Cuboid, a_Player, World, "cyl")) then
		return true
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)
	
	local BlockArea = cBlockArea()
	BlockArea:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	local Size = Radius * 2
	local MiddleVector = Vector3d(Radius, 0, Radius)
	local AffectedBlocks = 0
	for Y = 0, Height do
		for X = 0, Size do
			for Z = 0, Size do
				local TempVector = Vector3d(X, 0, Z)
				local Distance = math.floor((MiddleVector - TempVector):Length())

				if (Distance <= Radius) then
					BlockArea:SetRelBlockTypeMeta(X, Y, Z, BlockType, BlockMeta)
					AffectedBlocks = AffectedBlocks + 1
				end
			end
		end
	end
	
	BlockArea:Write(World, MinX, MinY, MinZ)
	a_Player:SendMessage(cChatColor.LightPurple .. AffectedBlocks .. " block(s) have been created.")
	return true
end





function HandleHCylCommand(a_Split, a_Player)
	-- //hcyl <BlockType> <Radius> [Height]
	
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "//hcyl <block> <radius> [height]")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	if (not BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Block name '" .. a_Split[2] .. "' was not recognized.")
		return true
	end
	
	local Radius = tonumber(a_Split[3])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	
	Radius = Round(Radius)
	
	local Height = tonumber(a_Split[4] or 1) - 1
	
	local Pos = a_Player:GetPosition()
	local MinX, MaxX = Pos.x - Radius, Pos.x + Radius
	local MinY, MaxY = Pos.y, Pos.y + Height
	local MinZ, MaxZ = Pos.z - Radius, Pos.z + Radius
	
	local World = a_Player:GetWorld()
	
	if (MinY > 254) then
		a_Player:SendMessage(cChatColor.LightPurple .. "0 block(s) have been created.")
		return true
	elseif (MaxY > 254) then
		MaxY = 254
	end
	
	local Cuboid = cCuboid(MinX, MinY, MinZ, MaxX, MaxY, MaxZ)
	Cuboid:ClampY(0, 255)
	if not(CheckAreaCallbacks(Cuboid, a_Player, World, "hcyl")) then
		return true
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)
	
	local BlockArea = cBlockArea()
	BlockArea:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)
	local Size = Radius * 2
	local MiddleVector = Vector3d(Radius, 0, Radius)
	local AffectedBlocks = 0
	for Y = 0, Height do
		for X = 0, Size do
			for Z = 0, Size do
				local TempVector = Vector3d(X, 0, Z)
				local Distance = math.floor((MiddleVector - TempVector):Length())

				if (Distance == Radius) then
					BlockArea:SetRelBlockTypeMeta(X, Y, Z, BlockType, BlockMeta)
					AffectedBlocks = AffectedBlocks + 1
				end
			end
		end
	end
	
	BlockArea:Write(World, MinX, MinY, MinZ)
	a_Player:SendMessage(cChatColor.LightPurple .. AffectedBlocks .. " block(s) have been created.")
	return true
end




