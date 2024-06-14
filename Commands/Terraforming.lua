
-- Terraforming.lua

-- Contains all the command handlers for the category Terraforming





function HandleDrainCommand(a_Split, a_Player)
	-- //drain <radius>

	-- Check the radius parameter:
	local Radius = tonumber(a_Split[2] or "")
	if (Radius == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //drain <radius>")
		return true
	end

	local Position = a_Player:GetPosition():Floor()
	local Cuboid = cCuboid(Position, Position)
	Cuboid:Expand(Radius, Radius, Radius, Radius, Radius, Radius)
	Cuboid:ClampY(0, 255)
	Cuboid:Sort()

	local World = a_Player:GetWorld()

	-- Check if other plugins want to block this action
	if (CallHook("OnAreaChanging", Cuboid, a_Player, World, "drain")) then
		return true
	end

	-- TODO: Do a proper areafill algorithm (BFS / DFS) to replace only the connected bodies of fluid,
	-- instead of replacing everything in the area

	-- Push the area to Undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid, "drain")

	-- Process the area around the player using a cBlockArea:
	local BlockArea = cBlockArea()
	BlockArea:Read(World, Cuboid)
	local SizeX, SizeY, SizeZ = BlockArea:GetCoordRange()

	-- The amount of changed blocks
	local NumBlocks = 0

	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				local BlockType = BlockArea:GetRelBlockType(X, Y, Z)
				if ((BlockType == E_BLOCK_LAVA) or (BlockType == E_BLOCK_STATIONARY_LAVA) or (BlockType == E_BLOCK_WATER) or (BlockType == E_BLOCK_STATIONARY_WATER)) then
					BlockArea:SetRelBlockType(X, Y, Z, E_BLOCK_AIR) -- set the block to air
					NumBlocks = NumBlocks + 1
				end
			end
		end
	end

	-- Write the block area back into the world
	BlockArea:Write(World, Cuboid.p1)

	-- Notify other plugins of the change
	CallHook("OnAreaChanged", Cuboid, a_Player, World, "drain")

	-- Send a message to the player with the amount of changed blocks
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) changed.")
	return true
end





function HandleExtinguishCommand(a_Split, a_Player)
	-- //extinguish <radius>
	-- /extinguish <radius>
	-- //ext <radius>
	-- /ext <radius>
	-- //ex <radius
	-- /ex <radius

	if a_Split[2] == nil then
		a_Player:SendMessage(cChatColor.Rose .. "usage: /ex [Radius]")
		return true
	elseif tonumber(a_Split[2]) == nil then
		a_Player:SendMessage(cChatColor.Rose .. 'Number expected; string "' .. a_Split[2] .. '" given')
		return true
	end

	local Radius   = tonumber(a_Split[2])
	local Position = a_Player:GetPosition():Floor()
	local Cuboid   = cCuboid(Position, Position)
	Cuboid:Expand(Radius, Radius, Radius, Radius, Radius, Radius)
	Cuboid:ClampY(0, 255)
	Cuboid:Sort()

	-- Remove all the fire in the area
	local NumAffectedBlocks = ReplaceBlocksInCuboid(a_Player, Cuboid, cMask:new("51"), GetBlockDst("0"), "extinguish")

	-- Send a message to the player
	a_Player:SendMessage(cChatColor.LightPurple .. NumAffectedBlocks .. " fire(s) put out")
	return true
end





function HandleGreenCommand(a_Split, a_Player)
	if tonumber(a_Split[2]) == nil or a_Split[2] == nil then -- check if the player gave a radius
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//green <radius>")
		return true
	end

	local Radius = tonumber(a_Split[2]) -- set the radius to the given radius

	local World = a_Player:GetWorld()
	local MinX = math.floor(a_Player:GetPosX()) - Radius
	local MaxX = math.floor(a_Player:GetPosX()) + Radius
	local MinZ = math.floor(a_Player:GetPosZ()) - Radius
	local MaxZ = math.floor(a_Player:GetPosZ()) + Radius
	local YCheck = GetMultipleBlockChanges(MinX, MaxX, MinZ, MaxZ, a_Player, World, "green")
	local PossibleBlockChanges = {}

	for x=MinX, MaxX do
		for z=MinZ, MaxZ do
			local IsValid, y = World:TryGetHeight(x, z)
			if IsValid then
				YCheck:SetY(y)
				if (World:GetBlock(Vector3i(x, y, z)) == E_BLOCK_DIRT) then -- if the block is dirt
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_GRASS})
				end
			end
		end
	end

	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(Vector3i(value.X, value.Y, value.Z), value.BlockType, 0)
		end
		a_Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. " surfaces greened.")
	end
	return true
