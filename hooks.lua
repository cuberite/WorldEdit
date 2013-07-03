----------------------------------------------------
---------------ONPLAYERBREAKINGBLOCK----------------
----------------------------------------------------
function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	if WandActivated[Player:GetName()] == true then
		if Player:GetEquippedItem().m_ItemType == Wand then
			OnePlayer[Player:GetName()] = Vector3i(BlockX, BlockY, BlockZ)
			if OnePlayer[Player:GetName()] ~= nil and TwoPlayer[Player:GetName()] ~= nil then
				Player:SendMessage( cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. GetSize( Player ) .. ")." )
			else
				Player:SendMessage( cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0)." )
			end
			return true
		end
	end
end


----------------------------------------------------
-----------------ONPLAYERLEFTCLICK------------------
----------------------------------------------------
function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if SP[Player:GetName()] == true then
		local World = Player:GetWorld()
		Item = cItem( World:GetBlock( BlockX, BlockY, BlockZ ), 10, World:GetBlockMeta( BlockX, BlockY, BlockZ ) )
		cPickup( BlockX, BlockY, BlockZ, Item, 0.0, 0.0, 0.0 )
		World:DigBlock( BlockX, BlockY, BlockZ ) 		
	end
end


-----------------------------------------------------
-----------------ONPLAYERRIGHTCLICK------------------
-----------------------------------------------------
function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if BlockY == 255 and BlockZ == -1 and BlockX == -1 then
		return true
	end
	if WandActivated[Player:GetName()] == true then
		if Player:GetEquippedItem().m_ItemType == Wand then
			if BlockX == -1 and BlockZ == -1 and BlockY == 255 then
				return false
			end
			TwoPlayer[Player:GetName()] = Vector3i(BlockX, BlockY, BlockZ)
			if OnePlayer[Player:GetName()] ~= nil and TwoPlayer[Player:GetName()] ~= nil then
				Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. GetSize( Player ) .. ")." )
			else
				Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0)." )
			end
			return true
		end
	end
	local World = Player:GetWorld()
	if Player:GetEquippedItem().m_ItemType == ReplItem[Player:GetName()] then
		Block = StringSplit( Repl[Player:GetName()], ":" )
		if Block[2] == nil then
			Block[2] = 0
		end
		World:SetBlock( BlockX, BlockY, BlockZ, Block[1], Block[2] )
	elseif Player:GetEquippedItem().m_ItemType == GrowTreeItem[Player:GetName()] then
		if World:GetBlock(BlockX, BlockY, BlockZ) == 2 or World:GetBlock(BlockX, BlockY, BlockZ) == 3 then
			World:GrowTree( BlockX, BlockY + 1, BlockZ )
		else
			Player:SendMessage( cChatColor.Rose .. "A tree can't go there." )
		end
	end
end


-----------------------------------------------------
-------------------ONPLAYERJOINED--------------------
-----------------------------------------------------
function OnPlayerJoined(Player)
	if PersonalBlockArea[Player:GetName()] == nil then
		PersonalBlockArea[Player:GetName()] = cBlockArea()
	end
	if PersonalUndo[Player:GetName()] == nil then
		PersonalUndo[Player:GetName()] = cBlockArea()
	end
	if PersonalRedo[Player:GetName()] == nil then
		PersonalRedo[Player:GetName()] = cBlockArea()
	end
	if PersonalClipboard[Player:GetName()] == nil then
		PersonalClipboard[Player:GetName()] = cBlockArea()
	end
	if WandActivated[Player:GetName()] == nil then
		WandActivated[Player:GetName()] = true
	end
end