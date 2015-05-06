
-- Generation.lua

-- Implements the commands from the Generation category





function HandleGenerationShapeCommand(a_Split, a_Player)
	-- //generate <block> <formula>
	
	local IsHollow     = false
	local UseRawCoords = false
	local Offset       = false
	local OffsetCenter = false
	
	local NumFlags = 0
	for Idx, Value in ipairs(a_Split) do
		NumFlags = NumFlags + 1
		if (Value == "-h") then
			IsHollow = true
		elseif (Value == "-r") then
			UseRawCoords = true
		elseif (Value == "-o") then
			Offset = true
		elseif (Value == "-c") then
			OffsetCenter = true
		else
			NumFlags = NumFlags - 1
		end
	end
	
	if ((a_Split[2 + NumFlags] == nil) or (a_Split[3 + NumFlags] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "//generate [Flags] <block> <formula>")
		return true
	end
	
	-- Check the selection:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "No region set")
		return true
	end
	
	local BlockTable = RetrieveBlockTypes(a_Split[2 + NumFlags])
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[2 + NumFlags] .. "'.")
		return true
	end
	
	-- Get the selected area
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	
	-- Expand the area in all directions. Otherwise we get some weird results at the sides
	SrcCuboid:Expand(1, 1, 1, 1, 1, 1)
	SrcCuboid:ClampY(0, 255)
	SrcCuboid:Sort()
	
	local FormulaString = table.concat(a_Split, " ", 3 + NumFlags)
	
	local zero, unit
	
	-- Read the selected cuboid into a cBlockArea:
	local BA = cBlockArea()
	BA:Read(World, SrcCuboid)
	
	local SizeX, SizeY, SizeZ = BA:GetCoordRange()
	SizeX = SizeX - 1
	SizeY = SizeY - 1
	SizeZ = SizeZ - 1
	
	-- Get the proper zero and unit values
	if (UseRawCoords) then
		zero = Vector3f(0, 0, 0)
		unit = Vector3f(1, 1, 1)
	elseif (Offset) then
		zero = Vector3f(SrcCuboid.p1) - Vector3f(a_Player:GetPosition())
		unit = Vector3f(1, 1, 1)
	elseif (OffsetCenter) then
		-- The lowest coordinate in the region
		local Min = Vector3f(0, 0, 0)
		
		-- The highest coordinate in the region.
		local Max = Vector3f(SizeX, SizeY, SizeZ)
		
		zero = (Max + Min) * 0.5
		unit = Vector3f(1, 1, 1)
	else
		-- The lowest coordinate in the region
		local Min = Vector3f(0, 0, 0)
		
		-- The highest coordinate in the region.
		local Max = Vector3f(SizeX, SizeY, SizeZ)
		
		zero = (Max + Min) * 0.5
		unit = Max - zero
	end
	
	local BlockTable = CalculateBlockChances(BlockTable)
	local Expression = cExpression:new(FormulaString)
	
	-- Create the shape generator
	local ShapeGenerator, Error = cShapeGenerator:new(zero, unit, BlockTable, Expression)
	if (not ShapeGenerator) then
		-- Something went wrong while constructing the ShapeGenerator.
		a_Player:SendMessage(cChatColor.Rose .. Error)
		return true
	end
	
	-- Check if other plugins want to block this action
	if (CallHook("OnAreaChanging", SrcCuboid, a_Player, World, "generate")) then
		return true
	end
	
	-- Push an undo snapshot:
	State.UndoStack:PushUndoFromCuboid(World, SrcCuboid, "generation")
	
	-- Get the mask for the equipped item
	local Mask = State.ToolRegistrator:GetMask(a_Player:GetEquippedItem().m_ItemType)
	
	-- Write the shape in the block area
	local NumAffectedBlocks = ShapeGenerator:MakeShape(BA, Vector3f(1, 1, 1), Vector3f(SizeX, SizeY, SizeZ), IsHollow, Mask)
	
	-- Send a message to the player with the number of changed blocks
	a_Player:SendMessage(cChatColor.LightPurple .. NumAffectedBlocks .. " block(s) changed")
	
	-- Write the blockarea in the world
	BA:Write(World, SrcCuboid.p1)
	
	-- Notify other plugins that the shape is in the world
	CallHook("OnAreaChanged", SrcCuboid, a_Player, World, "generate")
	return true
end