end





function HandleFillrCommand(a_Split, a_Player)
	-- //fillr <block> <radius> [depth] [allowUp]

	if (#a_Split < 3) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few parameters!");
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //fillr <block> <radius> [depth] [allowUp]");
		return true;
	elseif (#a_Split > 5) then
		a_Player:SendMessage(cChatColor.Rose .. "Too many parameters! Unused parameters: " .. table.concat(a_Split, " ", 6));
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //fillr <block> <radius> [depth] [allowUp]");
		return true;
	end

	local blockDst, errorBlock = GetBlockDst(a_Split[2]);
	if (not blockDst) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. errorBlock .. "'.");
		return true;
	end

	local radius = tonumber(a_Split[3]);
	if (not radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	radius = math.floor(radius)

	local depth = radius;
	if (a_Split[4]) then
		depth = tonumber(a_Split[4]);
		if (not depth) then
			a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[4] .. "\" given.")
			return true
		end
	end

	local allowUp = true
	if (a_Split[5]) then
		if (a_Split[5]:lower() == "false") then
			allowUp = false
		elseif (a_Split[5]:lower() ~= "true") then
			a_Player:SendMessage(cChatColor.Rose .. "Boolean expected; string \"" .. a_Split[5] .. "\" given.")
			return true
		end
	end

	local playerPos = a_Player:GetPosition():Floor();
	playerPos.y = playerPos.y - 1
	local region = cCuboid(playerPos, playerPos)
	region:Expand(radius, radius, depth, 0, radius, radius)
	region:Sort();

	local numBlocks = FillRecursively(a_Player, region, blockDst, allowUp)

	a_Player:SendMessage(cChatColor.LightPurple .. numBlocks .. " blocks have changed")
	return true;
end





function HandleFillCommand(a_Split, a_Player)
	-- //fill <block> <radius> [depth]

	if (#a_Split < 3) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few parameters!");
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //fill <block> <radius> [depth]");
		return true;
	elseif (#a_Split > 4) then
		a_Player:SendMessage(cChatColor.Rose .. "Too many parameters! Unused parameters: " .. table.concat(a_Split, " ", 5));
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //fill <block> <radius> [depth]");
		return true;
	end

	local blockDst, errorBlock = GetBlockDst(a_Split[2]);
	if (not blockDst) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. errorBlock .. "'.");
		return true;
	end

	local radius = tonumber(a_Split[3]);
	if (not radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	radius = math.floor(radius)

	local depth = radius;
	if (a_Split[4]) then
		depth = tonumber(a_Split[4]);
		if (not depth) then
			a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[4] .. "\" given.")
			return true
		end
	end

	local playerPos = a_Player:GetPosition():Floor();
	playerPos.y = playerPos.y - 1
	local region = cCuboid(playerPos, playerPos)
	region:Expand(radius, radius, depth, 0, radius, radius)
	region:Sort();

	local numBlocks = FillNormal(a_Player, region, blockDst)

	a_Player:SendMessage(cChatColor.LightPurple .. numBlocks .. " blocks have changed")
	return true;
end





function HandleReplaceNearCommand(a_Split, a_Player)
	-- //replacenear <size> <from> <to>

	if (#a_Split < 4) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few parameters!")
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //replacenear <size> <from> <to>")
		return true
	elseif (#a_Split > 4) then
		a_Player:SendMessage(cChatColor.Rose .. "Too many parameters! Unused parameters: " .. table.concat(a_Split, " ", 5))
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //replacenear <size> <from> <to>")
		return true
	end

	local Radius = tonumber(a_Split[2])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[2] .. "\" given.")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local SrcBlockTable, ErrBlock = cMask:new(a_Split[3])
	if (not SrcBlockTable) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown src block type: '" .. ErrBlock .. "'.")
		return true
	end

	local DstBlockTable, ErrBlock = GetBlockDst(a_Split[4], a_Player)
	if (not DstBlockTable) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. ErrBlock .. "'.")
		return true
	end

	local Cuboid = cCuboid(a_Player:GetPosition():Floor(), a_Player:GetPosition():Floor())
	Cuboid:Expand(Radius, Radius, Radius, Radius, Radius, Radius)
	Cuboid:ClampY(0, 255)
	Cuboid:Sort()

	local NumBlocks = ReplaceBlocksInCuboid(a_Player, Cuboid, SrcBlockTable, DstBlockTable, "replacenear")
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")

	return true
end





function HandleSnowCommand(a_Split, a_Player)
	if tonumber(a_Split[2]) == nil or a_Split[2] == nil then -- check if the player gave a radius
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//snow <radius>")
		return true
	end

	local Radius = tonumber(a_Split[2]) -- set the radius to the given radius

	local World = a_Player:GetWorld() -- Get the world the player is in
	local MinX = math.floor(a_Player:GetPosX()) - Radius
	local MaxX = math.floor(a_Player:GetPosX()) + Radius
	local MinZ = math.floor(a_Player:GetPosZ()) - Radius
	local MaxZ = math.floor(a_Player:GetPosZ()) + Radius
	local YCheck = GetMultipleBlockChanges(MinX, MaxX, MinZ, MaxZ, a_Player, World, "snow")
	local PossibleBlockChanges = {}

	for x=MinX, MaxX do
		for z=MinZ, MaxZ do
			local IsValid, y = World:TryGetHeight(x, z)
			if IsValid then
				YCheck:SetY(y)
				if (World:GetBlock(Vector3i(x, y , z)) == E_BLOCK_STATIONARY_WATER) then -- check if the block is water
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_ICE})
				elseif (World:GetBlock(Vector3i(x, y , z)) == E_BLOCK_LAVA) then -- check if the block is lava
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_OBSIDIAN})
				else
					if cBlockInfo:IsSnowable(World:GetBlock(Vector3i(x, y, z))) then
						table.insert(PossibleBlockChanges, {X = x, Y = y + 1, Z = z, BlockType = E_BLOCK_SNOW})
					end
				end
			end
		end
	end

	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(Vector3i(value.X, value.Y, value.Z), value.BlockType, 0)
		end
		a_Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. " surfaces covered. Let is snow~")
	end
	return true
