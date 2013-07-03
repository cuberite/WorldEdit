-----------------------------------------------
--------------------DESCEND--------------------
-----------------------------------------------
function HandleDescendCommand( Split, Player )
	local World = Player:GetWorld()
	if Player:GetPosY() ~= 1 then
		local X = math.floor( Player:GetPosX() )
		local Z = math.floor( Player:GetPosZ() )
		local Air = false
		for Y=math.floor( Player:GetPosY() ), 1, -1 do
			if World:GetBlock(X, Y, Z) == E_BLOCK_AIR then
				if Air == true then -- if the player went through blocks other then air then go further until you can teleport
					while World:GetBlock(X, Y, Z) == E_BLOCK_AIR do
						Y = Y - 1
					end
					y = Y
					break
				end
			else
				Air = true
			end
		end
		if y ~= nil then
			if Air == true then
				if Y ~= 1 then
					Player:TeleportToCoords( Player:GetPosX(), y + 1, Player:GetPosZ() )
				end
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
		local Air = false
		for Y = math.floor(Player:GetPosY()), World:GetHeight( X, Z ) + 1 do
			if World:GetBlock( X, Y, Z ) == E_BLOCK_AIR then
				if Air == true then
					y = Y
					break
				end
			else
				Air = true
			end
		end
		if y ~= nil then
			if Air == true then			
				Player:TeleportToCoords( Player:GetPosX(), y, Player:GetPosZ() )
			end
		end		
	end	
	Player:SendMessage( cChatColor.LightPurple .. "Ascended a level." )
	return true
end