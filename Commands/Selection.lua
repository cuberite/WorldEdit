------------------------------------------------
----------------------REDO----------------------
------------------------------------------------
function HandleRedoCommand( Split, Player )
	if PersonalRedo[Player:GetName()]:GetSizeX() == 0 and PersonalRedo[Player:GetName()]:GetSizeY() == 0 and PersonalRedo[Player:GetName()]:GetSizeZ() == 0 or LastRedoCoords[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "Nothing left to redo" )
		return true
	end
	local Coords = StringSplit( LastRedoCoords[Player:GetName()], "," )
	local World = cRoot:Get():GetWorld( Coords[4] )
	PersonalUndo[Player:GetName()]:Read( World, Coords[1], Coords[1] + PersonalRedo[Player:GetName()]:GetSizeX() - 1, Coords[2], Coords[2] + PersonalRedo[Player:GetName()]:GetSizeY() - 1,Coords[3],  Coords[3] + PersonalRedo[Player:GetName()]:GetSizeZ() - 1 )
	LastCoords[Player:GetName()] = LastRedoCoords[Player:GetName()]
	PersonalRedo[Player:GetName()]:Write( World, Coords[1], Coords[2], Coords[3], 3 )
	LastRedoCoords[Player:GetName()] = nil
	Player:SendMessage( cChatColor.LightPurple .. "Redo Successful." )
	return true
end


------------------------------------------------
----------------------UNDO----------------------
------------------------------------------------
function HandleUndoCommand( Split, Player )
	if PersonalUndo[Player:GetName()]:GetSizeX() == 0 and PersonalUndo[Player:GetName()]:GetSizeY() == 0 and PersonalUndo[Player:GetName()]:GetSizeZ() == 0 or LastCoords[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "Nothing left to undo" )
		return true
	end
	local Coords = StringSplit( LastCoords[Player:GetName()], "," )
	local World = cRoot:Get():GetWorld( Coords[4] ) 
	PersonalRedo[Player:GetName()]:Read( World, Coords[1], Coords[1] + PersonalUndo[Player:GetName()]:GetSizeX() - 1, Coords[2], Coords[2] + PersonalUndo[Player:GetName()]:GetSizeY() - 1,Coords[3],  Coords[3] + PersonalUndo[Player:GetName()]:GetSizeZ() - 1 )
	LastRedoCoords[Player:GetName()] = LastCoords[Player:GetName()]
	PersonalUndo[Player:GetName()]:Write( World, Coords[1], Coords[2], Coords[3], 3 )
	Player:SendMessage( cChatColor.LightPurple .. "Undo Successful." )
	LastCoords[Player:GetName()] = nil
	return true
end


------------------------------------------------
----------------------SIZE----------------------
------------------------------------------------
function HandleSizeCommand( Split, Player )
	if OnePlayerX[Player:GetName()] ~= nil and TwoPlayerX[Player:GetName()] ~= nil then -- Check if there is a region selected 
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
	if PersonalUndo[Player:GetName()]:GetSizeX() == 0 and PersonalUndo[Player:GetName()]:GetSizeY() == 0 and PersonalUndo[Player:GetName()]:GetSizeZ() == 0 then
		Player:SendMessage( cChatColor.Rose .. "Your clipboard is empty. Use //copy first." )
		return true
	end
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	if PersonalBlockArea[Player:GetName()]:Write( Player:GetWorld(), Player:GetPosX(), Player:GetPosY(), Player:GetPosZ(), 3 ) == false then -- paste the area that the player copied
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
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- Check if there is a region selected
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- get the right coordinates
	local World = Player:GetWorld()
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	Player:SendMessage( cChatColor. LightPurple .. "Block(s) copied." )
	return true
end


-----------------------------------------------
----------------------CUT----------------------
-----------------------------------------------
function HandleCutCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- Check if there is a region selected
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- get the right coordinates
	local World = Player:GetWorld() -- get the world
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	Cut = cPersonalBlockArea[Player:GetName()]()
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	Cut:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	Cut:Fill( 3, 0, 0 ) -- delete the area
	Cut:Write( World, OneX, OneY, OneZ ) -- write the area
	Player:SendMessage( cChatColor. LightPurple .. "Block(s) cut." )
	return true
end


-----------------------------------------------
----------------------SET----------------------
-----------------------------------------------
function HandleSetCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- Check if there is a region selected
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil then -- check if the player noted a blocktype
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
		return true
	end
	Block = StringSplit( Split[2], ":" ) -- split to blocktype and meta
	if Block[1] == nil or tonumber(Block[1]) == nil then-- Blocktype
		Player:SendMessage( cChatColor.Rose .. "unexpected character." )
		return true
	end
	if Block[2] == nil or tonumber(Block[2]) == nil then -- Meta
		Block[2] = 0
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )	
	local World = Player:GetWorld()	
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	PersonalBlockArea[Player:GetName()]:Fill( 3, Block[1], Block[2] ) -- fill the area with the right blocks
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- write the area in the world
	Player:SendMessage( cChatColor.LightPurple .. GetSize( Player ) .. " block(s) have been changed." )
	return true