end





function HandleThawCommand(a_Split, a_Player)
	if tonumber(a_Split[2]) == nil or a_Split[2] == nil then -- check if the player gave a radius
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//thaw <radius>")
		return true
	end

	local Radius = tonumber(a_Split[2]) -- set the radius to the given radius

	local World = a_Player:GetWorld() -- Get the world the player is in
	local MinX = math.floor(a_Player:GetPosX()) - Radius
	local MaxX = math.floor(a_Player:GetPosX()) + Radius
	local MinZ = math.floor(a_Player:GetPosZ()) - Radius
	local MaxZ = math.floor(a_Player:GetPosZ()) + Radius
	local YCheck = GetMultipleBlockChanges(MinX, MaxX, MinZ, MaxZ, a_Player, World, "thaw")
	local PossibleBlockChanges = {}

	for x=MinX, MaxX do
		for z=MinZ, MaxZ do
			local IsValid, y = World:TryGetHeight(x, z)
			if IsValid then
				YCheck:SetY(y)
				if (World:GetBlock(Vector3i(x, y, z)) == E_BLOCK_SNOW) then -- check if the block is snow
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_AIR})
				elseif (World:GetBlock(Vector3i(x, y, z)) == E_BLOCK_ICE) then -- check if the block is ice
					table.insert(PossibleBlockChanges, {X = x, Y = y, Z = z, BlockType = E_BLOCK_WATER})
				end
			end
		end
	end

	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(Vector3i(value.X, value.Y, value.Z), value.BlockType, 0)
		end
		a_Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. "  surfaces thawed")
	end
	return true
end






