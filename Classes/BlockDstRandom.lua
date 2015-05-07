
-- BlockDstRandom.lua

-- Implements the cBlockDstRandom class to return random blocks from a string.





cBlockDstRandom = {}





function cBlockDstRandom:new(a_BlockString)
	local BlockTable, ErrorBlock = cBlockDstRandom.RetrieveBlockTypes(a_BlockString)
	if (not BlockTable) then
		return false, ErrorBlock
	end
	
	local Obj = {}
	
	setmetatable(Obj, cBlockDstRandom)
	self.__index = self
	
	Obj.m_BlockTable = BlockTable
	
	return Obj
end





-- (STATIC) Returns a table from a string containing all the blocks with weighted chances
function cBlockDstRandom.RetrieveBlockTypes(a_Input)
	local BlockTable, ErrBlock = RetrieveBlockTypes(a_Input)
	if (not BlockTable) then
		return false, ErrBlock
	end
	
	local MaxChance = 0
	for Idx, BlockInfo in ipairs(BlockTable) do
		MaxChance = MaxChance + BlockInfo.Chance
	end
	
	local CalculatedBlockTable = {}
	local Temp = 0
	for Idx, BlockInfo in ipairs(BlockTable) do
		Temp = Temp + BlockInfo.Chance / MaxChance
		table.insert(CalculatedBlockTable, {BlockType = BlockInfo.BlockType, BlockMeta = BlockInfo.BlockMeta, Chance = Temp})
	end
	
	return CalculatedBlockTable
end





function cBlockDstRandom:Get(a_X, a_Y, a_Z)
	local RandomNumber = math.random()
	for Idx, BlockInfo in ipairs(self.m_BlockTable) do
		if (RandomNumber <= BlockInfo.Chance) then
			return BlockInfo.BlockType, BlockInfo.BlockMeta
		end
	end
end




