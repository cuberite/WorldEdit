-----------------------------------------------
--------------------DESCEND--------------------
-----------------------------------------------
function HandleDescendCommand( Split, Player )
	local World = Player:GetWorld()
	if Player:GetPosY() ~= 1 then
		PosX[Player:GetName()] = math.floor( Player:GetPosX() )
		PosZ[Player:GetName()] = math.floor( Player:GetPosZ() )
		PosY[Player:GetName()] = math.floor( Player:GetPosY() )
		while PosY[Player:GetName()] ~= 1 do 
			if World:GetBlock( PosX[Player:GetName()], PosY[Player:GetName()], PosZ[Player:GetName()]) == 0 then
				if Air[Player:GetName()] == true then -- if the player went through blocks other then air then go further until you can teleport
					while World:GetBlock( PosX[Player:GetName()], PosY[Player:GetName()], PosZ[Player:GetName()]) == 0 do
						PosY[Player:GetName()] = PosY[Player:GetName()] - 1
					end
					break
				end
			else
				Air[Player:GetName()] = true
			end
			PosY[Player:GetName()] = PosY[Player:GetName()] - 1
		end
		if PosY[Player:GetName()] ~= nil then
			if Air[Player:GetName()] == true then
				if PosY[Player:GetName()] ~= 1 then
					Player:TeleportToCoords( Player:GetPosX(), PosY[Player:GetName()] + 1, Player:GetPosZ() )
				end
				Air[Player:GetName()] = false
				PosY[Player:GetName()] = nil
			end
		end		
	end
	Player:SendMessage( cChatColor.LightPurple .. "Descended a level." )
	return true
end


------------------------------------------------
---------------------ASCEND---------------------
------------------------------------------------
function HandleAscendCommand( Split, Player )
	local World = Player:GetWorld()
	if Player:GetPosY() == World:GetHeight( math.floor(Player:GetPosX()), math.floor((Player:GetPosZ()) ) ) then
		Player:SendMessage( cChatColor.LightPurple .. "Ascended a level." )
	else
		local X = math.floor(Player:GetPosX())
		local Z = math.floor(Player:GetPosZ())
		for Y = math.floor(Player:GetPosY()), World:GetHeight( X, Z ) + 1 do
			if World:GetBlock( X, Y, Z ) == E_BLOCK_AIR then
				if Air[Player:GetName()] == true then
					PosY[Player:GetName()] = Y
					break
				end
			else
				Air[Player:GetName()] = true
			end
		end
		if PosY[Player:GetName()] ~= nil then
			if Air[Player:GetName()] == true then			
				Player:TeleportToCoords( Player:GetPosX(), PosY[Player:GetName()], Player:GetPosZ() )
				Air[Player:GetName()] = false
				PosY[Player:GetName()] = nil
			end
		end		
	end	
	Player:SendMessage( cChatColor.LightPurple .. "Ascended a level." )
	return true
end