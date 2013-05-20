-------------------------------------------------
-------------------REMOVEBELOW-------------------
-------------------------------------------------
function HandleRemoveBelowCommand( Split, Player )
	X = math.floor( Player:GetPosX() ) -- round the number ( for example from 12.23423987 to 12 )
	y = math.floor( Player:GetPosY() ) -- round the number ( for example from 12.23423987 to 12 )
	Z = math.floor( Player:GetPosZ() ) -- round the number ( for example from 12.23423987 to 12 )
	World = Player:GetWorld() -- Get the world
	local BlockBelow = 0
	for Y = 1, y do
		World:SetBlock( X, Y, Z, 0, 0 )
		BlockBelow = BlockBelow + 1
	end
	Player:SendMessage( cChatColor.LightPurple .. BlockBelow .. " block(s) have been removed." )
	return true
end


-------------------------------------------------
-------------------REMOVEABOVE-------------------
-------------------------------------------------
function HandleRemoveAboveCommand( Split, Player )
	X = math.floor( Player:GetPosX() ) -- round the number ( for example from 12.23423987 to 12 )
	y = math.floor( Player:GetPosY() ) -- round the number ( for example from 12.23423987 to 12 )
	Z = math.floor( Player:GetPosZ() ) -- round the number ( for example from 12.23423987 to 12 )
	World = Player:GetWorld()
	local BlocksAbove = 0
	for Y = y, World:GetHeight( X, Z ) do
		World:SetBlock( X, Y, Z, 0, 0 )
		BlocksAbove = BlocksAbove + 1
	end
	Player:SendMessage( cChatColor.LightPurple .. BlocksAbove .. " block(s) have been removed." )
	return true
end


-----------------------------------------------
---------------------DRAIN---------------------
-----------------------------------------------
function HandleDrainCommand( Split, Player )
	if tonumber( Split[2] ) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage( cChatColor.Rose .. "Too few arguments.\n//drain <radius>" )
		return true
	else
		Radius = tonumber( Split[2] ) -- set the radius to the given radius
	end
	OnePlayerX[Player:GetName()] = Player:GetPosX() - Radius -- Set the coordinates to the coordinates with the radius
	TwoPlayerX[Player:GetName()] = Player:GetPosX() + Radius -- Set the coordinates to the coordinates with the radius
	OnePlayerY[Player:GetName()] = Player:GetPosY() - Radius -- Set the coordinates to the coordinates with the radius
	TwoPlayerY[Player:GetName()] = Player:GetPosY() + Radius -- Set the coordinates to the coordinates with the radius
	OnePlayerZ[Player:GetName()] = Player:GetPosZ() - Radius -- Set the coordinates to the coordinates with the radius
	TwoPlayerZ[Player:GetName()] = Player:GetPosZ() + Radius -- Set the coordinates to the coordinates with the radius
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- get the coordinates in the right order
	BlockArea:Read( Player:GetWorld(), OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	for X=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			for Z=0, BlockArea:GetSizeZ() - 1 do
				if BlockArea:GetRelBlockType( X, Y, Z ) == E_BLOCK_WATER or BlockArea:GetRelBlockType( X, Y, Z ) == E_BLOCK_STATIONARY_WATER then -- check if the block is water
					BlockArea:SetRelBlockType( X, Y, Z, 0 ) -- set the block to air
				end
			end
		end
	end
	BlockArea:Write( Player:GetWorld(), OneX, OneY, OneZ ) -- write the are into the world.
	return true
end


------------------------------------------------
-------------------EXTINGUISH-------------------
------------------------------------------------
function HandleExtinguishCommand( Split, Player )
	if Split[2] == nil or tonumber( Split[2] ) == nil then
		Player:SendMessage( cChatColor.Rose .. "Too few arguments.\n/ex <radius>" )
		return true
	else
		Radius = tonumber( Split[2] )
	end
	OnePlayerX[Player:GetName()] = Player:GetPosX() - Radius -- Set the coordinates to the coordinates with the radius
	TwoPlayerX[Player:GetName()] = Player:GetPosX() + Radius -- Set the coordinates to the coordinates with the radius
	OnePlayerY[Player:GetName()] = Player:GetPosY() - Radius -- Set the coordinates to the coordinates with the radius
	TwoPlayerY[Player:GetName()] = Player:GetPosY() + Radius -- Set the coordinates to the coordinates with the radius
	OnePlayerZ[Player:GetName()] = Player:GetPosZ() - Radius -- Set the coordinates to the coordinates with the radius
	TwoPlayerZ[Player:GetName()] = Player:GetPosZ() + Radius -- Set the coordinates to the coordinates with the radius
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- get the coordinates in the right order
	BlockArea:Read( Player:GetWorld(), OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- Read the area
	for X=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			for Z=0, BlockArea:GetSizeZ() - 1 do
				if BlockArea:GetRelBlockType( X, Y, Z ) == E_BLOCK_FIRE then -- check if the block is fire
					BlockArea:SetRelBlockType( X, Y, Z, E_BLOCK_AIR )
				end
			end
		end
	end
	BlockArea:Write( Player:GetWorld(), OneX, OneY, OneZ )
	return true
end


-------------------------------------------------
----------------------GREEN----------------------
-------------------------------------------------
function HandleGreenCommand( Split, Player )
	
	if tonumber( Split[2] ) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage( cChatColor.Rose .. "Too few arguments.\n//green <radius>" )
		return true
	else
		Radius = tonumber( Split[2] ) -- set the radius to the given radius
	end
	World = Player:GetWorld()
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	local DirtBlocks = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == E_BLOCK_DIRT then -- if the block is dirt
				DirtBlocks = DirtBlocks + 1
				World:SetBlock(x, y, z, E_BLOCK_GRASS, 0) -- set the block to grass
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. DirtBlocks .. " surfaces greened." )
	return true
end


------------------------------------------------
----------------------SNOW----------------------
------------------------------------------------
function HandleSnowCommand( Split, Player )	
	if tonumber( Split[2] ) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage( cChatColor.Rose .. "Too few arguments.\n//snow <radius>" )
		return true
	else
		Radius = tonumber( Split[2] ) -- set the radius to the given radius
	end
	World = Player:GetWorld() -- Get the world the player is in
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	local SnowBlocks = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y , z) == E_BLOCK_STATIONARY_WATER then -- check if the block is water
				SnowBlocks = SnowBlocks + 1
				World:SetBlock(x, y, z, E_BLOCK_ICE, 0) -- set the block to ice
			elseif World:GetBlock(x, y , z) == E_BLOCK_LAVA then -- check if the block is lava
				SnowBlocks = SnowBlocks + 1
				World:SetBlock(x, y, z, E_BLOCK_OBSIDIAN, 0) -- set the block to obsydian
			else
				SnowBlocks = SnowBlocks + 1
				World:SetBlock(x, y + 1, z, E_BLOCK_SNOW, 0) -- set the block to snow.
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. SnowBlocks .. " surfaces covered. Let is snow~" )
	return true
