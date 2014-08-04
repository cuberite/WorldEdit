
-- cmd_Brush.lua

-- Implements command handlers for the brush commands





function HandleSphereBrush(a_Split, a_Player)
	-- //brush sphere [-h] <Block> <Radius>
	if (#a_Split < 4) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /brush sphere [-h] <Block> <Radius>")
		return true
	end

	-- TODO: Implement -h

	-- Convert the block param:
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[3])
	if not(BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown block type: \"" .. a_Split[3] .. "\"")
		return true
	end

	-- Convert the Radius param:
	local Radius = tonumber(a_Split[4])
	if not(Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Cannot convert radius \"" .. a_Split[4] .. "\" to a number.")
		return true
	end

	-- Initialize the handler.
	local function BrushHandler(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		local Position = Vector3i(a_BlockX, a_BlockY, a_BlockZ)

		if (a_BlockFace == BLOCK_FACE_NONE) then
			Position = GetTargetBlock(a_Player)

			if (Position == nil) then
				return true
			end
		end

		CreateSphereAt(BlockType, BlockMeta, Position, a_Player, Radius)
		return true
	end

	local State = GetPlayerState(a_Player)
	local Succes, error = State.ToolRegistrator:BindTool(a_Player:GetEquippedItem().m_ItemType, BrushHandler)
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Sphere brush shape equipped (" .. Radius .. ")")
	return true
end
