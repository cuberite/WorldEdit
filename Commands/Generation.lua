
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

	local BlockTable, ErrBlock = GetBlockDst(a_Split[2 + NumFlags], a_Player)
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. ErrBlock .. "'.")
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

	local Expression = cExpression:new(FormulaString)

	-- Create the shape generator
	local ShapeGenerator, Error = cShapeGenerator:new(zero, unit, BlockTable, Expression, a_Player:HasPermission('worldedit.anyblock'))
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
	local Success, NumAffectedBlocks = pcall(cShapeGenerator.MakeShape, ShapeGenerator, BA, Vector3f(1, 1, 1), Vector3f(SizeX, SizeY, SizeZ), IsHollow, Mask)
	if (not Success) then
		a_Player:SendMessage(cChatColor.Rose .. NumAffectedBlocks:match(":%d-: (.+)"))
		return true;
	end

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
		a_Player:SendMessage(cChatColor.Rose .. a_Split[1] .. " <block> <radius>[,<radius>] [height]")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable, ErrBlock = GetBlockDst(a_Split[2], a_Player)
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. ErrBlock .. "'.")
		return true
	end

	local RadiusX, RadiusZ
	local Radius = tonumber(a_Split[3])
	if (Radius) then
		-- Same radius for all axis
		RadiusX, RadiusZ = Radius, Radius, Radius
	else
		-- The player might want to specify the radius for each axis.
		local Radius = StringSplit(a_Split[3], ",")
		if (#Radius == 1) then
			a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
			return true
		end

		if (#Radius ~= 2) then
			a_Player:SendMessage(cChatColor.Rose .. "You must specify 1 or 2 radius values")
			return true
		end

		-- Check if the radius for all axis are numbers
		for Idx = 1, 2 do
			if (not tonumber(Radius[Idx])) then
				a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. Radius[Idx] .. "\" given.")
				return true
			end
		end

		RadiusX, RadiusZ = tonumber(Radius[1]) + 1, tonumber(Radius[2]) + 1
	end

	local Height = tonumber(a_Split[4] or 1) - 1
	local Pos = a_Player:GetPosition():Floor()

	local Cuboid = cCuboid(Pos, Pos)
	Cuboid:Expand(RadiusX, RadiusX, 0, Height, RadiusZ, RadiusZ)
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
		a_Player:SendMessage(cChatColor.Rose .. a_Split[1] .. " <block> <radius>[,<radius>,<radius>]")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable, ErrBlock = GetBlockDst(a_Split[2], a_Player)
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. ErrBlock .. "'.")
		return true
	end

	local RadiusX, RadiusY, RadiusZ
	local Radius = tonumber(a_Split[3])
	if (Radius) then
		-- Same radius for all axis
		RadiusX, RadiusY, RadiusZ = Radius, Radius, Radius
	else
		-- The player might want to specify the radius for each axis.
		local Radius = StringSplit(a_Split[3], ",")
		if (#Radius == 1) then
			a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
			return true
		end

		if (#Radius ~= 3) then
			a_Player:SendMessage(cChatColor.Rose .. "You must specify 1 or 3 radius values")
			return true
		end

		-- Check if the radius for all axis are numbers
		for Idx = 1, 3 do
			if (not tonumber(Radius[Idx])) then
				a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. Radius[Idx] .. "\" given.")
				return true
			end
		end

		RadiusX, RadiusY, RadiusZ = tonumber(Radius[1]) + 1, tonumber(Radius[2]) + 1, tonumber(Radius[3]) + 1
	end

	local Pos = a_Player:GetPosition():Floor()

	local Cuboid = cCuboid(Pos, Pos)
	Cuboid:Expand(RadiusX, RadiusX, RadiusY, RadiusY, RadiusZ, RadiusZ)
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
		a_Player:SendMessage(cChatColor.Rose .. a_Split[1] .. " <block> <size>[,<size>,<size>]")
		return true
	end

	-- Retrieve the blocktypes from the params:
	local BlockTable, ErrBlock = GetBlockDst(a_Split[2], a_Player)
	if not(BlockTable) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Unknown block type: '" .. ErrBlock .. "'.")
		return true
	end

	local RadiusX, RadiusY, RadiusZ
	local Radius = tonumber(a_Split[3])
	if (Radius) then
		-- Same size for all axis
		RadiusX, RadiusY, RadiusZ = Radius, Radius, Radius
	else
		-- The player might want to specify the size for each axis.
		local Radius = StringSplit(a_Split[3], ",")
		if (#Radius == 1) then
			a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. a_Split[3] .. "\" given.")
			return true
		end

		if (#Radius ~= 3) then
			a_Player:SendMessage(cChatColor.Rose .. "You must specify 1 or 3 size values")
			return true
		end

		-- Check if the size for all axis are numbers
		for Idx = 1, 3 do
			if (not tonumber(Radius[Idx])) then
				a_Player:SendMessage(cChatColor.Rose .. "Number expected; string \"" .. Radius[Idx] .. "\" given.")
				return true
			end
		end

		RadiusX, RadiusY, RadiusZ = tonumber(Radius[1]) + 1, tonumber(Radius[2]) + 1, tonumber(Radius[3]) + 1
	end

	-- Get the position of the player as a Vector3i
	local Pos = a_Player:GetPosition():Floor()

	-- Create a cuboid with the points set to the player's position
	local Cuboid = cCuboid(Pos, Pos)
	Cuboid:Expand(RadiusX, RadiusX, 0, RadiusY, RadiusZ, RadiusZ)
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
	BlockArea:Read(World, Cuboid)

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
