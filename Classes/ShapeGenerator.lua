
-- ShapeGenerator.lua

-- Capable of generating shapes in BlockAreas. Either a predefined shape like a cylinder, or a shape from a mathematical formula.
-- Only for a shape made using a mathematical formula the constructor has to be used. For other shapes there are static functions to create the shape in a blockarea.





cShapeGenerator = {}





-- The coordinates around a single point
cShapeGenerator.m_Coords =
{
	Vector3f(1, 0, 0), Vector3f(-1, 0, 0), -- X coords
	Vector3f(0, 1, 0), Vector3f(0, -1, 0), -- Y coords
	Vector3f(0, 0, 1), Vector3f(0, 0, -1), -- Z coords
}





-- Handler that makes the structure hollow
cShapeGenerator.m_HollowHandler = function(a_ShapeGenerator, a_BlockArea, a_BlockPos)
	-- Check around the block coordinates if it has at least one single position that doesn't get set
	for Idx, Coord in ipairs(cShapeGenerator.m_Coords) do
		local CoordAround = a_BlockPos + Coord
		local DoSet = a_ShapeGenerator:GetBlockInfoFromFormula(CoordAround)
		if (not DoSet) then
			-- Empty spot around the block.
			return true
		end
	end --  /for Coords
	return false
end





-- Handler that makes the structure solid. 
cShapeGenerator.m_SolidHandler = function(a_ShapeGenerator, a_BlockArea, a_BlockPos)
	return true
end





-- Creates a new cShapeGenerator object.
-- a_Zero and a_Unit are Vector3f vectors used to calculate a scaled vector3f. The formula will use the scaled vector as x, y and z values.
-- a_BlockTable are the blocks to make the shape out of.
-- a_Expression is a cExpression object that compiles the formula into a safe function.
function cShapeGenerator:new(a_Zero, a_Unit, a_BlockTable, a_Expression)
	local Obj = {}
	
	setmetatable(Obj, cShapeGenerator)
	self.__index = self
	
	-- Bind the parameters that will be used in the expression. We want the data and type returned again with the first comparison
	a_Expression:AddReturnValue("Comp1")
	:AddParameter("x")
	:AddParameter("y")
	:AddParameter("z")
	:AddParameter("type"):AddReturnValue("type")
	:AddParameter("data"):AddReturnValue("data")
	
	local Formula, Error = a_Expression:Compile()
	if (not Formula) then
		return false, "Invalid formula"
	end
	
	-- Test the formula to check if it is a comparison.
	local Succes, TestResult = pcall(Formula, 1, 1, 1, 1, 1)
	if (not Succes or (type(TestResult) ~= "boolean")) then
		return false, "The formula isn't a comparison"
	end
	
	-- A cache with blocktypes by x, y, z coordinates.
	-- It's only used when the shape is hollow
	Obj.m_Cache      = {}
	
	-- A table containing all the blocks to use. The block chances are already calculated
	Obj.m_BlockTable = a_BlockTable
	
	-- A function that will calculate the shape
	Obj.m_Formula    = Formula
	
	Obj.m_Unit = a_Unit
	Obj.m_Zero = a_Zero
	
	-- The size of the blockarea we're going to work in.
	Obj.m_Size = Vector3f()
	
	return Obj
end





-- Returns a random block from self.m_BlockTable
function cShapeGenerator:ChooseBlockTypeMeta()
	local RandomNumber = math.random()
	for Idx, Value in ipairs(self.m_BlockTable) do
		if (RandomNumber <= Value.Chance) then
			return Value.BlockType, Value.BlockMeta
		end
	end
	
	return E_BLOCK_AIR, 0
end





