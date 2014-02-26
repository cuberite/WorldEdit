
-- cmd_Selection.lua

-- Implements handlers for the selection-related commands




function HandleBiomeInfoCommand(Split, Player)
	-- /biomeinfo

	-- If a "-p" param is present, report the biome at player's position:
	if (Split[2] == "-p") then
		local Biome = GetStringFromBiome(Player:GetWorld():GetBiomeAt(math.floor(Player:GetPosX()), math.floor(Player:GetPosZ())))
		Player:SendMessage(cChatColor.LightPurple .. "Biome: " .. Biome)
		return true
	end
	
	-- Get the player state:
	local State = GetPlayerState(Player)
	if not(State.Selection:IsValid()) then
		Player:SendMessage(cChatColor.Rose .. "Make a region selection first.")
		return true
	end
	
	-- Retrieve set of biomes in the selection:
	local BiomesSet = {}
	local MinX, MaxX = State.Selection:GetXCoordsSorted()
	local MinZ, MaxZ = State.Selection:GetZCoordsSorted()
	local World = Player:GetWorld()
	for X = MinX, MaxX do
		for Z = MinZ, MaxZ do
			BiomesSet[World:GetBiomeAt(X, Z)] = true
		end
	end
	
	-- Convert set to array of names:
	local BiomesArr = {}
	for b, val in pairs(BiomesSet) do
		if (val) then
			table.insert(BiomesArr, GetStringFromBiome(b))
		end
	end
	
	-- Send the list to the player:
	Player:SendMessage(cChatColor.LightPurple .. "Biomes: " .. table.concat(BiomesArr, ", "))
	return true
end





function HandleRedoCommand(a_Split, a_Player)
	-- //redo
	local State = GetPlayerState(a_Player)
	local IsSuccess, Msg = State.UndoStack:Redo(a_Player:GetWorld())
	if (IsSuccess) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Redo Successful.")
	else
		a_Player:SendMessage(cChatColor.Rose .. "Cannot redo: " .. (Msg or "<unknown error>"))
	end
	return true
end





function HandleUndoCommand(a_Split, a_Player)
	-- //undo
	local State = GetPlayerState(a_Player)
	local IsSuccess, Msg = State.UndoStack:Undo(a_Player:GetWorld())
	if (IsSuccess) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Undo Successful.")
	else
		a_Player:SendMessage(cChatColor.Rose .. "Cannot undo: " .. (Msg or "<unknown error>"))
	end
	return true
end





function HandleSizeCommand(a_Split, a_Player)
	-- //size
	local State = GetPlayerState(a_Player)
	if (State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.LightPurple .. "The selection size is " .. State.Selection:GetSizeDesc() .. ".")
	else
		a_Player:SendMessage(cChatColor.LightPurple .. "Please select a region first")
	end
	return true
end





function HandlePasteCommand(a_Split, a_Player)
	-- //paste

	-- Check if there's anything in the clipboard:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Your clipboard is empty. Use //copy or //cut first.")
		return true
	end
	
	-- Check with other plugins if the operation is okay:
	local DstCuboid = State.Clipboard:GetPasteDestCuboid(a_Player)
	if not(CheckAreaCallbacks(DstCuboid, a_Player, a_Player:GetWorld(), "paste")) then
		return
	end
	
	-- Paste:
	State.UndoStack:PushUndoFromCuboid(a_Player:GetWorld(), DstCuboid, "paste")
	local NumBlocks = State.Clipboard:Paste(a_Player, DstCuboid.p1)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) pasted relative to you.")
	return true
end





function HandleCopyCommand(a_Split, a_Player)
	-- //copy
	
	-- Get the player state:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Make a region selection first.")
		return true
	end
	
	-- Check with other plugins if the operation is okay:
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if not(CheckAreaCallbacks(SrcCuboid, a_Player, World, "copy")) then
		return
	end
	
	-- Cut into the clipboard:
	local NumBlocks = State.Clipboard:Copy(World, SrcCuboid)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) copied.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	return true
end





