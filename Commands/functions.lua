-------------------------------------------------
---------------CREATEWALLSFUNCTION---------------
-------------------------------------------------
function HandleCreateWalls(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- Get the right X, Y and Z coordinates
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. World:GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	local Blocks = (2 * (PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 + PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1) * PersonalBlockArea[Player:GetName()]:GetSizeY()) -- Calculate the amount if blocks that are going to change
	if Blocks == 0 then -- if the wall is 1x1x1 then the amout of blocks changed are 1
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[Player:GetName()]:GetSizeX() - 1
	local YY = PersonalBlockArea[Player:GetName()]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta)
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[Player:GetName()]:Write(World, OneX, OneY, OneZ) -- Write the region into the world
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return Blocks
end


-------------------------------------------------
---------------CREATEFACESFUNCTION---------------
-------------------------------------------------
function HandleCreateFaces(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player) -- get the coordinates
	local World = Player:GetWorld()	
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	local Blocks = (2 * (PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 + PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1) * PersonalBlockArea[Player:GetName()]:GetSizeY()) -- calculate the amount of changed blocks.
	if Blocks == 0 then
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[Player:GetName()]:GetSizeX() - 1
	local YY = PersonalBlockArea[Player:GetName()]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta) -- Walls
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta)
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, XX, Y, Y, Z, ZZ, 3, BlockType, BlockMeta) -- Floor
	PersonalBlockArea[Player:GetName()]:FillRelCuboid(X, XX, YY, YY, Z, ZZ, 3, BlockType, BlockMeta) -- Ceiling

	PersonalBlockArea[Player:GetName()]:Write(World, OneX, OneY, OneZ) -- write the area in the world.
	World:WakeUpSimulatorsInArea(OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1)
	return Blocks
end


------------------------------------------------
------------------FILLFUNCTION------------------
------------------------------------------------
function HandleFillSelection(Player, World, BlockType, BlockMeta)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player)	
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	PersonalBlockArea[Player:GetName()]:Fill( 3, BlockType, BlockMeta ) -- fill the area with the right blocks
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- write the area in the world
	World:WakeUpSimulatorsInArea( OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1 )
	return GetSize(Player)
end


-------------------------------------------------
-----------------REPLACEFUNCTION-----------------
-------------------------------------------------
function HandleReplaceSelection(Player, World, ChangeBlockType, ChangeBlockMeta, ToChangeBlockType, ToChangeBlockMeta, TypeOnly)
	local OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords(Player)
	local Blocks =  0
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ)
	PersonalBlockArea[Player:GetName()]:Read(World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ) -- Read the area
	local XSize = PersonalBlockArea[Player:GetName()]:GetSizeX() - 1
	local YSize = PersonalBlockArea[Player:GetName()]:GetSizeY() - 1
	local ZSize = PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1
	for X=0, XSize do
		for Y=0, YSize do
			for Z=0, ZSize do
				if PersonalBlockArea[Player:GetName()]:GetRelBlockType(X, Y, Z) == ChangeBlockType then -- if the blocktype is the same as the block that needs to change then
					if PersonalBlockArea[Player:GetName()]:GetRelBlockMeta(X, Y, Z) == ChangeBlockMeta or (TypeOnly) then -- check if the blockmeta is the same as the meta that has to change
						PersonalBlockArea[Player:GetName()]:SetRelBlockType(X, Y, Z, ToChangeBlockType) -- change the block
						PersonalBlockArea[Player:GetName()]:SetRelBlockMeta(X, Y, Z, ToChangeBlockMeta) -- change the meta
						Blocks = Blocks + 1 -- add a 1 to the amount of changed blocks.
					end
				end
			end
		end
	end
	PersonalBlockArea[Player:GetName()]:Write(World, OneX, OneY, OneZ) -- write the area into the world.
	World:WakeUpSimulatorsInArea( OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1 )
	return Blocks
end


-------------------------------------------
------------RIGHTCLICKCOMPASS--------------
-------------------------------------------
function RightClickCompass(Player, World)
	local Teleported = false
	local Air = false
	local Callbacks = {
		OnNextBlock = function(X, Y, Z, BlockType, BlockMeta)
			if BlockType ~= E_BLOCK_AIR then
				Air = true
			else
				if Air then
					if BlockType == E_BLOCK_AIR and World:GetBlock(X, Y - 1, Z) ~= E_BLOCK_AIR then
						Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
						Teleported = true
						return true
					else
						for y = Y, 1, -1 do
							if World:GetBlock(X, y, Z) ~= E_BLOCK_AIR then
								Player:TeleportToCoords(X + 0.5, y + 1, Z + 0.5)
								Teleported = true
								return true
							end
						end
					end
				end
			end
		end;
	};
	local EyePos = Player:GetEyePosition()
	local LookVector = Player:GetLookVector()
	LookVector:Normalize()	

	local Start = EyePos + LookVector + LookVector;
	local End = EyePos + LookVector * 75
	
	cLineBlockTracer.Trace(World, Callbacks, Start.x, Start.y, Start.z, End.x, End.y, End.z)
	if not Teleported then
		Player:SendMessage(cChatColor.Rose .. "Nothing to pass through!")
	end
end


------------------------------------------
------------LEFTCLICKCOMPASS--------------
------------------------------------------
function LeftClickCompass(Player, World)
	local Tracer = cTracer(World)
	local EyePos = Vector3f(Player:GetEyePosition().x, Player:GetEyePosition().y, Player:GetEyePosition().z)
	local EyeVector = Vector3f(Player:GetLookVector().x, Player:GetLookVector().y, Player:GetLookVector().z)
	Tracer:Trace(EyePos , EyeVector, 200)
	local X = Tracer.BlockHitPosition.x
	local Z = Tracer.BlockHitPosition.z
	local Y = Tracer.BlockHitPosition.y
	if Z == 0 and X == 0 and Y == 0 then
		return false
	end
	
	for y = Y, World:GetHeight(X, Z) + 1 do
		if World:GetBlock(X, y, Z) == E_BLOCK_AIR then
			Y = y
			break
		end
	end
	Player:TeleportToCoords(X + 0.5, Y, Z + 0.5)
	return true
end