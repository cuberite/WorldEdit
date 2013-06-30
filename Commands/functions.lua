function HandleCreateWalls( Player, World, BlockType, BlockMeta )
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- Get the right X, Y and Z coordinates
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. World:GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	local Blocks = ( 2 *  ( PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 + PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1 ) * PersonalBlockArea[Player:GetName()]:GetSizeY() ) -- Calculate the amount if blocks that are going to change
	if Blocks == 0 then -- if the wall is 1x1x1 then the amout of blocks changed are 1
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[Player:GetName()]:GetSizeX() - 1
	local YY = PersonalBlockArea[Player:GetName()]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta )	
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- Write the region into the world
	World:WakeUpSimulatorsInArea( OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1 )
	return Blocks
end



function HandleCreateFaces( Player, World, BlockType, BlockMeta )
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player ) -- get the coordinates
	local World = Player:GetWorld()	
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	local Blocks = ( 2 *  ( PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 + PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1 ) * PersonalBlockArea[Player:GetName()]:GetSizeY() ) -- calculate the amount of changed blocks.
	if Blocks == 0 then
		Blocks = 1
	end
	local Y = 0
	local Z = 0
	local X = 0
	local XX = PersonalBlockArea[Player:GetName()]:GetSizeX() - 1
	local YY = PersonalBlockArea[Player:GetName()]:GetSizeY() - 1
	local ZZ = PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, Z, Z, 3, BlockType, BlockMeta ) -- Walls
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, YY, ZZ, ZZ, 3, BlockType, BlockMeta )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( XX, XX, Y, YY, Z, ZZ, 3, BlockType, BlockMeta )
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, X, Y, YY, Z, ZZ, 3, BlockType, BlockMeta )
	
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, Y, Y, Z, ZZ, 3, BlockType, BlockMeta ) -- Floor
	PersonalBlockArea[Player:GetName()]:FillRelCuboid( X, XX, YY, YY, Z, ZZ, 3, BlockType, BlockMeta ) -- Ceiling

	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- write the area in the world.
	World:WakeUpSimulatorsInArea( OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1 )
	return Blocks
end



function HandleFillSelection( Player, World, BlockType, BlockMeta )
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )	
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- read the area
	PersonalBlockArea[Player:GetName()]:Fill( 3, BlockType, BlockMeta ) -- fill the area with the right blocks
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- write the area in the world
	World:WakeUpSimulatorsInArea( OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1 )
	return GetSize(Player)
end


function HandleReplaceSelection( Player, World, ChangeBlockType, ChangeBlockMeta, ToChangeBlockType, ToChangeBlockMeta )
	OneX, TwoX, OneY, TwoY, OneZ, TwoZ = GetXYZCoords( Player )
	local Blocks =  0
	LastCoords[Player:GetName()] = OneX .. "," .. OneY .. "," .. OneZ .. "," .. Player:GetWorld():GetName()
	PersonalUndo[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ )
	PersonalBlockArea[Player:GetName()]:Read( World, OneX, TwoX, OneY, TwoY, OneZ, TwoZ ) -- Read the area
	for X=0, PersonalBlockArea[Player:GetName()]:GetSizeX() - 1 do
		for Y=0, PersonalBlockArea[Player:GetName()]:GetSizeY() - 1 do
			for Z=0, PersonalBlockArea[Player:GetName()]:GetSizeZ() - 1 do
				if PersonalBlockArea[Player:GetName()]:GetRelBlockType( X, Y, Z ) == ChangeBlockType then -- if the blocktype is the same as the block that needs to change then
					if PersonalBlockArea[Player:GetName()]:GetRelBlockMeta( X, Y, Z ) == ChangeBlockMeta then -- check if the blockmeta is the same as the meta that has to change
						PersonalBlockArea[Player:GetName()]:SetRelBlockType( X, Y, Z, ToChangeBlockType ) -- change the block
						PersonalBlockArea[Player:GetName()]:SetRelBlockMeta( X, Y, Z, ToChangeBlockMeta ) -- change the meta
						Blocks = Blocks + 1 -- add a 1 to the amount of changed blocks.
					end
				end
			end
		end
	end
	PersonalBlockArea[Player:GetName()]:Write( World, OneX, OneY, OneZ ) -- write the area into the world.
	World:WakeUpSimulatorsInArea( OneX - 1, TwoX + 1, OneY - 1, TwoY + 1, OneZ - 1, TwoZ + 1 )
	return Blocks
end