function HandleCutCommand(a_Split, a_Player)
	-- //cut
	
	-- Get the player state:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Make a region selection first.")
		return true
	end
	
	-- Check with other plugins if the operation is okay:
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if not(CheckAreaCallbacks(SrcCuboid, a_Player, World, "copy")) then
		return
	end
	
	-- Push an undo snapshot:
	State.UndoStack:PushUndoFromCuboid(World, SrcCuboid, "cut")
	
	-- Cut into the clipboard:
	local NumBlocks = State.Clipboard:Cut(World, SrcCuboid)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) cut.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	return true
end





function HandleSetCommand(a_Split, a_Player)
	-- //set <blocktype>
	
	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //set <BlockType>")
		return true
	end
	
	-- Retrieve the blocktype from the params:
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Player, a_Split[2])
	if not(BlockType) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[2] .. "'.")
		return true
	end
	
	-- Fill the selection:
	local NumBlocks = FillSelection(State, a_Player, a_Player:GetWorld(), BlockType, BlockMeta)
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end





function HandleReplaceCommand(a_Split, a_Player)
	-- //replace <srcblocktype> <dstblocktype>
	
	local State = GetPlayerState(a_Player)
	
	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	-- Check the params:
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //replace <SrcBlockType> <DstBlockType>")
		return true
	end
	
	-- Retrieve the blocktypes from the params:
	local SrcBlockType, SrcBlockMeta, TypeOnly = GetBlockTypeMeta(a_Player, a_Split[2])
	if not(SrcBlockType) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown src block type: '" .. a_Split[2] .. "'.")
		return true
	end
	local DstBlockType, DstBlockMeta = GetBlockTypeMeta(a_Player, a_Split[3])
	if not(DstBlockType) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown dst block type: '" .. a_Split[3] .. "'.")
		return true
	end
	
	-- Replace the blocks:
	local NumBlocks = ReplaceSelection(State, a_Player, a_Player:GetWorld(), SrcBlockType, SrcBlockMeta, DstBlockType, DstBlockMeta, TypeOnly)
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end





function HandleFacesCommand(a_Split, a_Player)
	-- //faces <blocktype>
	
	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //faces <BlockType>")
		return true
	end
	
	-- Retrieve the blocktype from the params:
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Player, a_Split[2])
	if not(BlockType) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[2] .. "'.")
		return true
	end
	
	-- Fill the selection:
	local NumBlocks = FillFaces(State, a_Player, a_Player:GetWorld(), BlockType, BlockMeta)
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end





function HandleWallsCommand(a_Split, a_Player)
	-- //walls <blocktype>
	
	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //walls <BlockType>")
		return true
	end
	
	-- Retrieve the blocktype from the params:
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Player, a_Split[2])
	if not(BlockType) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[2] .. "'.")
		return true
	end
	
	-- Fill the selection:
	local NumBlocks = FillWalls(State, a_Player, a_Player:GetWorld(), BlockType, BlockMeta)
	if (NumBlocks) then
		a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) have been changed.")
	end
	return true
end





