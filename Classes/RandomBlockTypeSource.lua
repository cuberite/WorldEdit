
-- BlockDstRandom.lua

-- Implements the cRandomBlockTypeSource class to return random blocks from a string.





cRandomBlockTypeSource = {}





function cRandomBlockTypeSource:new(a_BlockString)
	local BlockTable, ErrorBlock = cRandomBlockTypeSource.RetrieveBlockTypes(a_BlockString)
	if (not BlockTable) then
		return false, ErrorBlock
	end
	
	local Obj = {}
	
	setmetatable(Obj, cRandomBlockTypeSource)
	self.__index = self
	
	Obj.m_BlockTable = BlockTable
	
	return Obj
end





-- (STATIC) Returns a table from a string containing all the blocks with weighted chances
function cRandomBlockTypeSource.RetrieveBlockTypes(a_Input)
	local BlockTable, ErrBlock = RetrieveBlockTypes(a_Input)
	if (not BlockTable) then
		return false, ErrBlock
	end
	
	-- Count all the chances. This is used to calculate the chances off the blocks, since the chance from BlockTable are either raw from the player or 1.
	local ChanceSum = 0
	for Idx, BlockInfo in ipairs(BlockTable) do
		ChanceSum = ChanceSum + BlockInfo.Chance
	end
	
	local CalculatedBlockTable = {}
	local Temp = 0
	for Idx, BlockInfo in ipairs(BlockTable) do
		Temp = Temp + BlockInfo.Chance / ChanceSum
		table.insert(CalculatedBlockTable, {BlockType = BlockInfo.BlockType, BlockMeta = BlockInfo.BlockMeta, Chance = Temp})
	end
	
	return CalculatedBlockTable
end





-- Returns a random block from self.m_BlockTable
function cRandomBlockTypeSource:Get(a_X, a_Y, a_Z)
	local RandomNumber = math.random()
	for Idx, BlockInfo in ipairs(self.m_BlockTable) do
		if (RandomNumber <= BlockInfo.Chance) then
			return BlockInfo.BlockType, BlockInfo.BlockMeta
		end
	end
end





-- Returns if one of the blocktypes in the given table is in the block table as a key.
function cRandomBlockTypeSource:Contains(a_BlockTypeList)
	for Idx, BlockInfo in ipairs(self.m_BlockTable) do
		if (a_BlockTypeList[BlockInfo.BlockType]) then
			return true, BlockInfo.BlockType
		end
	end
	return false
end