-- Checks the cache if there already is a block calculated for the coordinates.
-- Generates a new one if it doesn't exist in the cache
-- a_BlockPos is a Vector3f with the coordinates to get the block for
function cShapeGenerator:GetBlockInfoFromFormula(a_BlockPos)
	local Index = a_BlockPos.x + (a_BlockPos.z * self.m_Size.x) + (a_BlockPos.y * self.m_Size.x * self.m_Size.z)
	local BlockInfo = self.m_Cache[Index]
	
	-- The block already exists in the cache. Return the info from that.
	if (BlockInfo) then
		return BlockInfo.DoSet, BlockInfo.BlockType, BlockInfo.BlockMeta
	end
	
	local scaled = (a_BlockPos - self.m_Zero) / self.m_Unit
	local BlockType, BlockMeta = self:ChooseBlockTypeMeta()
	
	-- Execute the formula to get the info from it.
	local DoSet, BlockType, BlockMeta = self.m_Formula(scaled.x, scaled.y, scaled.z, BlockType, BlockMeta)
	
	-- Save the block info in the cache
	self.m_Cache[Index] = {DoSet = DoSet, BlockType = BlockType, BlockMeta = BlockMeta}
	
	return DoSet, BlockType, BlockMeta
end





-- Generates a shape from m_Formula
-- a_BlockArea is a cBlockArea to build the shape in
-- a_MinVector and a_MaxVector are Vector3f classes. The shape will be build inside those coordinates
-- a_IsHollow is a boolean value. If true the the shape will be made hollow
-- a_Mask is a table or nil. If it's a table it will only change blocks if the block that is going to change is in the table.
function cShapeGenerator:MakeShape(a_BlockArea, a_MinVector, a_MaxVector, a_IsHollow, a_Mask)
	local DoCheckMask = a_Mask ~= nil
	local Handler = a_IsHollow and cShapeGenerator.m_HollowHandler or cShapeGenerator.m_SolidHandler
	local NumAffectedBlocks = 0
	self.m_Size = Vector3f(a_BlockArea:GetSize())
	
	local CurrentBlock = Vector3f(a_MinVector)
	for X = a_MinVector.x, a_MaxVector.x do
		CurrentBlock.x = X
		for Y = a_MinVector.y, a_MaxVector.y do
			CurrentBlock.y = Y
			for Z = a_MinVector.z, a_MaxVector.z do
				CurrentBlock.z = Z
				local DoSet, BlockType, BlockMeta = self:GetBlockInfoFromFormula(CurrentBlock)
				
				-- Check for the mask. 
				if (DoSet and DoCheckMask) then
					local CurrentBlock, CurrentMeta = a_BlockArea:GetRelBlockTypeMeta(X, Y, Z)
					local MaskBlock = a_Mask[CurrentBlock]
					
					if ((MaskBlock == nil) or ((not MaskBlock.TypeOnly) and (MaskBlock.BlockMeta ~= CurrentMeta))) then
						-- The block does not exist in the mask, or the meta isn't set/is different.
						-- Don't change the block.
						DoSet = false
					end
				end
					
				if (DoSet and Handler(self, a_BlockArea, CurrentBlock)) then
					a_BlockArea:SetRelBlockTypeMeta(X, Y, Z, BlockType, BlockMeta)
					NumAffectedBlocks = NumAffectedBlocks + 1
				end
			end --  /for Z
		end --  /for Y
	end --  /for X
	
	return NumAffectedBlocks
end