function HandleRotateCommand(a_Split, a_Player)
	-- //rotate [NumDegrees]
	
	-- Check if the clipboard is valid:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Nothing in the clipboard. Use //copy or //cut first.")
		return true
	end
	
	-- Check if the player gave an angle:
	local Angle = tonumber(a_Split[2])
	if (Angle == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //rotate [90, 180, 270, -90, -180, -270]")
		return true
	end
	
	-- Rotate the clipboard:
	local NumRots = math.floor(Angle / 90 + 0.5)  -- round to nearest 90-degree step
	State.Clipboard:Rotate(NumRots)
	a_Player:SendMessage(cChatColor.LightPurple .. "Rotated the clipboard by " .. (NumRots * 90) .. " degrees CCW")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	return true
end





function HandleSchematicSaveCommand(a_Split, a_Player)
	-- //schematic save [<format>] <FileName>

	-- Get the parameters from the command arguments:
	local FileName
	if (#a_Split == 4) then
		FileName = a_Split[4]
	elseif (#a_Split == 3) then
		FileName = a_Split[3]
	else
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //schematic save [<format>] <FileName>")
		return true
	end
	
	-- Check that there's data in the clipboard:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "There's no data in the clipboard. Use //copy or //cut first.")
		return true
	end

	-- Save the clipboard:
	State.Clipboard:SaveToSchematicFile("schematics/" .. FileName .. ".schematic")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard saved to " .. FileName .. ".")
	return true
end





function HandleSchematicLoadCommand(a_Split, a_Player)
	-- //schematic load <FileName>
	
	-- Check the FileName parameter:
	if (#a_Split ~= 3) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /schematic load <FileName>")
		return true
	end
	local FileName = a_Split[3]
	
	-- Check if the file exists:
	local Path = "schematics/" .. FileName .. ".schematic"
	if not(cFile:Exists(Path)) then
		a_Player:SendMessage(cChatColor.Rose .. FileName .. " schematic does not exist.")
		return true
	end
	
	-- Load the file into clipboard:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:LoadFromSchematicFile(Path)) then
		a_Player:SendMessage(cChatColor.Rose .. FileName .. " schematic does not exist.")
		return true
	end
	a_Player:SendMessage(cChatColor.LightPurple .. FileName .. " schematic was loaded into your clipboard.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	return true
end





function HandleSchematicFormatsCommand(a_Split, a_Player)
	-- //schematic listformats
	
	-- We support only one format, MCEdit:
	a_Player:SendMessage(cChatColor.LightPurple .. 'Available formats: "MCEdit"')
	return true
end





function HandleSchematicListCommand(Split, Player)
	-- //schematic list
	
	-- Retrieve all the objects in the folder:
	local FolderContents = cFile:GetFolderContents("schematics")
	
	-- Filter out non-files and non-".schematic" files:
	local FileList = {}
	for idx, fnam in ipairs(FolderContents) do
		if (
			cFile:IsFile("schematics/" .. fnam) and
			fnam:match(".*%.schematic")
		) then
			table.insert(FileList, fnam:sub(1, fnam:len() - 10))  -- cut off the ".schematic" part of the name
		end
	end
	table.sort(FileList,
		function(f1, f2)
			return (string.lower(f1) < string.lower(f2))
		end
	)
	
	Player:SendMessage(cChatColor.LightPurple .. "Available schematics: " .. table.concat(FileList, ", "))
	return true
end





function HandleExpandCommand(a_Split, a_Player)
	-- //expand [Amount] [Direction]
	
	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	if (a_Split[2] ~= nil) and (tonumber(a_Split[2]) == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //expand [Blocks] [Direction]")
		return true
	end
	
	local NumBlocks = a_Split[2] or 1 -- Use the given amount or 1 if nil
	local Direction = string.lower(a_Split[3] or "forward")
	local SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ = 0, 0, 0, 0, 0, 0
	local LookDirection = Round((a_Player:GetYaw() + 180) / 90)
	
	if (Direction == "up") then
		AddMaxY = NumBlocks
	elseif (Direction == "down") then
		SubMinY = NumBlocks
	elseif (Direction == "left") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			AddMaxX = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			SubMinZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			SubMinX = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			AddMaxZ = NumBlocks
		end
	elseif (Direction == "right") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			SubMinX = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			AddMaxZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			AddMaxX = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			SubMinZ = NumBlocks
		end
	elseif (Direction == "south") then
		AddMaxZ = NumBlocks
	elseif (Direction == "east") then
		AddMaxX = NumBlocks
	elseif (Direction == "north") then
		SubMinZ = NumBlocks
	elseif (Direction == "west") then
		SubMinX = NumBlocks
	elseif ((Direction == "forward") or (Direction == "me")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			AddMaxZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			AddMaxX = NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			SubMinZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			SubMinX = NumBlocks
		end
	elseif ((Direction == "backwards") or (Direction == "back")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			SubMinZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			SubMinX = NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			AddMaxZ = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			AddMaxX = NumBlocks
		end
	else
		a_Player:SendMessage(cChatColor.Rose .. "Unknown direction \"" .. Direction .. "\".")
		return true
	end
	
	State.Selection:Expand(SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ)
	a_Player:SendMessage(cChatColor.LightPurple .. "Expaned the selection.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Selection is now " .. State.Selection:GetSizeDesc())
	return true
end