end


-------------------------------------------------
---------------------REPLACE---------------------
-------------------------------------------------
function HandleReplaceCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- Check if there is a region selected
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil or Split[3] == nil then -- check if the player noted a blocktype
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
		return true
	end
	local ChangeBlock = StringSplit( Split[2], ":" ) -- Split string to blocktype and meta
	if ChangeBlock[1] == nil or tonumber( ChangeBlock[1] ) == nil then -- to change blocktype
		Player:SendMessage( cChatColor.Rose .. "unexpected character." )
		return true
	end
	local ToChangeBlock = StringSplit( Split[3], ":" ) -- Split string to blocktype and meta
	if ToChangeBlock[1] == nil or tonumber( ToChangeBlock[1] ) == nil then
		Player:SendMessage( cChatColor.Rose .. "unexpected character." )
		return true
	end
	if ToChangeBlock[2] == nil or tonumber( ToChangeBlock[2] ) == nil then
		ToChangeBlock[2] = 0
	end
	ChangeBlock[1] = tonumber(ChangeBlock[1])
	if tonumber( ChangeBlock[2] ) ~= nil then
		ChangeBlock[2] = tonumber(ChangeBlock[2])
	end
	ToChangeBlock[1] = tonumber(ToChangeBlock[1])
	ToChangeBlock[2] = tonumber(ToChangeBlock[2])
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )
	local World = Player:GetWorld()
	local Blocks =  0
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- Read the area
	for X=0, PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 do
		for Y=0, PersonalBlockArea[Player:GetName()]:GetSizeY() - 1 do
			for Z=0, PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1 do
				if PersonalBlockArea[Player:GetName()]:GetRelBlockType( X, Y, Z ) == ChangeBlock[1] then -- if the blocktype is the same as the block that needs to change then
					if PersonalBlockArea[Player:GetName()]:GetRelBlockMeta( X, Y, Z ) == ChangeBlock[2] or ChangeBlock[2] == nil then -- check if the blockmeta is the same as the meta that has to change
						PersonalBlockArea[Player:GetName()]:SetRelBlockType( X, Y, Z, ToChangeBlock[1] ) -- change the block
						
						PersonalBlockArea[Player:GetName()]:SetRelBlockMeta( X, Y, Z, ToChangeBlock[2] ) -- change the meta
						Blocks = Blocks + 1 -- add a 1 to the amount of changed blocks.
					end
				end
			end
		end
	end
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- write the area into the world.
	Player:SendMessage( cChatColor.LightPurple .. Blocks .. " block(s) have been changed." )
	return true
end



-------------------------------------------------
----------------------FACES----------------------
-------------------------------------------------
function HandleFacesCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- Check if there is a region selected
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true -- stop
	end
	if Split[2] == nil then -- Check if the player gave a block id
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	local Block = StringSplit( Split[2], ":" ) -- Split the string to meta and blocktype
	if Block[1] == nil or tonumber(Block[1]) == nil then-- Blocktype
		Player:SendMessage( cChatColor.Rose .. "unexpected character." )
		return true
	end
	if Block[2] == nil or tonumber(Block[2]) == nil then -- Meta
		Block[2] = 0
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- get the coordinates
	local World = Player:GetWorld()	
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	local Blocks = ( 2 *  ( PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 + PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1 ) * PersonalBlockArea[Player:GetName()]:GetSizeY() ) -- calculate the amount of changed blocks.
	if Blocks == 0 then
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[Player:GetName()]:GetSizeX() - 1
	local YY = PersonalBlockArea[Player:GetName()]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, Z, Z, 3, Block[1], Block[2] ) -- Walls
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, ZZ, ZZ, 3, Block[1], Block[2] )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( XX, XX, Y, YY, Z, ZZ, 3, Block[1], Block[2] )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, X, Y, YY, Z, ZZ, 3, Block[1], Block[2] )
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, Y, Z, ZZ, 3, Block[1], Block[2] ) -- Floor
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, YY, YY, Z, ZZ, 3, Block[1], Block[2] ) -- Ceiling

	Player:SendMessage( cChatColor.LightPurple .. Blocks .. " block(s) have changed" )
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- write the area in the world.
	return true
end


