
-- Selection.lua

-- Implements handlers for the selection-related commands





function HandleCountCommand(a_Split, a_Player)
	-- //count <blocktype>
	
	local State = GetPlayerState(a_Player)

	-- Check the selection:
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	-- Check the params:
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //count <BlockType>")
		return true
	end
	
	-- Retrieve the blocktypes from the params:
	local RawDstBlockTable = StringSplit(a_Split[2], ",")
	local BlockTable = {}
	for Idx, Value in ipairs(RawDstBlockTable) do
		local BlockType, BlockMeta, TypeOnly = GetBlockTypeMeta(Value)
		if not(BlockType) then
			a_Player:SendMessage(cChatColor.Rose .. "Unknown dst block type: '" .. Value .. "'.")
			return true
		end
		BlockTable[BlockType] = {BlockMeta = BlockMeta, TypeOnly = TypeOnly or false}
	end
	
	-- Count the blocks:
	local NumBlocks = CountBlocks(State, a_Player, a_Player:GetWorld(), BlockTable)
	a_Player:SendMessage(cChatColor.LightPurple .. "Counted: " .. NumBlocks)
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

	if (a_Split[2] == "vert") then
		State.Selection.Cuboid.p1.y = 0
		State.Selection.Cuboid.p2.y = 255

		a_Player:SendMessage(cChatColor.LightPurple .. "Expanded the selection from top to bottom.")
		a_Player:SendMessage(cChatColor.LightPurple .. "Selection is now " .. State.Selection:GetSizeDesc())
		return true
	end
	
	if (a_Split[2] ~= nil) and (tonumber(a_Split[2]) == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //expand [Blocks] [Direction]")
		return true
	end
	
	local NumBlocks = a_Split[2] or 1 -- Use the given amount or 1 if nil
	local Direction = string.lower(a_Split[3] or ((a_Player:GetPitch() > 70) and "down") or ((a_Player:GetPitch() < -70) and "up") or "forward")
	local SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ = 0, 0, 0, 0, 0, 0
	local LookDirection = math.round((a_Player:GetYaw() + 180) / 90)
	
	if ((Direction == "up") or (Direction == "u")) then
		AddMaxY = NumBlocks
	elseif ((Direction == "down") or (Direction == "d")) then
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
	elseif (Direction == "walls") then
		AddMaxX = NumBlocks
		AddMaxZ = NumBlocks
		SubMinX = NumBlocks
		SubMinZ = NumBlocks
	elseif ((Direction == "all") or (Direction == "faces")) then
		AddMaxX = NumBlocks
		AddMaxY = NumBlocks
		AddMaxZ = NumBlocks
		SubMinX = NumBlocks
		SubMinY = NumBlocks
		SubMinZ = NumBlocks
	else
		a_Player:SendMessage(cChatColor.Rose .. "Unknown direction \"" .. Direction .. "\".")
		return true
	end

	-- Expand the region
	State.Selection:Expand(SubMinX, SubMinY, SubMinZ, AddMaxX, AddMaxY, AddMaxZ)
	a_Player:SendMessage(cChatColor.LightPurple .. "Expanded the selection.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Selection is now " .. State.Selection:GetSizeDesc())
	return true
end





-- TODO: Make the HPos and Pos command use 2 handlers (HandleHPosCommand and HandlePosCommand)
function HandleHPos1Command(a_Split, a_Player)
	-- //hpos1
	
	-- Trace the blocks along the player's look vector until a hit is found:
	local Target = HPosSelect(a_Player)
	if not(Target) then
		a_Player:SendMessage(cChatColor.Rose .. "You were not looking at a block.")
		return true
	end
	
	-- Select the block:
	local State = GetPlayerState(a_Player)
	State.Selection:SetFirstPoint(Target.x, Target.y, Target.z)
	a_Player:SendMessage("First position set to {" .. Target.x .. ", " .. Target.y .. ", " .. Target.z .. "}.")
	return true
end





function HandleHPos2Command(a_Split, a_Player)
	-- //hpos2
	
	-- Trace the blocks along the player's look vector until a hit is found:
	local Target = HPosSelect(a_Player)
	if not(Target) then
		a_Player:SendMessage(cChatColor.Rose .. "You were not looking at a block.")
		return true
	end
	
	-- Select the block:
	local State = GetPlayerState(a_Player)
	State.Selection:SetSecondPoint(Target.x, Target.y, Target.z)
	a_Player:SendMessage("Second position set to {" .. Target.x .. ", " .. Target.y .. ", " .. Target.z .. "}.")
	return true
end





function HandlePos1Command(a_Split, a_Player)
	-- //pos1
	local State = GetPlayerState(a_Player)
	local BlockX = math.floor(a_Player:GetPosX())
	local BlockY = math.floor(a_Player:GetPosY())
	local BlockZ = math.floor(a_Player:GetPosZ())
	State.Selection:SetFirstPoint(BlockX, BlockY, BlockZ)
	a_Player:SendMessage(cChatColor.LightPurple .. "First position set to {" .. BlockX .. ", " .. BlockY .. ", " .. BlockZ .. "}.")
	return true
end





function HandlePos2Command(a_Split, a_Player)
	-- //pos2
	local State = GetPlayerState(a_Player)
	local BlockX = math.floor(a_Player:GetPosX())
	local BlockY = math.floor(a_Player:GetPosY())
	local BlockZ = math.floor(a_Player:GetPosZ())
	State.Selection:SetSecondPoint(BlockX, BlockY, BlockZ)
	a_Player:SendMessage(cChatColor.LightPurple .. "Second position set to {" .. BlockX .. ", " .. BlockY .. ", " .. BlockZ .. "}.")
	return true
end





function HandleShiftCommand(a_Split, a_Player)
	-- //shift [Amount] [Direction]
	
	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	if (a_Split[2] ~= nil) and (tonumber(a_Split[2]) == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //shift [Blocks] [Direction]")
		return true
	end
	
	local NumBlocks = a_Split[2] or 1 -- Use the given amount or 1 if nil
	local Direction = string.lower(a_Split[3] or ((a_Player:GetPitch() > 70) and "down") or ((a_Player:GetPitch() < -70) and "up") or "forward")
	local X, Y, Z = 0, 0, 0
	local LookDirection = math.round((a_Player:GetYaw() + 180) / 90)
	
	if (Direction == "up") then
		Y = NumBlocks
	elseif (Direction == "down") then
		Y = -NumBlocks
	elseif (Direction == "left") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			X = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			Z = -NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			X = -NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			Z = NumBlocks
		end
	elseif (Direction == "right") then
		if (LookDirection == E_DIRECTION_SOUTH) then
			X = -NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			Z = NumBlocks
		elseif (LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2) then
			X = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			Z = -NumBlocks
		end
	elseif (Direction == "south") then
		Z = NumBlocks
	elseif (Direction == "east") then
		X = NumBlocks
	elseif (Direction == "north") then
		Z = -NumBlocks
	elseif (Direction == "west") then
		X = -NumBlocks
	elseif ((Direction == "forward") or (Direction == "me")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			Z = NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			X = NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			Z = -NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			X = -NumBlocks
		end
	elseif ((Direction == "backwards") or (Direction == "back")) then
		if (LookDirection == E_DIRECTION_SOUTH) then
			Z = -NumBlocks
		elseif (LookDirection == E_DIRECTION_EAST) then
			X = -NumBlocks
		elseif ((LookDirection == E_DIRECTION_NORTH1) or (LookDirection == E_DIRECTION_NORTH2)) then
			Z = NumBlocks
		elseif (LookDirection == E_DIRECTION_WEST) then
			X = NumBlocks
		end
	else
		a_Player:SendMessage(cChatColor.Rose .. "Unknown direction \"" .. Direction .. "\".")
		return true
	end
	
	State.Selection:Move(X, Y, Z)
	a_Player:SendMessage(cChatColor.LightPurple .. "Region shifted.")
	return true
end





function HandleShrinkCommand(a_Split, a_Player)
	-- //shrink
	
	local State = GetPlayerState(a_Player)
	
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local BlockArea = cBlockArea()
	BlockArea:Read(a_Player:GetWorld(), SrcCuboid)
	local MinRelX, MinRelY, MinRelZ, MaxRelX, MaxRelY, MaxRelZ = BlockArea:GetNonAirCropRelCoords()
	
	-- Set the new points. This will not take the previous points in account. (For example p1 and p2 could get switched)
	State.Selection:SetFirstPoint(SrcCuboid.p1.x + MinRelX, SrcCuboid.p1.y + MinRelY, SrcCuboid.p1.z + MinRelZ)
	State.Selection:SetSecondPoint(SrcCuboid.p1.x + MaxRelX, SrcCuboid.p1.y + MaxRelY, SrcCuboid.p1.z + MaxRelZ)
	
	-- Send the change of the selection to the client
	State.Selection:NotifySelectionChanged()
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Region shrunk")
	return true
end





function HandleSizeCommand(a_Split, a_Player)
	-- //size
	
	local State = GetPlayerState(a_Player)
	if (not State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Please select a region first")
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "The selection size is " .. State.Selection:GetSizeDesc() .. ".")
	return true
end




