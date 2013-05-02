-------------------------------------------------
---------------------BUTCHER---------------------
-------------------------------------------------
function HandleButcherCommand( Split, Player )
	if Split[2] == nil then
		Radius = ButcherRadius
	elseif tonumber( Split[2] ) == nil then
		Player:SendMessage( cChatColor.Rose .. 'Number expected; string "' .. Split[2] .. '" given' )
		return true
	else
		Radius = tonumber( Split[2] )
	end
	X = Player:GetPosX()
	Y = Player:GetPosY()
	Z = Player:GetPosZ()
	Distance =  math.abs( math.floor( X + Y + Z ) )
	Count[Player:GetName()] = 0
	local EachEntity = function( Entity )
		if Entity:IsMob() == true then
			if Radius == 0 then
				Entity:Destroy()
				Count[Player:GetName()] = Count[Player:GetName()] + 1
			else
				EntityX = Entity:GetPosX()
				EntityY = Entity:GetPosY()
				EntityZ = Entity:GetPosZ()
				if (math.abs( Distance - math.abs( math.floor( EntityX + EntityY + EntityZ ) ) ) ) < Radius then
					Entity:Destroy()
					Count[Player:GetName()] = Count[Player:GetName()] + 1
				end
			end
		end
	end
	Player:GetWorld():ForEachEntity( EachEntity )
	Player:SendMessage( cChatColor.LightPurple .. "Killed " .. Count[Player:GetName()] .. " mobs." )
	return true
end
	
	
------------------------------------------------
----------------------NONE----------------------
------------------------------------------------
function HandleNoneCommand( Split, Player )
	if Player:GetEquippedItem().m_ItemType == ReplItem[Player:GetName()] then
		Repl[Player:GetName()] = nil
		ReplItem[Player:GetName()] = nil
	end
	Player:SendMessage( cChatColor.LightPurple .. "Tool unbound from your current item." )
	return true
end
	
	
------------------------------------------------
----------------------REPL----------------------
------------------------------------------------
function HandleReplCommand( Split, Player )
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Too few arguments." )
		Player:SendMessage( cChatColor.Rose .. "/repl <block ID>" )
	elseif tonumber(Split[2]) == nil then
		Block = StringSplit( Split[2], ":" )
		if IsValidBlock( tonumber(Block[1]) ) ~= nil then
			Repl[Player:GetName()] = Split[2]
			ReplItem[Player:GetName()] = Player:GetEquippedItem().m_ItemType
			Player:SendMessage( cChatColor.LightPurple .. "Block replacer tool bound to " .. Player:GetEquippedItem().m_ItemType )
			return true
		end
		Player:SendMessage( cChatColor.Rose .. "Too few arguments." )
		Player:SendMessage( cChatColor.Rose .. "/repl <block ID>" )
	elseif IsValidBlock( tonumber(Split[2]) ) == true and ItemCategory.IsTool( Player:GetEquippedItem().m_ItemType ) == true then
		Repl[Player:GetName()] = tonumber(Split[2])
		ReplItem[Player:GetName()] = Player:GetEquippedItem().m_ItemType
		Player:SendMessage( cChatColor.LightPurple .. "Block replacer tool bound to " .. Player:GetEquippedItem().m_ItemType )
	else
		if IsValidBlock( tonumber(Split[2]) ) == false then
			Player:SendMessage( cChatColor.Rose .. Split[2] .. " isn't a valid block" )
			return true
		end
		Player:SendMessage( cChatColor.Rose .. "Can't bind tool to " .. Player:GetEquippedItem().m_ItemType .. ": Blocks can't be used" )
	end
	return true
end