end


------------------------------------------------
----------------------THAW----------------------
------------------------------------------------
function HandleThawCommand( Split, Player )
	if tonumber( Split[2] ) == nil or Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage( cChatColor.Rose .. "Too few arguments.\n//thaw <radius>" )
		return true
	else
		Radius = tonumber( Split[2] ) -- set the radius to the given radius
	end
	World = Player:GetWorld() -- Get the world the player is in
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	local ThawBlocks = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == E_BLOCK_SNOW then -- check if the block is snow
				ThawBlocks = ThawBlocks + 1
				World:SetBlock(x, y, z, E_BLOCK_AIR, 0) -- set the block to an air block
			elseif World:GetBlock(x, y, z) == E_BLOCK_ICE then -- check if the block is ice
				ThawBlocks = ThawBlocks + 1
				World:SetBlock(x, y, z, E_BLOCK_WATER, 0) -- set the block to water
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. ThawBlocks .. " surfaces thawed" )
	return true
end


-----------------------------------------------
-------------------BIOMELIST-------------------
-----------------------------------------------
function HandleBiomeListCommand( Split, Player )
	if Split[2] == nil then -- if there was no page given then the page is 1
		Split[2] = 1 
	end
	if tonumber(Split[2]) == 1 then -- Page 1
		Player:SendMessage( cChatColor.Green .. "Page 1" )
		Player:SendMessage( "Ocean" )
		Player:SendMessage( "Plains" )
		Player:SendMessage( "Desert" )
		Player:SendMessage( "Extreme_Hills" )
		Player:SendMessage( "Forest" )
		Player:SendMessage( "Taiga" )
		Player:SendMessage( "Swampland" )
		Player:SendMessage( "River" )
	elseif tonumber(Split[2]) == 2 then -- Page 2
		Player:SendMessage( cChatColor.Green .. "Page 2" )
		Player:SendMessage( "Hell" )
		Player:SendMessage( "Sky" )
		Player:SendMessage( "FrozenOcean" )
		Player:SendMessage( "FrozenRiver" )
		Player:SendMessage( "Ice_Plains" )
		Player:SendMessage( "Ice_Mountains" )
		Player:SendMessage( "MushroomIsland" )
		Player:SendMessage( "MushroomIslandShore" )
	elseif tonumber(Split[2]) == 3 then -- Page 3
		Player:SendMessage( cChatColor.Green .. "Page 3" )
		Player:SendMessage( "Beach" )
		Player:SendMessage( "DesertHills" )
		Player:SendMessage( "ForestHills" )
		Player:SendMessage( "TaigaHills " )
		Player:SendMessage( "Extreme_Hills_Edge" )
		Player:SendMessage( "Jungle" )
		Player:SendMessage( "JungleHills" )
	else
		Player:SendMessage( "/biomelist [1-3]" ) -- the page was not valid
	end
	return true
end


------------------------------------------------
--------------------SETBIOME--------------------
------------------------------------------------
function HandleSetBiomeCommand( Split, Player )
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a biome" )
		return true
	end
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	Biome = SetBiomeFromString( Split, Player )
	if Biome == false then
		Player:SendMessage( "Please specify a valid biome" )
		return true
	end
	--World = Player:GetWorld()
	OneX, TwoX, OneZ, TwoZ = GetXZCoords( Player )
	for X=OneX, TwoX do
		for Z=OneZ, TwoZ do
			cChunkDesc:SetBiome( X, Z, Biome )
		end
	end
end