-- (STATIC) Creates a cylinder in the given blockarea
-- a_BlockArea is the cBlockArea to build the cylinder in
-- a_BlockTable are the blocks to make the cylinder out of
-- a_Radius is the radius to make the cylinder out of. This will be removed later when malformed cylinders are supported.
-- a_IsHollow is a boolean value. If true the cylinder will be made hollow.
-- a_Mask is a table or nil. If it's a table it will only change blocks if the block that is going to change is in the table.
function cShapeGenerator.MakeCylinder(a_BlockArea, a_BlockTable, a_Radius, a_IsHollow, a_Mask)
	local DoCheckMask = a_Mask ~= nil
	local SizeX, SizeY, SizeZ = a_BlockArea:GetCoordRange()
	local MiddleVector = Vector3f(SizeX / 2, 0, SizeZ / 2)
	local NumAffectedBlocks = 0
	local CurrentBlock = Vector3f(0, 0, 0)
	
	-- TODO: change this to not take a radius parameter, but rather make it support malformed cylinders (for example SizeX = 5 while SizeZ = 8)
	local Radius = (a_IsHollow and math.floor(a_Radius)) or a_Radius
	
	for X = 0, SizeX do
		CurrentBlock.x = X
		for Z = 0, SizeZ do
			CurrentBlock.z = Z
			
			local PlaceColumn = false
			local Distance = math.floor(((MiddleVector - CurrentBlock):Length()))
			if (
				((Distance <= Radius) and (not a_IsHollow)) or
				((Distance == Radius) and a_IsHollow)
			) then
				PlaceColumn = true
			end
			
			if (PlaceColumn) then
				for Y = 0, SizeY do
					local PlaceBlock = true
					
					-- Check for the mask. 
					if (PlaceColumn and DoCheckMask) then
						local CurrentBlock, CurrentMeta = a_BlockArea:GetRelBlockTypeMeta(X, Y, Z)
						local MaskBlock = a_Mask[CurrentBlock]
						
						if ((MaskBlock == nil) or ((not MaskBlock.TypeOnly) and (MaskBlock.BlockMeta ~= CurrentMeta))) then
							-- The block does not exist in the mask, or the meta isn't set/is different.
							-- Don't change the block.
							PlaceBlock = false
						end
					end
					
					if (PlaceBlock) then
						-- We want to place the block. Choose a blocktype and set it in the blockarea
						NumAffectedBlocks = NumAffectedBlocks + 1
						
						local RandomNumber = math.random()
						for Idx, Value in ipairs(a_BlockTable) do
							if (RandomNumber <= Value.Chance) then
								a_BlockArea:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
								break
							end
						end
					end
				end -- /for Y
			end
		end -- /for Z
	end -- /for X
	
	return NumAffectedBlocks
end





-- (STATIC) Creates a sphere in the given blockarea.
-- a_BlockArea is the cBlockArea to build the sphere in
-- a_BlockTable are the blocks to make the sphere out of
-- a_Radius is the radius to make the sphere out of. This will be removed later when malformed spheres are supported.
-- a_IsHollow is a boolean value. If true the sphere will be made hollow.
-- a_Mask is a table or nil. If it's a table it will only change blocks if the block that is going to change is in the table.
function cShapeGenerator.MakeSphere(a_BlockArea, a_BlockTable, a_Radius, a_IsHollow, a_Mask)
	local DoCheckMask = a_Mask ~= nil
	local SizeX, SizeY, SizeZ = a_BlockArea:GetCoordRange()
	local MiddleVector = Vector3f(SizeX / 2, SizeY / 2, SizeZ / 2)
	local NumAffectedBlocks = 0
	local CurrentBlock = Vector3f(0, 0, 0)
	
	-- TODO: change this to not take a radius parameter, but rather make it support malformed sphere (for example SizeX = 5 while SizeZ = 8)
	local Radius = (a_IsHollow and math.floor(a_Radius)) or a_Radius
	
	for X = 0, SizeX do
		CurrentBlock.x = X
		for Y = 0, SizeY do
			CurrentBlock.y = Y
			for Z = 0, SizeZ do
				CurrentBlock.z = Z
				
				local PlaceBlock = false
				local Distance = math.floor(((MiddleVector - CurrentBlock):Length()))
				if (
					((Distance <= Radius) and (not a_IsHollow)) or
					((Distance == Radius) and a_IsHollow)
				) then
					PlaceBlock = true
				end
				
				-- Check for the mask. 
				if (PlaceBlock and DoCheckMask) then
					local CurrentBlock, CurrentMeta = a_BlockArea:GetRelBlockTypeMeta(X, Y, Z)
					local MaskBlock = a_Mask[CurrentBlock]
					
					if ((MaskBlock == nil) or ((not MaskBlock.TypeOnly) and (MaskBlock.BlockMeta ~= CurrentMeta))) then
						PlaceBlock = false
					end
				end
			
				if (PlaceBlock) then
					-- We want to place the block. Choose a blocktype and set it in the blockarea
					
					NumAffectedBlocks = NumAffectedBlocks + 1
					local RandomNumber = math.random()
					for Idx, Value in ipairs(a_BlockTable) do
						if (RandomNumber <= Value.Chance) then
							a_BlockArea:SetRelBlockTypeMeta(X, Y, Z, Value.BlockType, Value.BlockMeta)
							break
						end
					end
				end
			end -- /for Z
		end -- /for Y
	end -- /for X
	
	return NumAffectedBlocks
end