function HandlePumpkinsCommand(a_Split, a_Player)
	-- /pumpkins [Radius]

	local Radius = not a_Split[2] and 10 or tonumber(a_Split[2])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "invaild argument")
		return true
	end


	local PosX = math.floor(a_Player:GetPosX())
	local PosZ = math.floor(a_Player:GetPosZ())
	local World = a_Player:GetWorld()

	local YCheck = GetMultipleBlockChanges(PosX - Radius, PosX + Radius, PosZ - Radius, PosZ + Radius, a_Player, World, "pumpkins")
	local PossibleBlockChanges = {}

	for I=1, Radius * 2 do
		local X = PosX + math.random(-Radius, Radius)
		local Z = PosZ + math.random(-Radius, Radius)
		local IsValid, Y = World:TryGetHeight(X, Z)
		if IsValid then
			Y = Y + 1
			if (World:GetBlock(Vector3i(X, Y - 1, Z)) == E_BLOCK_GRASS) or (World:GetBlock(Vector3i(X, Y, Z)) - 1 == E_BLOCK_DIRT) then
				YCheck:SetY(Y)
				table.insert(PossibleBlockChanges, {X = X, Y = Y, Z = Z, BlockType = E_BLOCK_LOG, BlockMeta = 0})
				for i=1, math.random(1, 6) do
					X = X + math.random(-2, 2)
					Z = Z + math.random(-2, 2)
					Y = World:GetHeight(X, Z) + 1
					YCheck:SetY(Y)

					local Block = World:GetBlock(Vector3i(X, Y - 1, Z))
					if (Block == E_BLOCK_GRASS) or Block == E_BLOCK_DIRT then
						table.insert(PossibleBlockChanges, {X = X, Y = Y, Z = Z, BlockType = E_BLOCK_LEAVES, BlockMeta = 0})
					end
				end
				for i=1, math.random(1, 4) do
					X = X + math.random(-2, 2)
					Z = Z + math.random(-2, 2)
					if (World:GetBlock(Vector3i(X, Y - 1, Z)) == E_BLOCK_GRASS) or (World:GetBlock(Vector3i(X, Y, Z)) - 1 == E_BLOCK_DIRT) then
						table.insert(PossibleBlockChanges, {X = X, Y = Y, Z = Z, BlockType = E_BLOCK_PUMPKIN, BlockMeta = math.random(0, 3)})
					end
				end
			end
		end
	end

	if not YCheck:Flush() then
		for idx, value in ipairs(PossibleBlockChanges) do
			World:SetBlock(Vector3i(value.X, value.Y, value.Z), value.BlockType, value.BlockMeta)
		end
		a_Player:SendMessage(cChatColor.LightPurple .. #PossibleBlockChanges .. " pumpkin patches created")
	end
	return true
end





function HandleRemoveColumnCommand(a_Split, a_Player)
	-- /removeabove
	-- /removebelow

	local Pos = a_Player:GetPosition():Floor()

	-- Try to determine the world height at this column:
	local IsValid, WorldHeight = a_Player:GetWorld():TryGetHeight(Pos.x, Pos.z)
	if not(IsValid) then
		a_Player:SendMessage(cChatColor.LightPurple .. "0 block(s) have been removed.")
		return true
	end

	local Cuboid = cCuboid(Pos, Pos)
	Cuboid.p1.y = ((a_Split[1] == "/removeabove") or (a_Split[1] == "//removeabove")) and (WorldHeight + 1) or 1
	Cuboid:Sort()

	-- Check if other plugins allow the operation:
	local World = a_Player:GetWorld()
	if (CallHook("OnAreaChanging", Cuboid, a_Player, World, a_Split[1]:sub(3, -1))) then
		return false
	end

	-- Push in Undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid, a_Split[1])

	-- Clear the blocks by writing an empty cBlockArea over them:
	local Area = cBlockArea()
	Area:Create(Cuboid:DifX() + 1, Cuboid:DifY() + 1, Cuboid:DifZ() + 1)
	Area:Write(World, Cuboid.p1)
	Area:Clear()

	-- Notify other plugins
	CallHook("OnAreaChanged", Cuboid, a_Player, World, a_Split[1]:sub(3, -1))

	local ChangedBlocks = Cuboid.p2.y - Cuboid.p1.y
	a_Player:SendMessage(cChatColor.LightPurple .. ChangedBlocks .. " block(s) have been removed.")
	return true
end
