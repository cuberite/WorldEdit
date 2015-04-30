
-- hooks.lua

-- Implements the handlers for the hooks used by the plugin
-- This file is temporary, the hook handlers will be moved to the tools they implement!





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
function RightClickToolsHook(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
	local State = GetPlayerState(a_Player)
	
	return State.ToolRegistrator:UseRightClickTool(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Player:GetEquippedItem().m_ItemType)
end





function LeftClickToolsHook(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
	local State = GetPlayerState(a_Player)
	
	return State.ToolRegistrator:UseLeftClickTool(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Player:GetEquippedItem().m_ItemType)
end




----------------------------------------------------
-----------------RIGHTCLICKCOMPASS------------------
----------------------------------------------------
function RightClickCompassHook(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if BlockFace ~= BLOCK_FACE_NONE then
		return false
	end

	-- Check if the equipped item is a compass.
	if (Player:GetEquippedItem().m_ItemType == E_ITEM_COMPASS) and Player:HasPermission("worldedit.navigation.thru.tool") then
		RightClickCompass(Player, Player:GetWorld())
	end
end




---------------------------------------------------
-----------------LeftClickCompass------------------
---------------------------------------------------
function LeftClickCompassHook(Player, BlockX, BlockY, BlockZ, BlockFace, Status)
	if Status ~= 0 then
		return false
	end
	
	if (not Player:HasPermission("worldedit.navigation.jumpto.tool")) then
		return false
	end
	
	if (Player:GetEquippedItem().m_ItemType ~= E_ITEM_COMPASS) then
		return false
	end
	
	if (LeftClickCompassUsed[Player:GetName()]) then
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
	
	if (not Player:HasPermission("worldedit.navigation.jumpto.tool")) then
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



