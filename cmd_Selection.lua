-----------------------------------------------
-------------------BIOMEINFO-------------------
-----------------------------------------------
function HandleBiomeInfoCommand(Split, Player)
	if Split[2] == "-p" then
		local Biome = GetStringFromBiome(Player:GetWorld():GetBiomeAt(math.floor(Player:GetPosX()), math.floor(Player:GetPosZ())))
		Player:SendMessage(cChatColor.LightPurple .. "Biome: " .. Biome)
		return true
	end
	
	local PlayerName = Player:GetName()
	if OnePlayer[PlayerName] == nil or TwoPlayer[PlayerName] == nil then
		Player:SendMessage(cChatColor.Rose .. "Make a region selection first.")
		return true
	end
	
	local BiomeList = {}
	local World = Player:GetWorld()
	local OneX, TwoX, OneZ, TwoZ = GetXZCoords(Player)
	for X = OneX, TwoX do
		for Z = OneZ, TwoZ do
			if not table.contains(BiomeList, GetStringFromBiome(World:GetBiomeAt(X, Z))) then
				BiomeList[#BiomeList + 1] = GetStringFromBiome(World:GetBiomeAt(X, Z))
			end
		end
	end
	Player:SendMessage(cChatColor.LightPurple .. "Biomes:\n " .. table.concat(BiomeList, "\n "))
	return true
end


------------------------------------------------
----------------------REDO----------------------
------------------------------------------------
function HandleRedoCommand(Split, Player)
	local PlayerName = Player:GetName()
	if PersonalRedo[PlayerName]:GetSizeX() == 0 and PersonalRedo[PlayerName]:GetSizeY() == 0 and PersonalRedo[PlayerName]:GetSizeZ() == 0 or LastRedoCoords[PlayerName] == nil then
		Player:SendMessage(cChatColor.Rose .. "Nothing left to redo")
		return true
	end
	
	local Coords = LastRedoCoords[PlayerName]
	
	local World = cRoot:Get():GetWorld(Coords.WorldName)
	PersonalUndo[PlayerName]:Read(World, Coords.X, Coords.X + PersonalRedo[PlayerName]:GetSizeX() - 1, Coords.Y, Coords.Y + PersonalRedo[PlayerName]:GetSizeY() - 1,Coords.Z,  Coords.Z + PersonalRedo[PlayerName]:GetSizeZ() - 1)
	LastCoords[PlayerName] = LastRedoCoords[PlayerName]
	PersonalRedo[PlayerName]:Write(World, Coords.X, Coords.Y, Coords.Z, 3)
	
	LastRedoCoords[PlayerName] = nil
	Player:SendMessage(cChatColor.LightPurple .. "Redo Successful.")
	return true
end


------------------------------------------------
----------------------UNDO----------------------
------------------------------------------------
function HandleUndoCommand(Split, Player)
	local PlayerName = Player:GetName()
	
	if PersonalUndo[PlayerName]:GetSizeX() == 0 and PersonalUndo[PlayerName]:GetSizeY() == 0 and PersonalUndo[PlayerName]:GetSizeZ() == 0 or LastCoords[PlayerName] == nil then
		Player:SendMessage(cChatColor.Rose .. "Nothing left to undo")
		return true
	end
	local Coords = LastCoords[PlayerName]
	local World = cRoot:Get():GetWorld(Coords.WorldName)
	
	PersonalRedo[PlayerName]:Read(World, Coords.X, Coords.X + PersonalUndo[PlayerName]:GetSizeX() - 1, Coords.Y, Coords.Y + PersonalUndo[PlayerName]:GetSizeY() - 1, Coords.Z,  Coords.Z + PersonalUndo[PlayerName]:GetSizeZ() - 1)
	LastRedoCoords[PlayerName] = LastCoords[PlayerName]
	PersonalUndo[PlayerName]:Write(World, Coords.X, Coords.Y, Coords.Z, 3)
	Player:SendMessage(cChatColor.LightPurple .. "Undo Successful.")
	
	LastCoords[PlayerName] = nil
	return true
end


------------------------------------------------
----------------------SIZE----------------------
------------------------------------------------
function HandleSizeCommand(Split, Player)
	if OnePlayer[Player:GetName()] ~= nil and TwoPlayer[Player:GetName()] ~= nil then -- Check if there is a region selected 
		Player:SendMessage(cChatColor.LightPurple .. "the selection is " .. GetSize(Player) .. " block(s) big")
	else
		Player:SendMessage(cChatColor.LightPurple .. "Please select a region first")
	end
	return true
end


-------------------------------------------------
----------------------PASTE----------------------
-------------------------------------------------
function HandlePasteCommand(Split, Player)
	local PlayerName = Player:GetName()
	if PersonalClipboard[PlayerName]:GetSizeX() == 0 and PersonalClipboard[PlayerName]:GetSizeY() == 0 and PersonalClipboard[PlayerName]:GetSizeZ() == 0 then
		Player:SendMessage(cChatColor.Rose .. "Your clipboard is empty. Use //copy first.")
		return true
	end
	
	local World = Player:GetWorld()
	local MinX = Player:GetPosX()
	local MinY = Player:GetPosY()
	local MinZ = Player:GetPosZ()
	local MaxX = MinX + PersonalClipboard[PlayerName]:GetSizeX()
	local MaxY = MinY + PersonalClipboard[PlayerName]:GetSizeY()
	local MaxZ = MinZ + PersonalClipboard[PlayerName]:GetSizeZ()
	
	if CheckIfInsideAreas(MinX, MaxX, MinY, MaxY, MinZ, MaxZ, Player, Player:GetWorld(), "paste") then -- Check if the clipboard intersects with any of the areas.
		return true
	end
	
	LastCoords[PlayerName] = {X = MinX, Y = MinY, Z = MinZ, WorldName = World:GetName()}
	
	PersonalUndo[PlayerName]:Read(World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	PersonalClipboard[PlayerName]:Write(World, MinX, MinY, MinZ, 3) -- paste the area that the player copied
	World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	Player:SendMessage(cChatColor.LightPurple .. "Pasted relative to you.")
	return true
end


------------------------------------------------
----------------------COPY----------------------
------------------------------------------------
function HandleCopyCommand(Split, Player)
	local PlayerName = Player:GetName()
	if OnePlayer[PlayerName] == nil or TwoPlayer[PlayerName] == nil then -- Check if there is a region selected
		Player:SendMessage(cChatColor.Rose .. "No Region set")
		return true
	end
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- get the right coordinates
	local World = Player:GetWorld()
	PersonalClipboard[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- read the area
	Player:SendMessage(cChatColor.LightPurple .. "Block(s) copied.")
	return true
end


-----------------------------------------------
----------------------CUT----------------------
-----------------------------------------------
function HandleCutCommand(Split, Player)
	local PlayerName = Player:GetName()
	
	if OnePlayer[PlayerName] == nil or TwoPlayer[PlayerName] == nil then -- Check if there is a region selected
		Player:SendMessage(cChatColor.Rose .. "No Region set")
		return true
	end
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- get the right coordinates
	
	if CheckIfInsideAreas(OneX, TwoX, OneY, TwoY, OneZ, TwoZ, Player, Player:GetWorld(), "cut") then -- Check if the clipboard intersects with any of the areas.
		return true
	end
	
	local World = Player:GetWorld() -- get the world

	LastCoords[PlayerName] = {X = OneX, Y = OneY, Z = OneZ, WorldName = World:GetName()}
	
	PersonalUndo[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	local Cut = cBlockArea()
	PersonalClipboard[PlayerName]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- read the area
	Cut:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- read the area
	Cut:Fill(3, 0, 0) -- delete the area
	Cut:Write(World, OneX, OneY, OneZ) -- write the area
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	Player:SendMessage(cChatColor. LightPurple .. "Block(s) cut.")
	return true
end


-----------------------------------------------
----------------------SET----------------------
-----------------------------------------------
function HandleSetCommand(Split, Player)
	local PlayerName = Player:GetName()
	
	if OnePlayer[PlayerName] == nil or TwoPlayer[PlayerName] == nil then -- Check if there is a region selected
		Player:SendMessage(cChatColor.Rose .. "No Region set")
		return true
	end
	
	if Split[2] == nil then
		Player:SendMessage(cChatColor.Rose .. "Please say a block ID")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(Player, Split[2])
	if BlockType ~= false then
		local Blocks = HandleFillSelection(Player, Player:GetWorld(), BlockType, BlockMeta)
		if Blocks then
			Player:SendMessage(cChatColor.LightPurple .. Blocks .. " block(s) have been changed.")
		end
	end
	return true
end


-------------------------------------------------
---------------------REPLACE---------------------
-------------------------------------------------
function HandleReplaceCommand(Split, Player)
	local PlayerName = Player:GetName()
	
	if OnePlayer[PlayerName] == nil or TwoPlayer[PlayerName] == nil then -- Check if there is a region selected
		Player:SendMessage(cChatColor.Rose .. "No Region set")
		return true
	end
	if Split[2] == nil or Split[3] == nil then -- check if the player noted a blocktype
		Player:SendMessage(cChatColor.Rose .. "Please say a block ID")
		return true
	end
	local ChangeBlockType, ChangeBlockMeta, TypeOnly = GetBlockTypeMeta(Player, Split[2])
	local ToChangeBlockType, ToChangeBlockMeta = GetBlockTypeMeta(Player, Split[3])
	if ChangeBlockType ~= false and ToChangeBlockType ~= false then
		local Blocks = HandleReplaceSelection(Player, Player:GetWorld(), ChangeBlockType, ChangeBlockMeta, ToChangeBlockType, ToChangeBlockMeta, TypeOnly)
		if Blocks then
			Player:SendMessage(cChatColor.LightPurple .. Blocks .. " block(s) have been changed.")
		end
	end
	return true
end



-------------------------------------------------
----------------------FACES----------------------
-------------------------------------------------
function HandleFacesCommand(Split, Player)
	local PlayerName = Player:GetName()
	
	if OnePlayer[PlayerName] == nil or TwoPlayer[PlayerName] == nil then -- Check if there is a region selected
		Player:SendMessage(cChatColor.Rose .. "No Region set")
		return true -- stop
	end
	if Split[2] == nil then
		Player:SendMessage(cChatColor.Rose .. "Please say a block ID")
		return true
	end
	local BlockType, BlockMeta = GetBlockTypeMeta(Player, Split[2])
	if BlockType ~= false then
		local Blocks = HandleCreateFaces(Player, Player:GetWorld(), BlockType, BlockMeta)
		if not Blocks then
			Player:SendMessage(cChatColor.Rose .. "Region intersects with an area")
		else
			Player:SendMessage(cChatColor.LightPurple .. Blocks .. " block(s) have been changed.")
		end
	end
	return true
end


-------------------------------------------------
----------------------WALLS----------------------
-------------------------------------------------
function HandleWallsCommand(Split, Player)
	local PlayerName = Player:GetName()
	
	if OnePlayer[PlayerName] == nil or TwoPlayer[PlayerName] == nil then -- Check if there is a region selected
		Player:SendMessage(cChatColor.Rose .. "No Region set")
		return true
	end
	if Split[2] == nil then
		Player:SendMessage(cChatColor.Rose .. "Please say a block ID")
		return true
	end
	local BlockType, BlockMeta = GetBlockTypeMeta(Player, Split[2])
	if BlockType ~= false then
		local Blocks = HandleCreateWalls(Player, Player:GetWorld(), BlockType, BlockMeta)
		if not Blocks then
			Player:SendMessage(cChatColor.Rose .. "Region intersects with an area")
		else
			Player:SendMessage(cChatColor.LightPurple .. Blocks .. " block(s) have been changed.")
		end
	end
	return true
end


------------------------------------------------
---------------------ROTATE---------------------
------------------------------------------------
function HandleRotateCommand(Split, Player)
	if Split[2] == nil or tonumber(Split[2]) == nil then -- Check if the player gave an angle
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n//rotate [90, 180, 270]")
		return true
	end
	if tonumber(Split[2]) == 90 or tonumber(Split[2]) == 180 or tonumber(Split[2]) == 270 then
		for I =1, tonumber(Split[2]) / 90 do -- rotate the area some times.
			PersonalClipboard[Player:GetName()]:RotateCCW() -- Rotate the area
		end
		Player:SendMessage(cChatColor.Rose .. "Rotated clipboard " .. Split[2] .. " degrees")
	else
		Player:SendMessage(cChatColor.Rose .. "usage: /rotate [90, 180, 270]")
	end
	return true
end


-----------------------------------------------
-------------------SCHEMATIC-------------------
-----------------------------------------------
-- Handles the schematic's save subcommand
function HandleSchematicSaveCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "worldedit.schematic.save", "worldedit.clipboard.save") then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to save schematic files.")
		return true
	end
	if #Split ~= 4 then
		Player:SendMessage(cChatColor.Rose .. "Usage: /schematic save <Format> <Name>")
		return true
	end
	local Scheme = string.upper(Split[3])
	
	if Scheme == "MCEDIT" then
		local SchematicName = Split[4]
		PersonalClipboard[Player:GetName()]:SaveToSchematicFile("Schematics/" .. Split[4] .. ".Schematic") -- save the schematic.
		Player:SendMessage(cChatColor.LightPurple .. Split[4] .. " saved.")
	else
		Player:SendMessage("Scheme " .. Split[3] .. "Does not exist.")
	end
	return true
end


-- Handles the schematic's load subcommand.
function HandleSchematicLoadCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "worldeidt.schematic.load", "worldedit.clipboard.load") then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to load schematic file.")
		return true
	end
	if #Split ~= 3 then
		Player:SendMessage(cChatColor.Rose .. "Usage: /schematic load <name>")
		return true
	end
	local Path = "Schematics/" .. Split[3] .. ".Schematic"
	if not cFile:Exists(Path) then
		Player:SendMessage(cChatColor.LightPurple .. "schematic does not exist.")
		return true
	end
	PersonalClipboard[Player:GetName()]:LoadFromSchematicFile(Path) -- load the schematic file
	Player:SendMessage(cChatColor.LightPurple .. "You loaded " .. Split[3])
	return true
end


-- Handles the schematic's formats subcommand.
function HandleSchematicFormatsCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "worldedit.schematic.formats") then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to use this command.")
		return true
	end
	Player:SendMessage(cChatColor.LightPurple .. 'Available formats: "MCEdit"')
	return true
end


-- Handles the schematic's list subcommand.
function HandleSchematicListCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "worldeidt.schematic.list") then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to use this command.")
		return true
	end
	local FileList = cFile:GetFolderContents("Schematics")
	for Idx, FileName in ipairs(FileList) do
		FileList[Idx] = FileName:sub(1, FileName:len() - 10) -- Remove the extension part of the filename.
	end
	
	Player:SendMessage(cChatColor.LightPurple .. "Available schematics: " .. table.concat(FileList, ", ", 3))
	return true