function HandleCylCommand(a_Split, a_Player)
	-- //cyl <BlockType> <Radius> [Height]
	-- //hcyl <BlockType> <Radius> [Height]

	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. a_Split[1] .. " <block> <radius> [height]")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable = RetrieveBlockTypes(a_Split[2])
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[2] .. "'.")
		return true
	end
	
	BlockTable = CalculateBlockChances(BlockTable)

	local Radius = tonumber(a_Split[3])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	
	local Height = tonumber(a_Split[4] or 1) - 1
	local Pos = a_Player:GetPosition():Floor()
	
	local Cuboid = cCuboid(Pos, Pos)
	Cuboid:Expand(Radius, Radius, 0, Height, Radius, Radius)
	Cuboid:Sort()
	
	-- Create the sphere in the world
	local NumAffectedBlocks = CreateCylinderInCuboid(a_Player, Cuboid, BlockTable, a_Split[1] == "//hcyl")
	
	-- Send a message to the player with the amount of affected blocks
	a_Player:SendMessage(cChatColor.LightPurple .. NumAffectedBlocks .. " block(s) have been created.")
	return true
end





function HandleSphereCommand(a_Split, a_Player)
	-- //sphere <BlockType> <Radius>
	-- //hsphere <BlockType> <Radius>

	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. a_Split[1] .. " <block> <radius> [height]")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable = RetrieveBlockTypes(a_Split[2])
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[2] .. "'.")
		return true
	end
	
	BlockTable = CalculateBlockChances(BlockTable)

	local Radius = tonumber(a_Split[3])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	
	local Pos    = a_Player:GetPosition():Floor()
	
	local Cuboid = cCuboid(Pos, Pos)
	Cuboid:Expand(Radius, Radius, Radius, Radius, Radius, Radius)
	Cuboid:Sort()
	
	-- Create the sphere in the world
	local NumAffectedBlocks = CreateSphereInCuboid(a_Player, Cuboid, BlockTable, a_Split[1] == "//hsphere")
	
	-- Send a message to the player with the amount of affected blocks
	a_Player:SendMessage(cChatColor.LightPurple .. NumAffectedBlocks .. " block(s) have been created.")
	return true
end





function HandlePyramidCommand(a_Split, a_Player)
	-- //pyramid <block> <size>
	-- //hpyramid <block <size>
	
	if ((a_Split[2] == nil) or (a_Split[3] == nil)) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.")
		a_Player:SendMessage(cChatColor.Rose .. a_Split[1] .. " <block> <size>")
		return true
	end
	
	-- Retrieve the blocktypes from the params:
	local BlockTable = RetrieveBlockTypes(a_Split[2])
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. a_Split[2] .. "'.")
		return true
	end
	
	BlockTable = CalculateBlockChances(BlockTable)
	
	local Radius = tonumber(a_Split[3])
	if (not Radius) then
		a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
		return true
	end
	
	Radius = Radius - 1
	local Height = tonumber(a_Split[4] or 1) - 1
	local Pos = a_Player:GetPosition():Floor()
	
	-- Create a cuboid with the points set to the player's position
	local Cuboid = cCuboid(Pos, Pos)
	Cuboid:Expand(Radius, Radius, 0, Radius, Radius, Radius)
	Cuboid:ClampY(0, 255)
	Cuboid:Sort()
	
	local World = a_Player:GetWorld()
	
	-- Check other plugins
	if (CallHook("OnAreaChanging", Cuboid, a_Player, World, a_Split[1]:sub(3, -1))) then
		return true
	end
	
	-- Push the area into an undo stack:
	local State = GetPlayerState(a_Player)
	State.UndoStack:PushUndoFromCuboid(World, Cuboid)
	
	local BlockArea = cBlockArea()
	
	-- Read the affected area from the world.
	BlockArea:Read(World, Cuboid, cBlockArea.baTypes + cBlockArea.baMetas)
	
	-- Get the mask for the equipped item
	local Mask = State.ToolRegistrator:GetMask(a_Player:GetEquippedItem().m_ItemType)
	
	-- Create the pyramid in the blockarea.
	local AffectedBlocks = cShapeGenerator.MakePyramid(BlockArea, BlockTable, a_Split[1] == "//hpyramid", Mask);
	
	-- Write the changes into the world
	BlockArea:Write(World, Cuboid.p1)
	
	-- Notify other plugins of the (h)pyramid
	CallHook("OnAreaChanged", Cuboid, a_Player, World, a_Split[1]:sub(3, -1))
	
	-- Send a message to the player with the amount of changed blocks
	a_Player:SendMessage(cChatColor.LightPurple .. AffectedBlocks .. " block(s) have been created.")
	
	return true
end








