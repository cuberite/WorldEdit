---------------------------------------------------
-----------------SELECTFIRSTPOINT------------------
---------------------------------------------------
function SelectFirstPointHook(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	if not PlayerHasWEPermission(Player, "worldedit.selection.pos") then
		return false
	end
	
	local PlayerName = Player:GetName()
	if not WandActivated[PlayerName] then
		return false
	end
	
	if Player:GetEquippedItem().m_ItemType ~= Wand then
		return false
	end
	
	OnePlayer[PlayerName] = Vector3i(BlockX, BlockY, BlockZ)
	if OnePlayer[PlayerName] ~= nil and TwoPlayer[PlayerName] ~= nil then
		Player:SendMessage(cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. GetSize(Player) .. ").")
	else
		Player:SendMessage(cChatColor.LightPurple .. 'First position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0).")
	end
	return true
end


---------------------------------------------------
-------------------SUPERPICKAXE--------------------
---------------------------------------------------
function SuperPickaxeHook(Player, BlockX, BlockY, BlockZ, BlockFace, Status)
	if (SP[Player:GetName()]) then
		local World = Player:GetWorld()
		World:DigBlock(BlockX, BlockY, BlockZ) 		
	end
end


---------------------------------------------------
-----------------LeftClickCompass------------------
---------------------------------------------------
function LeftClickCompassHook(Player, BlockX, BlockY, BlockZ, BlockFace, Status)
	if Status == 0 then
		if PlayerHasWEPermission(Player, "worldedit.navigation.jumpto.tool") and Player:GetEquippedItem().m_ItemType == E_ITEM_COMPASS then
			LeftClickCompassUsed[Player:GetName()] = false
			return false
		end
	end
end


----------------------------------------------------
---------------------TOOLSHOOK----------------------
----------------------------------------------------
function ToolsHook(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if BlockFace == BLOCK_FACE_NONE then
		return false
	end
	
	local PlayerName = Player:GetName()
	local World = Player:GetWorld()
	if Player:GetEquippedItem().m_ItemType == ReplItem[PlayerName] then
		local Block = StringSplit(Repl[PlayerName], ":")
		if Block[2] == nil then
			Block[2] = 0
		end
		World:SetBlock(BlockX, BlockY, BlockZ, Block[1], Block[2])
		return false
	end
	if Player:GetEquippedItem().m_ItemType == GrowTreeItem[PlayerName] then
		if World:GetBlock(BlockX, BlockY, BlockZ) == 2 or World:GetBlock(BlockX, BlockY, BlockZ) == 3 then
			World:GrowTree(BlockX, BlockY + 1, BlockZ)
		else
			Player:SendMessage(cChatColor.Rose .. "A tree can't go there.")
		end
	end
end


----------------------------------------------------
-----------------SELECTSECONDPOINT------------------
----------------------------------------------------
function SelectSecondPointHook(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if BlockFace == BLOCK_FACE_NONE then
		return false
	end
	
	local PlayerName = Player:GetName()
	if not PlayerHasWEPermission(Player, "worldedit.selection.pos") then
		return false
	end
	
	if not WandActivated[PlayerName] then
		return false
	end
	
	-- Check if the wand is equipped
	if Player:GetEquippedItem().m_ItemType ~= Wand then
		return false
	end
	
	TwoPlayer[PlayerName] = Vector3i(BlockX, BlockY, BlockZ)
	if OnePlayer[Player:GetName()] ~= nil and TwoPlayer[Player:GetName()] ~= nil then
		Player:SendMessage(cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. GetSize(Player) .. ").")
	else
		Player:SendMessage(cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0).")
	end
	return true
end


----------------------------------------------------
-----------------RIGHTCLICKCOMPASS------------------
----------------------------------------------------
function RightClickCompassHook(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if BlockFace == BLOCK_FACE_NONE then
		return false
	end

	-- Check if the equipped item is a compass.
	if (Player:GetEquippedItem().m_ItemType == E_ITEM_COMPASS) and PlayerHasWEPermission(Player, "worldedit.navigation.thru.tool") then
		RightClickCompass(Player, Player:GetWorld())
	end
end


-----------------------------------------------------
-------------------ONPLAYERJOINED--------------------
-----------------------------------------------------
function OnPlayerJoined(Player)
	LoadPlayer(Player)
end



----------------------------------------------------
-----------------ONPLAYERANIMATION------------------
----------------------------------------------------
function OnPlayerAnimation(Player, Animation)
	if Animation ~= 1 then
		return false
	end
	
	local PlayerName = Player:GetName()
	if LeftClickCompassUsed[PlayerName] or LeftClickCompassUsed[PlayerName] == nil then
		if Player:GetEquippedItem().m_ItemType == E_ITEM_COMPASS and PlayerHasWEPermission(Player, "worldedit.navigation.jumpto.tool") then
			if not LeftClickCompass(Player, Player:GetWorld()) then
				Player:SendMessage(cChatColor.Rose .. "No blocks in sight (or too far)!")
			end
		end
	end
	LeftClickCompassUsed[PlayerName] = true
end