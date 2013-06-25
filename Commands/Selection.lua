------------------------------------------------
---------------------EXPAND---------------------
------------------------------------------------
function HandleExpandCommand( Split, Player )
	if Split[2] == nil or tonumber(Split[2]) == nil then
		Player:SendMessage( cChatColor.Rose .. "Invaild arguments.\n//expand <amount>" )
		return true
	end
	if OnePlayerY[Player:GetName()] == nil or TwoPlayerY[Player:GetName()] == nil then
		Player:SendMessage( cChatColor.Rose .. "Make a region selection first." )
		return true
	end
	if OnePlayerY[Player:GetName()] > TwoPlayerY[Player:GetName()] then
		OnePlayerY[Player:GetName()] = OnePlayerY[Player:GetName()] + tonumber( Split[2] )
	else
		TwoPlayerY[Player:GetName()] = TwoPlayerY[Player:GetName()] + tonumber( Split[2] )
	end
	Player:SendMessage( cChatColor.LightPurple .. "Region expanded " .. Split[2] .. " blocks." )
	return true
end


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
	if PersonalBlockArea[Player:GetName()]:GetSizeX() == 0 and PersonalBlockArea[Player:GetName()]:GetSizeY() == 0 and PersonalBlockArea[Player:GetName()]:GetSizeZ() == 0 then
		Player:SendMessage( cChatColor.Rose .. "Your clipboard is empty. Use //copy first." )
		return true
	end
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( Player:GetWorld(), Player:GetPosX(), Player:GetPosX() + PersonalBlockArea[Player:GetName()]:GetSizeX(), Player:GetPosY(), Player:GetPosY() + PersonalBlockArea[Player:GetName()]:GetSizeY(), Player:GetPosZ(), Player:GetPosZ() + PersonalBlockArea[Player:GetName()]:GetSizeZ() )
	PersonalBlockArea[Player:GetName()]:Write( Player:GetWorld(), Player:GetPosX(), Player:GetPosY(), Player:GetPosZ(), 3 ) -- paste the area that the player copied
	Player:SendMessage( cChatColor.LightPurple .. "Pasted relative to you." )
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
		if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
		return true
	end
	local BlockType, BlockMeta = GetBlockTypeMeta( Player, Split[2] )
	if BlockType ~= false then
		Player:SendMessage( cChatColor.LightPurple .. HandleFillSelection( Player, Player:GetWorld(), BlockType, BlockMeta ) .. " block(s) have been changed." )
	end
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
	local ChangeBlockType, ChangeBlockMeta = GetBlockTypeMeta( Player, Split[2] )
	local ToChangeBlockType, ToChangeBlockMeta = GetBlockTypeMeta( Player, Split[3] )
	if ChangeBlockType ~= false and ToChangeBlockType ~= false then
		Player:SendMessage( cChatColor.LightPurple .. HandleReplaceSelection( Player, Player:GetWorld(), ChangeBlockType, ChangeBlockMeta, ToChangeBlockType, ToChangeBlockMeta ) .. " block(s) have been changed." )
	end
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
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
		return true
	end
	local BlockType, BlockMeta = GetBlockTypeMeta( Player, Split[2] )
	if BlockType ~= false then
		Player:SendMessage( cChatColor.LightPurple .. HandleCreateFaces( Player, Player:GetWorld(), BlockType, BlockMeta ) .. " block(s) have been changed." )
	end
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
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "Please say a block ID" )
		return true
	end
	local BlockType, BlockMeta = GetBlockTypeMeta( Player, Split[2] )
	if BlockType ~= false then
		Player:SendMessage( cChatColor.LightPurple .. HandleCreateWalls( Player, Player:GetWorld(), BlockType, BlockMeta ) .. " block(s) have been changed." )
	end
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
			if Player:HasPermission("worldedit.schematic.save") or Player:HasPermission("worldedit.*") then -- check if the player has the permission to use the command
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
			if Player:HasPermission("worldedit.schematic.load") or Player:HasPermission("worldedit.*") then -- check if the player has the permission to use the command
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
			if Player:HasPermission("worldedit.schematic.delete") or Player:HasPermission("worldedit.*") then
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