-----------------------------------------------
--------------------DESCEND--------------------
-----------------------------------------------
function HandleDescendCommand( Split, Player )
	World = Player:GetWorld()
	if Player:GetPosY() ~= 1 then
		X[Player:GetName()] = math.floor( Player:GetPosX() )
		Z[Player:GetName()] = math.floor( Player:GetPosZ() )
		PosY[Player:GetName()] = math.floor( Player:GetPosY() )
		while PosY[Player:GetName()] ~= 1 do 
			if World:GetBlock( X[Player:GetName()], PosY[Player:GetName()], Z[Player:GetName()]) == 0 then
				if Air[Player:GetName()] == true then
					while World:GetBlock( X[Player:GetName()], PosY[Player:GetName()], Z[Player:GetName()]) == 0 do
						PosY[Player:GetName()] = PosY[Player:GetName()] - 1
					end
					break
				end
			else
				Air[Player:GetName()] = true
			end
			PosY[Player:GetName()] = PosY[Player:GetName()] - 1
		end
		if PosY[Player:GetName()] ~= nil then
			if Air[Player:GetName()] == true then
				if PosY[Player:GetName()] ~= 1 then
					Player:TeleportTo( Player:GetPosX(), PosY[Player:GetName()] + 1, Player:GetPosZ() )
				end
				Air[Player:GetName()] = false
				PosY[Player:GetName()] = nil
			end
		end		
	end
	Player:SendMessage( cChatColor.LightPurple .. "Descended a level." )
	return true
end


------------------------------------------------
---------------------ASCEND---------------------
------------------------------------------------
function HandleAscendCommand( Split, Player )
	World = Player:GetWorld()
	if Player:GetPosY() == World:GetHeight( math.floor(Player:GetPosX()), math.floor((Player:GetPosZ()) ) ) then
		Player:SendMessage( cChatColor.LightPurple .. "Ascended a level." )
	else
		X[Player:GetName()] = math.floor(Player:GetPosX())
		Z[Player:GetName()] = math.floor(Player:GetPosZ())
		for Y = math.floor(Player:GetPosY()), World:GetHeight( X[Player:GetName()], Z[Player:GetName()] ) + 1 do
			if World:GetBlock( X[Player:GetName()], Y, Z[Player:GetName()] ) == 0 then
				if Air[Player:GetName()] == true then
					PosY[Player:GetName()] = Y
					break
				end
			else
				Air[Player:GetName()] = true
			end
		end
		if PosY[Player:GetName()] ~= nil then
			if Air[Player:GetName()] == true then			
				Player:TeleportTo( Player:GetPosX(), PosY[Player:GetName()], Player:GetPosZ() )
				Air[Player:GetName()] = false
				PosY[Player:GetName()] = nil
			end
		end		
	end	
	Player:SendMessage( cChatColor.LightPurple .. "Ascended a level." )
	return true
end


-------------------------------------------------
----------------------GREEN----------------------
-------------------------------------------------
function HandleGreenCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /green [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	Blocks[Player:GetName()] = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == 3 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 2, 0)
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " surfaces greened." )
	return true
end

------------------------------------------------
----------------------SIZE----------------------
------------------------------------------------
function HandleSizeCommand( Split, Player )
	if OnePlayerX[Player:GetName()] ~= nil and TwoPlayerX[Player:GetName()] ~= nil then
		Player:SendMessage( cChatColor.LightPurple .. "the selection is " .. GetSize( Player ) .. " block(s) big" )
	else
		Player:SendMessage( cChatColor.LightPurple .. "Please select a region first" )
	end
	return true
end


-------------------------------------------------
----------------------PASTE----------------------
-------------------------------------------------
function HandlePasteCommand( Split, Player )
	if BlockArea:Write( Player:GetWorld(), Player:GetPosX(), Player:GetPosY(), Player:GetPosZ(), 3 ) == false then
		Player:SendMessage( cChatColor.LightPurple .. "You didn't copy anything" )
	else
		Player:SendMessage( cChatColor.LightPurple .. "Pasted relative to you." )
	end
	return true
end


------------------------------------------------
----------------------COPY----------------------
------------------------------------------------
function HandleCopyCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )
	World = Player:GetWorld()
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Player:SendMessage( cChatColor. LightPurple .. "Block(s) copied." )
	return true
end


-----------------------------------------------
----------------------CUT----------------------
-----------------------------------------------
function HandleCutCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )
	World = Player:GetWorld()
	Cut = cBlockArea()
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Cut:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Cut:Fill( 1, 0, 0 )
	Cut:Write( World, OneX, OneY, OneZ )
	Player:SendMessage( cChatColor. LightPurple .. "Block(s) cut." )
	return true
end