-- (STATIC) Creates a pyramid in the given BlockArea.
-- a_BlockArea is the cBlockArea to build the pyramid in
-- a_BlockTable are the blocks to make the pyramid out of
-- a_IsHollow is a boolean value. If true the pyramid will be made hollow.
-- a_Mask is a table or nil. If it's a table it will only change blocks if the block that is going to change is in the table.
function cShapeGenerator.MakePyramid(a_BlockArea, a_BlockTable, a_IsHollow, a_Mask)
	local DoCheckMask = a_Mask ~= nil
	local SizeX, SizeY, SizeZ = a_BlockArea:GetCoordRange()
	local NumAffectedBlocks = 0
	
	-- Function that checks in the mask if a block can be placed. 
	local function CheckMask(a_X, a_Y, a_Z)
		if (not DoCheckMask) then
			-- We don't have to check the mask, because a_Mask is nil
			return true
		end
		
		local CurrentBlock, CurrentMeta = a_BlockArea:GetRelBlockTypeMeta(a_X, a_Y, a_Z)
		local MaskBlock = a_Mask[CurrentBlock]
		
		if ((MaskBlock == nil) or ((not MaskBlock.TypeOnly) and (MaskBlock.BlockMeta ~= CurrentMeta))) then
			return false
		end
		return true
	end
	
	-- Returns a random block from a_BlockTable
	local GetBlockTypeMeta = function()
		local RandomNumber = math.random()
		for Idx, Value in ipairs(a_BlockTable) do
			if (RandomNumber <= Value.Chance) then
				return Value.BlockType, Value.BlockMeta
			end
		end
	end
	
	-- Makes a hollow layer
	local HollowLayer = function(a_Y)
		local MinX = a_Y
		local MaxX = SizeX - a_Y
		local MinZ = a_Y
		local MaxZ = SizeZ - a_Y
		for X = MinX, MaxX do
			if (CheckMask(X, a_Y, MinZ)) then
				NumAffectedBlocks = NumAffectedBlocks + 1
				local BlockType, BlockMeta = GetBlockTypeMeta()
				a_BlockArea:SetRelBlockTypeMeta(X, a_Y, MinZ, BlockType, BlockMeta)
			end
			
			if (CheckMask(X, a_Y, MaxZ)) then
				NumAffectedBlocks = NumAffectedBlocks + 1
				local BlockType, BlockMeta = GetBlockTypeMeta()
				a_BlockArea:SetRelBlockTypeMeta(X, a_Y, MaxZ, BlockType, BlockMeta)
			end
		end
		
		for Z = MinZ + 1, MaxZ - 1 do
			if (CheckMask(MinX, a_Y, Z)) then
				NumAffectedBlocks = NumAffectedBlocks + 1
				local BlockType, BlockMeta = GetBlockTypeMeta()
				a_BlockArea:SetRelBlockTypeMeta(MinX, a_Y, Z, BlockType, BlockMeta)
			end
			
			if (CheckMask(MaxX, a_Y, Z)) then
				NumAffectedBlocks = NumAffectedBlocks + 1
				local BlockType, BlockMeta = GetBlockTypeMeta()
				a_BlockArea:SetRelBlockTypeMeta(MaxX, a_Y, Z, BlockType, BlockMeta)
			end
		end
	end
	
	-- Makes a solid layer
	local SolidLayer = function(a_Y)
		local MinX = a_Y
		local MaxX = SizeX - a_Y
		local MinZ = a_Y
		local MaxZ = SizeZ - a_Y
		for X = MinX, MaxX do
			for Z = MinZ, MaxZ do
				if (CheckMask(X, a_Y, Z)) then
					NumAffectedBlocks = NumAffectedBlocks + 1
					local BlockType, BlockMeta = GetBlockTypeMeta()
					a_BlockArea:SetRelBlockTypeMeta(X, a_Y, Z, BlockType, BlockMeta)
				end
			end
		end
	end
	
	-- Choose the layer handler
	local LayerHandler = (a_IsHollow and HollowLayer) or SolidLayer;
	
	-- Call the layer handler on each layer.
	for Y = 0, SizeY do		
		LayerHandler(Y)
	end
	
	-- Return the number of changed blocks
	return NumAffectedBlocks;
end



