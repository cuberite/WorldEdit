------------------------------------------------
----------------------REPL----------------------
------------------------------------------------
function HandleReplCommand( Split, Player )
	if Split[2] == nil or tonumber( Split[2] ) == nil then -- check if the player gave a block id
		Player:SendMessage( cChatColor.Rose .. "Too few arguments." )
		Player:SendMessage( cChatColor.Rose .. "/repl <block ID>" )
	elseif IsValidBlock( tonumber(Split[2]) ) == true and ItemCategory.IsTool( Player:GetEquippedItem().m_ItemType ) == true then -- check if the player gave a valid block id and has a tool in his hand
		Repl[Player:GetName()] = tonumber(Split[2]) 
		ReplItem[Player:GetName()] = Player:GetEquippedItem().m_ItemType -- bind tool to //repl
		Player:SendMessage( cChatColor.LightPurple .. "Block replacer tool bound to " .. ItemToString(Player:GetEquippedItem()) )
	else
		if IsValidBlock( tonumber(Split[2]) ) == false then
			Player:SendMessage( cChatColor.Rose .. Split[2] .. " isn't a valid block" )
			return true
		end
		Player:SendMessage( cChatColor.Rose .. "Can't bind tool to " .. ItemToString(Player:GetEquippedItem()) .. ": Blocks can't be used" )
	end
	return true
end


------------------------------------------------
----------------------NONE----------------------
------------------------------------------------
function HandleNoneCommand( Split, Player )
	if Player:GetEquippedItem().m_ItemType == ReplItem[Player:GetName()] then -- check if the item is bound to //repl
		Repl[Player:GetName()] = nil -- unbind the item
		ReplItem[Player:GetName()] = nil -- unbind the item
	elseif Player:GetEquippedItem().m_ItemType == GrowTreeItem[Player:GetName()] then -- check if the item is bound to /tree
		GrowTreeItem[Player:GetName()] = nil -- unbind the item
	end
	Player:SendMessage( cChatColor.LightPurple .. "Tool unbound from your current item." )
	return true
end
		
	
------------------------------------------------
----------------------TREE----------------------
------------------------------------------------
function HandleTreeCommand( Split, Player )
	if ItemCategory.IsTool( Player:GetEquippedItem().m_ItemType ) then -- check if the player has a tool in his hand
		GrowTreeItem[Player:GetName()] = Player:GetEquippedItem().m_ItemType -- bind tool to /tree
		Player:SendMessage( cChatColor.LightPurple .. "Tree tool bound to " .. ItemToString(Player:GetEquippedItem()) )
	else
		Player:SendMessage( cChatColor.Rose .. "Can't bind tool to " .. ItemToString(Player:GetEquippedItem()) .. ": Blocks can't be used" )
	end
	return true
end


-----------------------------------------------
-------------------SUPERPICK-------------------
-----------------------------------------------
function HandleSuperPickCommand( Split, Player )
	if SP[Player:GetName()] == nil or SP[Player:GetName()] == false then -- check if super pickaxe is activated
		SP[Player:GetName()] = true
		Player:SendMessage( cChatColor.LightPurple .. "Super pick activated" )
	else -- else deactivate the superpickaxe
		SP[Player:GetName()] = false
		Player:SendMessage( cChatColor.LightPurple .. "Super pick deactivated" )
	end
	return true
end