-------------------------------------------------
----------------------WALLS----------------------
-------------------------------------------------
function HandleWallsCommand( Split, Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- Check if there is a region selected
		Player:SendMessage( cChatColor.Rose .. "No Region set" )
		return true
	end
	if Split[2] == nil then -- Check if the player gave a block id
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
	end
	local Block = StringSplit( Split[2], ":" ) -- Split the string to meta and blocktype
	if Block[1] == nil or tonumber(Block[1]) == nil then-- Blocktype
		Player:SendMessage( cChatColor.Rose .. "unexpected character." )
		return true
	end
	if Block[2] == nil or tonumber(Block[2]) == nil then -- Meta
		Block[2] = 0
	end
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- Get the right X, Y and Z coordinates
	local World = Player:GetWorld()	
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	local Blocks = ( 2 *  ( PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 + PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1 ) * PersonalBlockArea[Player:GetName()]:GetSizeY() ) -- Calculate the amount if blocks that are going to change
	if Blocks == 0 then -- if the wall is 1x1x1 then the amout of blocks changed are 1
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[Player:GetName()]:GetSizeX() - 1
	local YY = PersonalBlockArea[Player:GetName()]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, Z, Z, 3, Block[1], Block[2] )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, ZZ, ZZ, 3, Block[1], Block[2] )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( XX, XX, Y, YY, Z, ZZ, 3, Block[1], Block[2] )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, X, Y, YY, Z, ZZ, 3, Block[1], Block[2] )
	Player:SendMessage( cChatColor.LightPurple .. Blocks .. " block(s) have changed" )
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- Write the region into the world
	return true
end


------------------------------------------------
---------------------ROTATE---------------------
------------------------------------------------
function HandleRotateCommand( Split, Player )
	if Split[2] == nil or tonumber( Split[2] ) == nil then -- Check if the player gave an angle
		Player:SendMessage( cChatColor.Rose .. "Too few arguments.\n//rotate [90, 180, 270]" )
		return true
	else
		if tonumber( Split[2] ) == 90 or tonumber( Split[2] ) == 180 or tonumber( Split[2] ) == 270 then
			for I =1, tonumber(Split[2]) / 90 do -- rotate the area some times.
				PersonalBlockArea[Player:GetName()]:RotateCCW() -- Rotate the area
			end
			Player:SendMessage( cChatColor.Rose .. "Rotated clipboard " .. Split[2] .. " degrees" )
		else
			Player:SendMessage( cChatColor.Rose .. "usage: /rotate [90, 180, 270]" )
		end
	end
	return true
end


-----------------------------------------------
-------------------SCHEMATIC-------------------
-----------------------------------------------
function HandleSchematicCommand( Split, Player )
	if Split[2] ~= nil then 
		if string.upper(Split[2]) == "SAVE" or string.upper(Split[2]) == "L" then -- check if the player want to save a region.
			if Player:HasPermission("worldedit.schematic.save") then -- check if the player has the permission to use the command
				if Split[3] == nil then -- check if the player stated a name for the schematic.
					Player:SendMessage( cChatColor.Green .. "Please state a schematic name" )
					return true
				end	
				Schematic = io.open( "Schematics\\" .. Split[3] .. ".Schematic", "r" ) -- check if the schematic file already exists.
				if Schematic then -- check if the schematic exists
					Player:SendMessage( cChatColor.Rose .. "Schematic already exists" )
					Schematic:close() -- close the file
				else
					PersonalBlockArea[Player:GetName()]:SaveToSchematicFile( "Schematics/" .. Split[3] .. ".Schematic" ) -- save the schematic.
					Player:SendMessage( cChatColor.LightPurple .. Split[3] .. " saved."	)					
				end
			end
		elseif string.upper(Split[2]) == "LOAD" or string.upper(Split[2]) == "L" then -- check if the player wants to load a schematic
			if Player:HasPermission("worldedit.schematic.load") then -- check if the player has the permission to use the command
				if Split[3] == nil then -- check if the player stated a name of the schematic.
					Player:SendMessage( cChatColor.Green .. "Please state a schematic name" )
					return true
				end 	
				Schematic = io.open( "Schematics\\" .. Split[3] .. ".Schematic", "r" ) -- check if the schematic file already exists.
				if Schematic then -- check if the schematic exists
					PersonalBlockArea[Player:GetName()]:LoadFromSchematicFile( "Schematics/" .. Split[3] .. ".Schematic" ) -- load the schematic file
					Player:SendMessage( cChatColor.LightPurple .. "Clipboard " .. Split[3] .. " is loaded" ) 
					Schematic:close() -- close the file
				else
					Player:SendMessage( cChatColor.Rose .. "Schematic " .. Split[3] .. " does not exist" )
				end
			end
		elseif string.upper(Split[2]) == "DELETE" then -- check if the player wants to delete a file
			if Player:HasPermission("worldedit.schematic.delete") then
				if Split[3] == nil then
					Player:SendMessage( cChatColor.Green .. "Please state a schematic name" )
					return true
				end
				Schematic = io.open( "Schematics\\" .. Split[3] .. ".Schematic", "r" ) -- check if the schematic file already exists.
				if Schematic then
					Schematic:close() -- close the schematic file
					os.remove( "Schematics\\" .. Split[3] .. ".Schematic" ) -- remove the schematic file
					Player:SendMessage( cChatColor.LightPurple .. "Schematic " .. Split[3] .. " is deleted" ) 
				end
			end
		end
	else -- the command didn't exist or the player did not gave a command
		Player:SendMessage( cChatColor.LightPurple .. "//schematic <save:load:delete>" )
	end
	return true
end