-----------------------------------------------
-------------------SCHEMATIC-------------------
-----------------------------------------------
function HandleSchematicCommand( Split, Player )
	if string.upper(Split[2]) == "SAVE" then
		if Player:HasPermission("worldedit.schematic.save") then
			if Split[3] == nil then
				Player:SendMessage( cChatColor.Green .. "Please state a schematic name" )
				return true
			end	
			BlockArea:SaveToSchematicFile( "Schematics/" .. Split[3] .. ".Schematic" )
			Player:SendMessage( cChatColor.LightPurple .. "Clipboard saved to " .. Split[3] )
		end
	elseif string.upper(Split[2]) == "LOAD" then
		if Player:HasPermission("worldedit.schematic.load") then
			if Split[3] == nil then
				Player:SendMessage( cChatColor.Green .. "Please state a schematic name" )
				return true
			end 		
			BlockArea:LoadFromSchematicFile( "Schematics/" .. Split[3] .. ".Schematic" )
			Player:SendMessage( cChatColor.LightPurple .. "Clipboard " .. Split[3] .. " is loaded" ) 
		end
	end
	return true
end


-----------------------------------------------
----------------------SET----------------------
-----------------------------------------------
function HandleSetCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	Block = StringSplit( Split[2], ":" )
	if Block[1] == nil then
		Block[1] = 0
	end
	if Block[2] == nil then
		Block[2] = 0
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )
	World = Player:GetWorld()	
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	BlockArea:Fill( 1, Block[1], Block[2] )
	BlockArea:Write( World, OneX, OneY, OneZ )
	Player:SendMessage( cChatColor.LightPurple .. GetSize( Player ) .. " block(s) have been changed." )
	return true
end


-------------------------------------------------
---------------------REPLACE---------------------
-------------------------------------------------
function HandleReplaceCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil or Split[3] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	ChangeBlock = StringSplit( Split[2], ":" )
	if ChangeBlock[1] == nil then
		ChangeBlock[1] = 0
	end
	ToChangeBlock = StringSplit( Split[3], ":" )
	if ToChangeBlock[1] == nil then
		ToChangeBlock[1] = 0
	end
	if ToChangeBlock[2] == nil then
		ToChangeBlock[2] = 0
	end
	ChangeBlock[1] = tonumber(ChangeBlock[1])
	if ChangeBlock[2] ~= nil then
		ChangeBlock[2] = tonumber(ChangeBlock[2])
	end
	ToChangeBlock[1] = tonumber(ToChangeBlock[1])
	ToChangeBlock[2] = tonumber(ToChangeBlock[2])
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )
	World = Player:GetWorld()
	Blocks[Player:GetName()] = 0
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	for X=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			for Z=0, BlockArea:GetSizeZ() - 1 do
				if BlockArea:GetRelBlockType( X, Y, Z ) == ChangeBlock[1] then
					if BlockArea:GetRelBlockMeta( X, Y, Z ) == ChangeBlock[2] or ChangeBlock[2] == nil then
						BlockArea:SetRelBlockType( X, Y, Z, ToChangeBlock[1] )
						BlockArea:SetRelBlockMeta( X, Y, Z, ToChangeBlock[2] )
						Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
					end
				end
			end
		end
	end
	BlockArea:Write( World, OneX, OneY, OneZ )
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " block(s) have been changed." )
	return true
end


-------------------------------------------------
----------------------WALLS----------------------
-------------------------------------------------
function HandleWallsCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	Block = StringSplit( Split[2], ":" )
	if Block[1] == nil then
		Block[1] = 0
	end
	if Block[2] == nil then
		Block[2] = 0
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )
	World = Player:GetWorld()	
	BlockArea:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Blocks[Player:GetName()] = 0
	Z = 0
	for X=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			BlockArea:SetRelBlockType( X, Y, Z, Block[1] )
			BlockArea:SetRelBlockMeta( X, Y, Z, Block[2] )
			Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
		end
	end
	Z = BlockArea:GetSizeZ() - 1
	for X=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			BlockArea:SetRelBlockType( X, Y, Z, Block[1] )
			BlockArea:SetRelBlockMeta( X, Y, Z, Block[2] )
			Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
		end
	end
	for Z=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1  do
			BlockArea:SetRelBlockType( X, Y, Z, Block[1] )
			BlockArea:SetRelBlockMeta( X, Y, Z, Block[2] )
			Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
		end
	end
	X = BlockArea:GetSizeX() - 1
	for Z=0, BlockArea:GetSizeX() - 1 do
		for Y=0, BlockArea:GetSizeY() - 1 do
			BlockArea:SetRelBlockType( X, Y, Z, Block[1] )
			BlockArea:SetRelBlockMeta( X, Y, Z, Block[2] )
			Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " block(s) have changed" )
	BlockArea:Write( World, OneX, OneY, OneZ )
	return true