end


----------------------------------------------
--------------------EXPAND--------------------
----------------------------------------------
function HandleExpandCommand(Split, Player)
	if #Split == 1 then
		Player:SendMessage("More parameters needed.")
		Player:SendMessage("//expand <Direction> [Blocks]")
		return true
	end
	
	if GetSize(Player) == -1 then
		Player:SendMessage(cChatColor.Rose .. "You don't have anything selected.")
		return true
	end
	
	local PlayerName = Player:GetName()
	local Direction = string.upper(Split[2])
	local Blocks = 1
	
	if #Split == 3 then
		if tonumber(Split[3]) == nil then
			Player:SendMessage(cChatColor.Rose .. "Unknown char \"" .. Split[3] .. "\" number expected.")
			return true
		end
		Blocks = tonumber(Split[3])
	end
	
	if Direction == "UP" then
		if OnePlayer[PlayerName].y < TwoPlayer[PlayerName].y then
			SetPlayerSelectionPoint(Player, TwoPlayer[PlayerName].x, TwoPlayer[PlayerName].y + Blocks, TwoPlayer[PlayerName].z, E_SELECTIONPOINT_RIGHT)
		else
			SetPlayerSelectionPoint(Player, OnePlayer[PlayerName].x, OnePlayer[PlayerName].y + Blocks, OnePlayer[PlayerName].z, E_SELECTIONPOINT_LEFT)
		end
		return true
	elseif Direction == "DOWN" then
		if OnePlayer[PlayerName].y > TwoPlayer[PlayerName].y then
			SetPlayerSelectionPoint(Player, TwoPlayer[PlayerName].x, TwoPlayer[PlayerName].y - Blocks, TwoPlayer[PlayerName].z, E_SELECTIONPOINT_RIGHT)
		else
			SetPlayerSelectionPoint(Player, OnePlayer[PlayerName].x, OnePlayer[PlayerName].y - Blocks, OnePlayer[PlayerName].z, E_SELECTIONPOINT_LEFT)
		end
		return true
	end
	
	local LookDirection = Round((Player:GetYaw() + 180) / 90)
	local FinalDirection = 0
	if Direction == "LEFT" then
		if LookDirection == E_DIRECTION_SOUTH then
			FinalDirection = E_DIRECTION_EAST
		elseif LookDirection == E_DIRECTION_EAST then
			FinalDirection = E_DIRECTION_NORTH1
		elseif LookDirection == E_DIRECTION_NORTH1 or LookDirection == E_DIRECTION_NORTH2 then
			FinalDirection = E_DIRECTION_WEST
		elseif LookDirection == E_DIRECTION_WEST then
			FinalDirection = E_DIRECTION_SOUTH
		end
	elseif Direction == "RIGHT" then
		if LookDirection == E_DIRECTION_SOUTH then
			FinalDirection = E_DIRECTION_WEST
		elseif LookDirection == E_DIRECTION_EAST then
			FinalDirection = E_DIRECTION_SOUTH
		elseif LookDirection == E_DIRECTION_NORTH1 or LookDirection == E_DIRECTION_NORTH2 then
			FinalDirection = E_DIRECTION_EAST
		elseif LookDirection == E_DIRECTION_WEST then
			FinalDirection = E_DIRECTION_NORTH1
		end
	elseif Direction == "SOUTH" then
		FinalDirection = E_DIRECTION_SOUTH
	elseif Direction == "EAST" then
		FinalDirection = E_DIRECTION_EAST
	elseif Direction == "NORTH" then
		FinalDirection = E_DIRECTION_NORTH1
	elseif Direction == "WEST" then
		FinalDirection = E_DIRECTION_WEST
	elseif Direction == "FORWARD" then
		FinalDirection = LookDirection
	elseif Direction == "BACKWARDS" or Direction == "BACK" then
		if LookDirection == E_DIRECTION_SOUTH then
			FinalDirection = E_DIRECTION_NORTH1
		elseif LookDirection == E_DIRECTION_EAST then
			FinalDirection = E_DIRECTION_WEST
		elseif LookDirection == E_DIRECTION_NORTH1 or LookDirection == E_DIRECTION_NORTH2 then
			FinalDirection = E_DIRECTION_SOUTH
		elseif LookDirection == E_DIRECTION_WEST then
			FinalDirection = E_DIRECTION_EAST
		end
	end
	
	if FinalDirection == E_DIRECTION_EAST then
		if OnePlayer[PlayerName].x < TwoPlayer[PlayerName].x then
			SetPlayerSelectionPoint(Player, TwoPlayer[PlayerName].x + Blocks, TwoPlayer[PlayerName].y, TwoPlayer[PlayerName].z, E_SELECTIONPOINT_RIGHT)
		else
			SetPlayerSelectionPoint(Player, OnePlayer[PlayerName].x + Blocks, OnePlayer[PlayerName].y, OnePlayer[PlayerName].z, E_SELECTIONPOINT_LEFT)
		end
	elseif FinalDirection == E_DIRECTION_SOUTH then
		if OnePlayer[PlayerName].z < TwoPlayer[PlayerName].z then
			SetPlayerSelectionPoint(Player, TwoPlayer[PlayerName].x, TwoPlayer[PlayerName].y, TwoPlayer[PlayerName].z + Blocks, E_SELECTIONPOINT_RIGHT)
		else
			SetPlayerSelectionPoint(Player, OnePlayer[PlayerName].x, OnePlayer[PlayerName].y, OnePlayer[PlayerName].z + Blocks, E_SELECTIONPOINT_LEFT)
		end
	elseif FinalDirection == E_DIRECTION_NORTH1  or FinalDirection == E_DIRECTION_NORTH2 then
		if OnePlayer[PlayerName].z > TwoPlayer[PlayerName].z then
			SetPlayerSelectionPoint(Player, TwoPlayer[PlayerName].x, TwoPlayer[PlayerName].y, TwoPlayer[PlayerName].z - Blocks, E_SELECTIONPOINT_RIGHT)
		else
			SetPlayerSelectionPoint(Player, OnePlayer[PlayerName].x, OnePlayer[PlayerName].y, OnePlayer[PlayerName].z - Blocks, E_SELECTIONPOINT_LEFT)
		end
	elseif FinalDirection == E_DIRECTION_WEST then
		if OnePlayer[PlayerName].x > TwoPlayer[PlayerName].x then
			SetPlayerSelectionPoint(Player, TwoPlayer[PlayerName].x - Blocks, TwoPlayer[PlayerName].y, TwoPlayer[PlayerName].z, E_SELECTIONPOINT_RIGHT)
		else
			SetPlayerSelectionPoint(Player, OnePlayer[PlayerName].x - Blocks, OnePlayer[PlayerName].y, OnePlayer[PlayerName].z, E_SELECTIONPOINT_LEFT)
		end
	end
	return true
end