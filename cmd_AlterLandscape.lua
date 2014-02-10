-------------------------------------------------
-------------------REMOVEBELOW-------------------
-------------------------------------------------
function HandleRemoveBelowCommand(Split, Player)
	local X = math.floor(Player:GetPosX()) -- round the number (for example from 12.23423987 to 12)
	local Y = math.floor(Player:GetPosY()) -- round the number (for example from 12.23423987 to 12)
	local Z = math.floor(Player:GetPosZ()) -- round the number (for example from 12.23423987 to 12)
	local World = Player:GetWorld() -- Get the world
	local PlayerName = Player:GetName()
	
	if CheckIfInsideAreas(X, X, 1, Y, Z, Z, Player, Player:GetWorld(), "removebelow") then
		return true
	end
	
	LastCoords[PlayerName] = {X = X, Y = 1, Z = Z, WorldName = World:GetName()}
	
	PersonalUndo[PlayerName]:Read(World, X, X, 1, Y, Z, Z)
	for y = 1, Y do
		World:SetBlock(X, y, Z, E_BLOCK_AIR, 0)
	end
	Player:SendMessageSuccess(Y + 1 .. " block(s) have been removed.")
	return true
end


-------------------------------------------------
-------------------REMOVEABOVE-------------------
-------------------------------------------------
function HandleRemoveAboveCommand(Split, Player)
	local X = math.floor(Player:GetPosX()) -- round the number (for example from 12.23423987 to 12)
	local y = math.floor(Player:GetPosY()) -- round the number (for example from 12.23423987 to 12)
	local Z = math.floor(Player:GetPosZ()) -- round the number (for example from 12.23423987 to 12)
	local World = Player:GetWorld()
	local PlayerName = Player:GetName()
	local IsValid, WorldHeight = World:TryGetHeight(X, Z)
	
	if not IsValid then
		Player:SendMessageFailure("No blocks have been removed, chunk not loaded?")
		return true
	end
	
	if CheckIfInsideAreas(X, X, y, WorldHeight, Z, Z, Player, World, "removeabove") then
		return true
	end
	
	LastCoords[PlayerName] = {X = X, Y = y, Z = Z, WorldName = World:GetName()}
	PersonalUndo[PlayerName]:Read(World, X, X, y, WorldHeight, Z, Z)
	
	for Y = y, WorldHeight do
		World:SetBlock(X, Y, Z, E_BLOCK_AIR, 0)
	end
	Player:SendMessageSuccess(WorldHeight - y .. " block(s) have been removed.")
	return true
end


-----------------------------------------------
---------------------DRAIN---------------------
-----------------------------------------------
function HandleDrainCommand(Split, Player)
	if tonumber(Split[2]) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessageInfo("Usage: //drain <radius>")
		return true
	else
		Radius = tonumber(Split[2]) -- set the radius to the given radius
	end
	
	local MinX = math.floor(Player:GetPosX()) - Radius
	local MinY = math.floor(Player:GetPosY()) - Radius
	local MinZ = math.floor(Player:GetPosZ()) - Radius
	local MaxX = math.floor(Player:GetPosX()) + Radius
	local MaxY = math.floor(Player:GetPosY()) + Radius
	local MaxZ = math.floor(Player:GetPosZ()) + Radius
	
	if CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, Player, Player:GetWorld(), "drain") then
		return true
	end
	
	local BlockArea = cBlockArea()
	BlockArea:Read(Player:GetWorld(), MinX, MaxX, MinY, MaxY, MinZ, MaxZ) -- read the area
	for x=0, BlockArea:GetSizeX() - 1 do
		for y=0, BlockArea:GetSizeY() - 1 do
			for z=0, BlockArea:GetSizeZ() - 1 do
				if BlockArea:GetRelBlockType(x, y, z) == E_BLOCK_WATER or BlockArea:GetRelBlockType(x, y, z) == E_BLOCK_STATIONARY_WATER then -- check if the block is water
					BlockArea:SetRelBlockType(x, y, z, 0) -- set the block to air
				end
			end
		end
	end
	BlockArea:Write(Player:GetWorld(), MinX, MinY, MinZ) -- write the are into the world.
	return true
