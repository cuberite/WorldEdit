----------------------------------------------------
---------------ONPLAYERBREAKINGBLOCK----------------
----------------------------------------------------
function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	if (WandActivated[Player:GetName()]) then
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
function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, Status)
	if (SP[Player:GetName()]) then
		local World = Player:GetWorld()
		Item = cItem( World:GetBlock( BlockX, BlockY, BlockZ ), 10, World:GetBlockMeta( BlockX, BlockY, BlockZ ) )
		cPickup( BlockX, BlockY, BlockZ, Item, 0.0, 0.0, 0.0 )
		World:DigBlock( BlockX, BlockY, BlockZ ) 		
	end
	if (Player:GetEquippedItem().m_ItemType == E_ITEM_COMPASS) then
		if Player:HasPermission("worldedit.navigation.jumpto.tool") then
			World = Player:GetWorld()
			local Tracer = cTracer( World )
			local EyePos = Vector3f(Player:GetEyePosition().x, Player:GetEyePosition().y, Player:GetEyePosition().z)
			local EyeVector = Vector3f(Player:GetLookVector().x, Player:GetLookVector().y, Player:GetLookVector().z)
			Tracer:Trace( EyePos , EyeVector, 200 )
			X = Tracer.BlockHitPosition.x
			Z = Tracer.BlockHitPosition.z
			
			if Z == nil or X == nil then
				Player:SendMessage( cChatColor.Green .. "No blocks in sight(or too far)")
				return false
			end
			for y = Tracer.BlockHitPosition.y, World:GetHeight(X, Z) + 1 do
				if World:GetBlock(X, y, Z) == E_BLOCK_AIR then
					Y = y
					break
				end
			end
			Player:TeleportToCoords( X + 0.5, Y, Z + 0.5 )
			return false
		end
	end
end


-----------------------------------------------------
-----------------ONPLAYERRIGHTCLICK------------------
-----------------------------------------------------
function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if (BlockX ~= -1) or (BlockY ~= 255) or (BlockZ ~= -1) then
		if (WandActivated[Player:GetName()]) then
			if Player:GetEquippedItem().m_ItemType == Wand then
				TwoPlayer[Player:GetName()] = Vector3i(BlockX, BlockY, BlockZ)
				if OnePlayer[Player:GetName()] ~= nil and TwoPlayer[Player:GetName()] ~= nil then
					Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0) (" .. GetSize( Player ) .. ")." )
				else
					Player:SendMessage( cChatColor.LightPurple .. 'Second position set to (' .. BlockX .. ".0, " .. BlockY .. ".0, " .. BlockZ .. ".0)." )
				end
				return false
			end
		end
		
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
		return false
	end
	if (Player:GetEquippedItem().m_ItemType == E_ITEM_COMPASS) then
		Compass(Player, Player:GetWorld())
	end
end


-----------------------------------------------------
-------------------ONPLAYERJOINED--------------------
-----------------------------------------------------
function OnPlayerJoined(Player)
	LoadPlayer(Player)
end