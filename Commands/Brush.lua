
-- cmd_Brush.lua

-- Implements command handlers for the brush commands





function HandleMaskCommand(a_Split, a_Player)
	-- /mask <Blocks>
	
	if (#a_Split == 1) then
		-- Remove mask
		local State = GetPlayerState(a_Player)
		local Succes, error = State.ToolRegistrator:UnbindMask(a_Player:GetEquippedItem().m_ItemType)

		if (not Succes) then
			a_Player:SendMessage(cChatColor.Rose .. error)
			return true
		end
		a_Player:SendMessage(cChatColor.LightPurple .. "Brush mask disabled.")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable = RetrieveBlockTypes(a_Split[2])
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown block type: '" .. a_Split[2] .. "'.")
		return true
	end

	-- Convert the BlockTable to a mask table (It's better for the performance)
	local MaskTable = {}
	for Idx, Block in ipairs(BlockTable) do
		MaskTable[Block.BlockType] = { BlockMeta = Block.BlockMeta, TypeOnly = Block.TypeOnly, Chance = Block.Chance }
	end

	local State = GetPlayerState(a_Player)
	local Succes, error = State.ToolRegistrator:BindMask(a_Player:GetEquippedItem().m_ItemType, MaskTable)
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	a_Player:SendMessage(cChatColor.LightPurple .. "Brush mask set.")
	return true
end





function HandleSphereBrush(a_Split, a_Player)
	-- //brush sphere [-h] <Block> <Radius>
	
	if (#a_Split < 4) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /brush sphere [-h] <Block> <Radius>")
		return true
	end

	local Hollow = false
	if (a_Split[3] == "-h") then
		Hollow = true
		table.remove(a_Split, 3)
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable = RetrieveBlockTypes(a_Split[3])
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[3] .. "'.")
		return true
	end

	-- Convert the Radius param:
	local Radius = tonumber(a_Split[4])
	if not(Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Cannot convert radius \"" .. a_Split[4] .. "\" to a number.")
		return true
	end
	
	-- The player state is used to get the player's mask, and to bind the tool
	local State = GetPlayerState(a_Player)
	
	-- Initialize the handler.
	local function BrushHandler(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		local Position = (a_BlockFace == BLOCK_FACE_NONE and GetTargetBlock(a_Player)) or Vector3i(a_BlockX, a_BlockY, a_BlockZ)
		
		if (not Position) then
			return true
		end
		
		local AffectedArea = cCuboid(Position, Position)
		AffectedArea:Expand(Radius, Radius, Radius, Radius, Radius, Radius)
		AffectedArea:Sort()
		
		-- Get the mask. We can't put this outside the brush handler, because the player might have changed it already.
		local Mask = State.ToolRegistrator:GetMask(a_Player:GetEquippedItem().m_ItemType)
		
		CreateSphereInCuboid(a_Player, AffectedArea, BlockTable, Hollow, Mask)
		return true
	end

	local Succes, error = State.ToolRegistrator:BindTool(a_Player:GetEquippedItem().m_ItemType, BrushHandler)
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Sphere brush shape equipped (" .. Radius .. ")")
	return true
end





function HandleCylinderBrush(a_Split, a_Player)
	-- //brush cyl [-h] <Block> <Radius> <Height>
	
	if (#a_Split < 5) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /brush cylinder [-h] <Block> <Radius> <Height>")
		return true
	end

	local Hollow = false
	if (a_Split[3] == "-h") then
		Hollow = true
		table.remove(a_Split, 3)
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable = RetrieveBlockTypes(a_Split[3])
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[3] .. "'.")
		return true
	end

	-- Convert the Radius param:
	local Radius = tonumber(a_Split[4])
	if not(Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Cannot convert radius \"" .. a_Split[4] .. "\" to a number.")
		return true
	end

	-- Convert the height param.
	local Height = tonumber(a_Split[5])
	if not(Height) then
		a_Player:SendMessage(cChatColor.Rose .. "Cannot convert height \"" .. a_Split[5] .. "\" to a number.")
		return true
	end
	
	-- The height used in the brush handler. If Height is negative we add one, if positive we lower by one
	local UsedHeight = (Height > 0 and (Height - 1)) or (Height + 1)
	
	-- The player state is used to get the player's mask, and to bind the tool
	local State = GetPlayerState(a_Player)
	
	-- Initialize the handler.
	local function BrushHandler(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		local Position = (a_BlockFace == BLOCK_FACE_NONE and GetTargetBlock(a_Player)) or Vector3i(a_BlockX, a_BlockY, a_BlockZ)
		
		if (not Position) then
			return true
		end
		
		local AffectedArea = cCuboid(Position, Position)
		AffectedArea:Expand(Radius, Radius, 0, UsedHeight, Radius, Radius)
		AffectedArea:Sort()
		
		-- Get the mask. We can't put this outside the brush handler, because the player might have changed it already.
		local Mask = State.ToolRegistrator:GetMask(a_Player:GetEquippedItem().m_ItemType)
		
		CreateCylinderInCuboid(a_Player, AffectedArea, BlockTable, Hollow, Mask)
		return true
	end

	local Succes, error = State.ToolRegistrator:BindTool(a_Player:GetEquippedItem().m_ItemType, BrushHandler)
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Cylinder brush shape equipped (" .. Radius .. " by " .. Height .. ")")
	return true
end