end


------------------------------------------------
----------------------WAND----------------------
------------------------------------------------
function HandleWandCommand( Split, Player )
	Item = cItem( Wand, 1 )
	if( Player:GetInventory():AddItem( Item ) == true ) then
		Player:SendMessage( cChatColor.Green .. "You have a wooden axe now." )
	else
		Player:SendMessage( cChatColor.Green .. "Not enough inventory space" )
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


-----------------------------------------------
-------------------BIOMELIST-------------------
-----------------------------------------------
function HandleBiomeListCommand( Split, Player )
	if Split[2] == nil then 
		Split[2] = 1 
	end
	if tonumber(Split[2]) == 1 then
		Player:SendMessage( cChatColor.Green .. "Page 1" )
		Player:SendMessage( "Ocean" )
		Player:SendMessage( "Plains" )
		Player:SendMessage( "Desert" )
		Player:SendMessage( "Extreme_Hills" )
		Player:SendMessage( "Forest" )
		Player:SendMessage( "Taiga" )
		Player:SendMessage( "Swampland" )
		Player:SendMessage( "River" )
	elseif tonumber(Split[2]) == 2 then
		Player:SendMessage( cChatColor.Green .. "Page 2" )
		Player:SendMessage( "Hell" )
		Player:SendMessage( "Sky" )
		Player:SendMessage( "FrozenOcean" )
		Player:SendMessage( "FrozenRiver" )
		Player:SendMessage( "Ice_Plains" )
		Player:SendMessage( "Ice_Mountains" )
		Player:SendMessage( "MushroomIsland" )
		Player:SendMessage( "MushroomIslandShore" )
	elseif tonumber(Split[2]) == 3 then
		Player:SendMessage( cChatColor.Green .. "Page 3" )
		Player:SendMessage( "Beach" )
		Player:SendMessage( "DesertHills" )
		Player:SendMessage( "ForestHills" )
		Player:SendMessage( "TaigaHills " )
		Player:SendMessage( "Extreme_Hills_Edge" )
		Player:SendMessage( "Jungle" )
		Player:SendMessage( "JungleHills" )
	else
		Player:SendMessage( "/biomelist [1-3]" )
	end
	return true
end


------------------------------------------------
----------------------SNOW----------------------
------------------------------------------------
function HandleSnowCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /snow [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	Blocks[Player:GetName()] = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y , z) == 9 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 79, 0)
			elseif World:GetBlock(x, y , z) == 10 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 49, 0)
			else
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y + 1, z, 78, 0)
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " surfaces covered. Let is snow~" )
	return true
end


------------------------------------------------
----------------------THAW----------------------
------------------------------------------------
function HandleThawCommand( Split, Player )
	World = Player:GetWorld()
	if Split[2] == nil then
		Radius = 5
	elseif tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Green .. "Usage: /thaw [Radius]" )
	else
		Radius = Split[2]
	end
	X = Player:GetPosX()
	Z = Player:GetPosZ()
	Blocks[Player:GetName()] = 0
	for x=X - Radius, X + Radius do
		for z=Z - Radius, Z + Radius do
			y = World:GetHeight(x, z)
			if World:GetBlock(x, y, z) == 78 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 0, 0)
			elseif World:GetBlock(x, y, z) == 79 then
				Blocks[Player:GetName()] = Blocks[Player:GetName()] + 1
				World:SetBlock(x, y, z, 8, 0)
			end
		end
	end
	Player:SendMessage( cChatColor.LightPurple .. Blocks[Player:GetName()] .. " surfaces thawed" )
	return true
end


-----------------------------------------------
-------------------SUPERPICK-------------------
-----------------------------------------------
function HandleSuperPickCommand( Split, Player )
	if SP[Player:GetName()] == nil or SP[Player:GetName()] == false then
		SP[Player:GetName()] = true
		Player:SendMessage( cChatColor.LightPurple .. "Super pick activated" )
	elseif SP[Player:GetName()] == true then
		SP[Player:GetName()] = false
		Player:SendMessage( cChatColor.LightPurple .. "Super pick deactivated" )
	end
	return true
end