----------------------------------------------
----------------------UP----------------------
----------------------------------------------
function HandleUpCommand(Split, Player)
	
	local Height = tonumber(Split[2])
	
	if #Split ~= 2 or Height == nil then
		Player:SendMessageInfo("Usage: /up <number of blocks>")
		return true
	end
	
	local Y = math.floor(Player:GetPosY())
	local y = math.floor(Player:GetPosY()) + Height
	local X = math.floor(Player:GetPosX())
	local Z = math.floor(Player:GetPosZ())
	local World = Player:GetWorld()
	for Y = Y, y + 1 do
		if World:GetBlock(X, Y, Z) ~= E_BLOCK_AIR then
			Player:SendMessageFailure("You would hit something above you.")
			return true
		end
	end
	
	if not CheckIfInsideAreas(X, X, y - 1, y - 1, Z, Z, Player, World, "up") then
		World:SetBlock(X, y - 1, Z, 20, 0)
	end
	
	Player:TeleportToCoords(X + 0.5, y, Z + 0.5)
	Player:SendMessageSuccess("Whoosh!")
	return true
end


----------------------------------------------
--------------------JUMPTO--------------------
----------------------------------------------
function HandleJumpToCommand(Split, Player)
	if #Split ~= 1 then
		Player:SendMessageInfo("Usage: /jumpto")
		return true
	end
	
	LeftClickCompass(Player, Player:GetWorld())
	Player:SendMessageSuccess("Poof!")
	return true
end


----------------------------------------------
---------------------THRU---------------------
----------------------------------------------
function HandleThruCommand(Split, Player)
	if #Split ~= 1 then
		Player:SendMessageInfo("Usage: /thru")
		return true
	end
	
	RightClickCompass(Player, Player:GetWorld())
	Player:SendMessageSuccess("Whoosh!")
	return true
end


-----------------------------------------------
--------------------DESCEND--------------------
-----------------------------------------------
function HandleDescendCommand(Split, Player)
	local World = Player:GetWorld()
	if Player:GetPosY() < 1 then
		Player:SendMessageFailure("Y position too low, go higher...")
		return true
	end
	
	local FoundYCoordinate = false
	local WentThroughBlock = false
	local XPos = math.floor(Player:GetPosX())
	local YPos = Player:GetPosY()
	local ZPos = math.floor(Player:GetPosZ())

	for Y = math.floor(YPos), 1, -1 do
		if World:GetBlock(XPos, Y, ZPos) ~= E_BLOCK_AIR then
			WentThroughBlock = true
		else
			if WentThroughBlock then
				for y = Y, 1, -1 do
					if cBlockInfo:IsSolid(World:GetBlock(XPos, y, ZPos)) then
						YPos = y
						FoundYCoordinate = true
						break
					end
				end
				
				if FoundYCoordinate then
					break
				end
			end
		end
	end
	
	if FoundYCoordinate then
		Player:TeleportToCoords(Player:GetPosX(), YPos + 1, Player:GetPosZ())
	end
	
	Player:SendMessageSuccess("Descended a level.")
	return true
end


------------------------------------------------
---------------------ASCEND---------------------
------------------------------------------------
function HandleAscendCommand(Split, Player)
	local World = Player:GetWorld()
	local XPos = math.floor(Player:GetPosX())
	local YPos = Player:GetPosY()
	local ZPos = math.floor(Player:GetPosZ())
	
	local IsValid, WorldHeight = World:TryGetHeight(XPos, ZPos)
	
	if not IsValid then
		Player:SendMessageFailure("Couldn't ascend, chunk not loaded?")
		return true
	end
	
	if Player:GetPosY() == WorldHeight then
		Player:SendMessageFailure("Y coordinate too high, come lower...")
		return true
	end
	
	
	local WentThroughBlock = false

	for Y = math.floor(Player:GetPosY()), WorldHeight + 1 do
		if World:GetBlock(XPos, Y, ZPos) == E_BLOCK_AIR then
			if WentThroughBlock then
				YPos = Y
				break
			end
		else
			WentThroughBlock = true
		end
	end
	
	if WentThroughBlock then			
		Player:TeleportToCoords(Player:GetPosX(), YPos, Player:GetPosZ())
	end
	
	Player:SendMessageSuccess("Ascended a level.")
	return true
end


------------------------------------------------
----------------------CEIL----------------------
------------------------------------------------
function HandleCeilCommand(Split, Player)
	if #Split > 2 then
		Player:SendMessageInfo("Usage: /ceil [clearance as number]")
		return true
	end
	
	local BlockFromCeil
	if Split[2] == nil then
		BlockFromCeil = 0
	else
		BlockFromCeil = tonumber(Split[2])
	end
	
	if BlockFromCeil == nil then
		Player:SendMessageInfo("Usage: /ceil [clearance as number]")
		return true
	end
	local World = Player:GetWorld()
	local X = math.floor(Player:GetPosX())
	local Y = math.floor(Player:GetPosY())
	local Z = math.floor(Player:GetPosZ())
	local IsValid, WorldHeight = World:TryGetHeight(X, Z)
	
	if not IsValid then
		Player:SendMessageFailure("Couldn't query heightmap, chunk not loaded?")
		return true
	end
	
	if Y >= WorldHeight + 1 then
		Player:SendMessageFailure("Y coordinate too high, come lower...")
		return true
	end
	
	for y=Y, WorldHeight do
		if World:GetBlock(X, y, Z) ~= E_BLOCK_AIR then
			if not CheckIfInsideAreas(X, X, y - BlockFromCeil - 3, y - BlockFromCeil - 3, Z, Z, Player, PlayerWorld, "ceil") then
				World:SetBlock(X, y - BlockFromCeil - 3, Z, E_BLOCK_GLASS, 0)
			end
			local I = y - BlockFromCeil - 2
			if I == Y then
				Player:SendMessageFailure("No free spot above you was found.")
				return true
			end
			Player:TeleportToCoords(X + 0.5, I, Z + 0.5)
			break
		end
	end
	
	Player:SendMessageSuccess("Whoosh!")
	return true
end