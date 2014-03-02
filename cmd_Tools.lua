------------------------------------------------
----------------------REPL----------------------
------------------------------------------------
function HandleReplCommand(Split, Player)
	if Split[2] == nil then -- check if the player gave a block id
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		Player:SendMessage(cChatColor.Rose .. "/repl <block ID>")
		return true
	end
	
	local BlockType, BlockMeta = GetBlockTypeMeta(Split[2])
	
	if (not BlockType) then
		Player:SendMessage(cChatColor.Rose .. "Unknown character \"" .. Split[2] .. "\"")
		return true
	end
	
	local PlayerName = Player:GetName()
	
	if not IsValidBlock(BlockType) then -- check if the player gave a valid block id
		Player:SendMessage(cChatColor.Rose .. Split[2] .. " isn't a valid block")
		return true
	end
	
	local EquippedItem = Player:GetEquippedItem()
	if not ItemCategory.IsTool(EquippedItem.m_ItemType) then -- Check if the player has a tool in equipped
		Player:SendMessage(cChatColor.Rose .. "Can't bind tool to \"" .. ItemToString(EquippedItem) .. "\": Blocks can't be used")
		return true
	end

	-- ToDo: Check if another tool is using the equipped item.
	local State = GetPlayerState(Player)
	
	State.Tools:SetReplaceTool(EquippedItem.m_ItemType, BlockType, BlockMeta)
	Player:SendMessage(cChatColor.LightPurple .. "Block replacer tool bound to " .. ItemToString(Player:GetEquippedItem()))
	return true
end


------------------------------------------------
----------------------NONE----------------------
------------------------------------------------
function HandleNoneCommand(Split, Player)
	if Player:GetEquippedItem().m_ItemType == ReplItem[Player:GetName()] then -- check if the item is bound to //repl
		Repl[Player:GetName()] = nil -- unbind the item
		ReplItem[Player:GetName()] = nil -- unbind the item
	elseif Player:GetEquippedItem().m_ItemType == GrowTreeItem[Player:GetName()] then -- check if the item is bound to /tree
		GrowTreeItem[Player:GetName()] = nil -- unbind the item
	end
	Player:SendMessage(cChatColor.LightPurple .. "Tool unbound from your current item.")
	return true
end
		
	
------------------------------------------------
----------------------TREE----------------------
------------------------------------------------
function HandleTreeCommand(Split, Player)
	local EquippedItem = Player:GetEquippedItem()
	if (not ItemCategory.IsTool(EquippedItem.m_ItemType)) then -- check if the player has a tool in his hand
		Player:SendMessage(cChatColor.Rose .. "Can't bind tool to " .. ItemToString(Player:GetEquippedItem()) .. ": Blocks can't be used")
		return true		
	end
	
	local State = GetPlayerState(Player)
	State.Tools:EnableGrowTreeTool(EquippedItem.m_ItemType)
	
	Player:SendMessage(cChatColor.LightPurple .. "Tree tool bound to " .. ItemToString(Player:GetEquippedItem()))
	return true
end


-----------------------------------------------
-------------------SUPERPICK-------------------
-----------------------------------------------
function HandleSuperPickCommand(Split, Player)
	local State = GetPlayerState(Player)
	
	if (State.Tools:SwichSuperPickaxeActivated()) then -- check if super pickaxe is activated
		Player:SendMessage(cChatColor.LightPurple .. "Super pick activated")
	else -- else deactivate the superpickaxe
		Player:SendMessage(cChatColor.LightPurple .. "Super pick deactivated")
	end
	return true
end




