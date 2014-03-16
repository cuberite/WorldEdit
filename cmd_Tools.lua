------------------------------------------------
----------------------REPL----------------------
------------------------------------------------
function HandleReplCommand(a_Split, a_Player)
	if a_Split[2] == nil then -- check if the player gave a block id
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "/repl <block ID>")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(a_Split[2])
	
	if (not BlockType) then
		a_Player:SendMessage(cChatColor.Rose .. "Unknown character \"" .. a_Split[2] .. "\"")
		return true
	end
	
	if not IsValidBlock(BlockType) then -- check if the player gave a valid block id
		a_Player:SendMessage(cChatColor.Rose .. a_Split[2] .. " isn't a valid block")
		return true
	end
	
	-- Initialize the handler.
	local function ReplaceHandler(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		if (a_BlockFace == BLOCK_FACE_NONE) then
			return true
		end
		
		if CheckIfInsideAreas(a_BlockX, a_BlockX, a_BlockY, a_BlockY, a_BlockZ, a_BlockZ, a_Player, a_Player:GetWorld(), "replacetool") then
			return true
		end
		
		a_Player:GetWorld():SetBlock(a_BlockX, a_BlockY, a_BlockZ, BlockType, BlockMeta)
		return false
	end
	
	local State = GetPlayerState(a_Player)
	local Succes, error = State.ToolRegistrator:BindTool(a_Player:GetEquippedItem().m_ItemType, ReplaceHandler)
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Block replacer tool bound to " .. ItemToString(a_Player:GetEquippedItem()))
	return true
end


------------------------------------------------
----------------------NONE----------------------
------------------------------------------------
function HandleNoneCommand(a_Split, a_Player)
	local State = GetPlayerState(a_Player)
	local Succes, error = State.ToolRegistrator:UnbindTool(a_Player:GetEquippedItem().m_ItemType)
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Tool unbound from your current item.")
	return true
end
		
	
------------------------------------------------
----------------------TREE----------------------
------------------------------------------------
function HandleTreeCommand(a_Split, a_Player)

	local function HandleTree(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		if (a_BlockFace == BLOCK_FACE_NONE) then
			return false
		end
		
		local World = a_Player:GetWorld()
		if World:GetBlock(a_BlockX, a_BlockY, a_BlockZ) == 2 or World:GetBlock(a_BlockX, a_BlockY, a_BlockZ) == 3 then
			World:GrowTree(a_BlockX, a_BlockY + 1, a_BlockZ)
		else
			a_Player:SendMessage(cChatColor.Rose .. "A tree can't go there.")
		end
	end
	
	local State = GetPlayerState(a_Player)
	local Succes, error = State.ToolRegistrator:BindTool(a_Player:GetEquippedItem().m_ItemType, HandleTree)
	
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. error)
		return true
	end
	
	a_Player:SendMessage(cChatColor.LightPurple .. "Tree tool bound to " .. ItemToString(a_Player:GetEquippedItem()))
	return true
end


-----------------------------------------------
-------------------SUPERPICK-------------------
-----------------------------------------------
function HandleSuperPickCommand(Split, Player)
	if SP[Player:GetName()] == nil or not SP[Player:GetName()] then -- check if super pickaxe is activated
		SP[Player:GetName()] = true
		Player:SendMessage(cChatColor.LightPurple .. "Super pick activated")
	else -- else deactivate the superpickaxe
		SP[Player:GetName()] = false
		Player:SendMessage(cChatColor.LightPurple .. "Super pick deactivated")
	end
	return true
end




