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
	Player:SendMessage(cChatColor.LightPurple .. Y + 1 .. " block(s) have been removed.")
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
		Player:SendMessage(cChatColor.LightPurple .. "0 block(s) have been removed.")
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
	Player:SendMessage(cChatColor.LightPurple .. WorldHeight - y .. " block(s) have been removed.")
	return true
end


-----------------------------------------------
---------------------DRAIN---------------------
-----------------------------------------------
function HandleDrainCommand(Split, Player)
	if tonumber(Split[2]) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//drain <radius>")
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


------------------------------------------------
---------------------SPHERE---------------------
------------------------------------------------
function HandleSphereCommand(Split, Player)
	if Split[2] == nil or Split[3] == nil then
		Player:SendMessage(cChatColor.Rose .. "Not enough parameters.")
		Player:SendMessage(cChatColor.Rose .. "Usage: //sphere [BlockID] [Radius]")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(Player, Split[2])

	if not BlockType then
		Player:SendMessage(cChatColor.Rose .. "Unknown parameter \"" .. Split[2] .. "\"")
		return true
	end
	
	local Radius = tonumber(Split[3])
	if not Radius then
		Player:SendMessage(cChatColor.Rose .. "Unknown parameter \"" .. Split[3] .. "\"")
		return true
	end
	
	local World = Player:GetWorld()
	local PosX = math.floor(Player:GetPosX())
	local PosY = math.floor(Player:GetPosY())
	local PosZ = math.floor(Player:GetPosZ())
	
	if PosY + Radius > 256 then
		Player:SendMessage(cChatColor.Rose .. "You are at the top of the world. You can't build here.")
		return true
	end
	
	local MinX, MaxX, MinY, MaxY, MinZ, MaxZ = PosX - Radius, PosX + Radius, PosY - Radius, PosY + Radius, PosZ - Radius, PosZ + Radius
	
	if CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, Player, World, "sphere") then
		return true
	end
	
	LastCoords[Player:GetName()] = {X = MinX, Y = MinY, Z = MinZ, WorldName = World:GetName()}
	PersonalUndo[Player:GetName()]:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	local BlockArea = cBlockArea()
	BlockArea:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, 3)
	local BlockAreaRadius = BlockArea:GetSizeX() - 1 -- All sides are the same size so we can use the GetSizeX function
	
	local MidPoint = Vector3d(BlockAreaRadius / 2, BlockAreaRadius / 2, BlockAreaRadius / 2)
	
	local Blocks = 0
	for X=0, BlockAreaRadius do
		for Y=0, BlockAreaRadius do
			for Z=0, BlockAreaRadius do
				local Distance = math.floor((MidPoint - Vector3d(X, Y, Z)):Length())
				if Distance <= Radius then
					BlockArea:SetRelBlockTypeMeta(X, Y, Z, BlockType, BlockMeta)
					Blocks = Blocks + 1
				end
			end
		end
	end

	BlockArea:Write(World, MinX, MinY, MinZ)
	Player:SendMessage(cChatColor.LightPurple .. Blocks .. " block(s) were created.")
	return true
end


-------------------------------------------------
---------------------HSPHERE---------------------
-------------------------------------------------
function HandleHSphereCommand(Split, Player)
	if Split[2] == nil or Split[3] == nil then
		Player:SendMessage(cChatColor.Rose .. "Not enough parameters.")
		Player:SendMessage(cChatColor.Rose .. "Usage: //hsphere [BlockID] [Radius]")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(Player, Split[2])

	if not BlockType then
		Player:SendMessage(cChatColor.Rose .. "Unknown parameter \"" .. Split[2] .. "\"")
		return true
	end
	
	local Radius = tonumber(Split[3])
	if not Radius then
		Player:SendMessage(cChatColor.Rose .. "Unknown parameter \"" .. Split[3] .. "\"")
		return true
	end
	
	local World = Player:GetWorld()
	local PosX = math.floor(Player:GetPosX())
	local PosY = math.floor(Player:GetPosY())
	local PosZ = math.floor(Player:GetPosZ())
	
	if PosY + Radius > 256 then
		Player:SendMessage(cChatColor.Rose .. "You are at the top of the world. You can't build here.")
		return true
	end
	
	local MinX, MaxX, MinY, MaxY, MinZ, MaxZ = PosX - Radius, PosX + Radius, PosY - Radius, PosY + Radius, PosZ - Radius, PosZ + Radius
	if CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, Player, World, "hsphere") then
		return true
	end
	
	LastCoords[Player:GetName()] = {X = MinX, Y = MinY, Z = MinZ, WorldName = World:GetName()}
	PersonalUndo[Player:GetName()]:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	local BlockArea = cBlockArea()
	BlockArea:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, 3)
	local BlockAreaRadius = BlockArea:GetSizeX() - 1 -- All sides are the same size so we can use the GetSizeX function
	
	local MidPoint = Vector3d(BlockAreaRadius / 2, BlockAreaRadius / 2, BlockAreaRadius / 2)
	
	local Blocks = 0
	for X=0, BlockAreaRadius do
		for Y=0, BlockAreaRadius do
			for Z=0, BlockAreaRadius do
				local Distance = math.floor((MidPoint - Vector3d(X, Y, Z)):Length())
				if Distance == Radius then
					BlockArea:SetRelBlockTypeMeta(X, Y, Z, BlockType, BlockMeta)
					Blocks = Blocks + 1
				end
			end
		end
	end
	
	BlockArea:Write(World, MinX, MinY, MinZ)
	Player:SendMessage(cChatColor.LightPurple .. Blocks .. " block(s) were created.")
	return true
end
