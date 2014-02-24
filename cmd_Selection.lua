
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
	-- //expand [Amount] [Direction]
	
	local State = GetPlayerState(Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	if Split[2] ~= nil and tonumber(Split[2]) == nil then
		Player:SendMessage(cChatColor.Rose .. "Usage: //expand [Blocks] [Direction]")
		return true
	end
	
	local Blocks = Split[2] or 1 -- Use the given amount or 1 if nil
	local Direction = string.lower(Split[3] or "forward")
	local SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ = 0, 0, 0, 0, 0, 0
	local LookDirection = Round((Player:GetYaw() + 180) / 90)
	
	if Direction == "up" then
		AddMaxY = Blocks
	elseif Direction == "down" then
		SubMinY = Blocks
	elseif Direction == "left" then
		if LookDirection == E_DIRECTION_SOUTH then
			AddMaxX = Blocks
		elseif LookDirection == E_DIRECTION_EAST then
			SubMinZ = Blocks
		elseif LookDirection == E_DIRECTION_NORTH1 or LookDirection == E_DIRECTION_NORTH2 then
			SubMinX = Blocks
		elseif LookDirection == E_DIRECTION_WEST then
			AddMaxZ = Blocks
		end
	elseif Direction == "right" then
		if LookDirection == E_DIRECTION_SOUTH then
			SubMinX = Blocks
		elseif LookDirection == E_DIRECTION_EAST then
			AddMaxZ = Blocks
		elseif LookDirection == E_DIRECTION_NORTH1 or LookDirection == E_DIRECTION_NORTH2 then
			AddMaxX = Blocks
		elseif LookDirection == E_DIRECTION_WEST then
			SubMinZ = Blocks
		end
	elseif Direction == "south" then
		AddMaxZ = Blocks
	elseif Direction == "east" then
		AddMaxX = Blocks
	elseif Direction == "north" then
		SubMinZ = Blocks
	elseif Direction == "west" then
		SubMinX = Blocks
	elseif Direction == "forward" then
		if LookDirection == E_DIRECTION_SOUTH then
			AddMaxZ = Blocks
		elseif LookDirection == E_DIRECTION_EAST then
			AddMaxX = Blocks
		elseif LookDirection == E_DIRECTION_NORTH1 or LookDirection == E_DIRECTION_NORTH2 then
			SubMinZ = Blocks
		elseif LookDirection == E_DIRECTION_WEST then
			SubMinX = Blocks
		end
	elseif Direction == "backwards" or Direction == "back" then
		if LookDirection == E_DIRECTION_SOUTH then
			SubMinZ = Blocks
		elseif LookDirection == E_DIRECTION_EAST then
			SubMinX = Blocks
		elseif LookDirection == E_DIRECTION_NORTH1 or LookDirection == E_DIRECTION_NORTH2 then
			AddMaxZ = Blocks
		elseif LookDirection == E_DIRECTION_WEST then
			AddMaxX = Blocks
		end
	else
		Player:SendMessage(cChatColor.Rose .. "Unknown direction \"" .. Direction .. "\".")
		return true
	end
	
	State.Selection:Expand(SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ)
	Player:SendMessage(cChatColor.LightPurple .. "Expaned the area " .. Blocks .. " block(s) " .. Direction)
	return true
end