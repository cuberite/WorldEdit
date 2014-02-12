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
	
	if Player:IsCrouched() then
		BlockX, BlockY, BlockZ = AddFaceDirection(BlockX, BlockY, BlockZ, BlockFace)
	end
	
	SetPlayerSelectionPoint(Player, BlockX, BlockY, BlockZ, E_SELECTIONPOINT_LEFT)
	return true
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
	
	if Player:IsCrouched() then
		BlockX, BlockY, BlockZ = AddFaceDirection(BlockX, BlockY, BlockZ, BlockFace)
	end
	
	SetPlayerSelectionPoint(Player, BlockX, BlockY, BlockZ, E_SELECTIONPOINT_RIGHT)
	return true
end


---------------------------------------------------
-------------------SUPERPICKAXE--------------------
---------------------------------------------------
function SuperPickaxeHook(Player, BlockX, BlockY, BlockZ, BlockFace, Status)
	if (SP[Player:GetName()]) then
		if CheckIfInsideAreas(BlockX, BlockX, BlockY, BlockY, BlockZ, BlockZ, Player, Player:GetWorld(), "superpickaxe") then
			return true
		end
		local World = Player:GetWorld()
		World:DigBlock(BlockX, BlockY, BlockZ) 		
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
		if CheckIfInsideAreas(BlockX, BlockX, BlockY, BlockY, BlockZ, BlockZ, Player, Player:GetWorld(), "replacetool") then
			return true
		end
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
-----------------RIGHTCLICKCOMPASS------------------
----------------------------------------------------
function RightClickCompassHook(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if BlockFace ~= BLOCK_FACE_NONE then
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


---------------------------------------------------
-----------------LeftClickCompass------------------
---------------------------------------------------
function LeftClickCompassHook(Player, BlockX, BlockY, BlockZ, BlockFace, Status)
	if Status ~= 0 then
		return false
	end
	
	if not PlayerHasWEPermission(Player, "worldedit.navigation.jumpto.tool") then
		return false
	end
	
	if Player:GetEquippedItem().m_ItemType ~= E_ITEM_COMPASS then
		return false
	end
	
	if LeftClickCompassUsed[Player:GetName()] then
		return false
	end
	return true
end


----------------------------------------------------
-----------------ONPLAYERANIMATION------------------
----------------------------------------------------
function OnPlayerAnimation(Player, Animation)
	if Animation ~= 1 then
		return false
	end
	
	local PlayerName = Player:GetName()
	
	if (not LeftClickCompassUsed[PlayerName]) and (LeftClickCompassUsed[PlayerName] ~= nil) then
		LeftClickCompassUsed[PlayerName] = true
		return false
	end
	
	if Player:GetEquippedItem().m_ItemType ~= E_ITEM_COMPASS then
		return false
	end
	
	if not PlayerHasWEPermission(Player, "worldedit.navigation.jumpto.tool") then
		return false
	end
	
	local World = Player:GetWorld()
	local PlayerID = Player:GetUniqueID()
	LeftClickCompassUsed[PlayerName] = false
	World:ScheduleTask(1, function(World)
		World:DoWithEntityByID(PlayerID, function(Player)
			if not LeftClickCompass(Player, Player:GetWorld()) then
				Player:SendMessage(cChatColor.Rose .. "No blocks in sight (or too far)!")
			end
			LeftClickCompassUsed[PlayerName] = true
		end)
	end)
				
	return true
end



----------------------------------------------------
------------------ONPLUGINMESSAGE-------------------
----------------------------------------------------
function OnPluginMessage(a_Client, a_Channel, a_Message)
	if (a_Channel == "REGISTER") and (a_Message:find("WECUI") ~= nil) then
		PlayerWECUIActivated[a_Client:GetPlayer():GetName()] = true
	end
end