end


------------------------------------------------
-------------------EXTINGUISH-------------------
------------------------------------------------
function HandleExtinguishCommand(Split, Player)
	if Split[2] == nil or tonumber(Split[2]) == nil then
		Player:SendMessageInfo("Usage: /ex <radius as number>")
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
		Player:SendMessageInfo("Usage: //green <radius>")
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
		Player:SendMessageSuccess(#PossibleBlockChanges .. " surfaces greened.")
	end
	return true
end


------------------------------------------------
----------------------SNOW----------------------
------------------------------------------------
function HandleSnowCommand(Split, Player)	
	if tonumber(Split[2]) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessageInfo("Usage: /snow <radius>")
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
					if g_BlockIsSnowable[World:GetBlock(x, y, z)] then
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
		Player:SendMessageSuccess(#PossibleBlockChanges .. " surfaces covered. Let is snow~")
	end
	return true
end


------------------------------------------------
----------------------THAW----------------------
------------------------------------------------
function HandleThawCommand(Split, Player)
	if tonumber(Split[2]) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessageInfo("Usage: /thaw <radius>")
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
		Player:SendMessageSuccess(#PossibleBlockChanges .. "  surfaces thawed")
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
		Player:SendMessageInfo("Biomes List | Page 1")
		Player:SendMessage("Ocean")
		Player:SendMessage("Plains")
		Player:SendMessage("Desert")
		Player:SendMessage("Extreme_Hills")
		Player:SendMessage("Forest")
		Player:SendMessage("Taiga")
		Player:SendMessage("Swampland")
		Player:SendMessage("River")
	elseif tonumber(Split[2]) == 2 then -- Page 2
		Player:SendMessageInfo("Biomes List | Page 2")
		Player:SendMessage("Hell")
		Player:SendMessage("Sky")
		Player:SendMessage("FrozenOcean")
		Player:SendMessage("FrozenRiver")
		Player:SendMessage("Ice_Plains")
		Player:SendMessage("Ice_Mountains")
		Player:SendMessage("MushroomIsland")
		Player:SendMessage("MushroomIslandShore")
	elseif tonumber(Split[2]) == 3 then -- Page 3
		Player:SendMessageInfo("Biomes List | Page 3")
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
	Player:SendMessageFailure("This command is currently non-functional.")
	return true
	--[[if Split[2] == nil then
		Player:SendMessage(cChatColor.Rose .. "Please say a biome")
		return true
	end
	if OnePlayer[Player:GetName()] == nil or TwoPlayer[Player:GetName()] == nil then
		Player:SendMessage(cChatColor.Rose .. "No Region set")
		return true
	end
	Biome = GetBiomeFromString(Split, Player)
	if Biome == false then
		Player:SendMessage("Please specify a valid biome")
		return true
	end
	--local World = Player:GetWorld()
	OneX, TwoX, OneZ, TwoZ = GetXZCoords(Player)
	for X=OneX, TwoX do
		for Z=OneZ, TwoZ do
			cChunkDesc:SetBiome(X, Z, Biome)
		end
	end]]
end



------------------------------------------------
--------------------PUMPKINS--------------------
------------------------------------------------
function HandlePumpkinsCommand(Split, Player)
	if Split[2] == nil then
		Radius = 10
	elseif tonumber(Split[2]) == nil then
		Player:SendMessageInfo("Usage: /pumpkins <radius as number>")
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
		local IsValid, Y = World:TryGetHeight(X, Z) + 1
		if IsValid then
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
		Player:SendMessageSuccess(#PossibleBlockChanges .. "  surfaces pumpkinfied")
	end
	return true
end		