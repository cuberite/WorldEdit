
-- Mask.lua

-- Contains the cMask class representing blocks that can be replaced. Used for example in masks and the replace command.





cMask = {}




local function ParseBlockArray(a_BlockArray)
	-- Make from the array a table with the blocktypes as keys.
	-- In there create a table a boolean value called TypeOnly, and a table containing blockmetas
	-- If TypeOnly is set to true the Contains function will only check if the blocktype exists. Else it will look if the blockmeta exists in the BlockMetas table.
	local BlockTable = {}
	for Idx, Block in ipairs(a_BlockArray) do
		local BlockInfo = BlockTable[Block.BlockType] or {TypeOnly = false, BlockMetas = {}}
		BlockInfo.TypeOnly = BlockInfo.TypeOnly or Block.TypeOnly
		if (not BlockInfo.TypeOnly) then
			BlockInfo.BlockMetas[Block.BlockMeta] = true
		end

		-- Save the blockinfo in the table with the blocktype as key.
		BlockTable[Block.BlockType] = BlockInfo
	end
	return BlockTable;
end





local function Contains(a_BlockTable, a_BlockType, a_BlockMeta)
	local BlockInfo = a_BlockTable[a_BlockType]
	if (not BlockInfo) then
		return false
	end

	if (BlockInfo.TypeOnly) then
		-- The block is marked to only check the blocktype, so we don't have to check the meta.
		-- Since the block exists in the blocktable we can just return true
		return true
	end

	-- Check if the meta exists. If it exists it has the value true, so we either return that or return false.
	return BlockInfo.BlockMetas[a_BlockMeta] or false
end





function cMask:new(a_PositiveBlocks, a_NegativeBlocks)
	-- Get all the different blocks from the string
	local Obj = {}

	setmetatable(Obj, cMask)
	self.__index = self

	Obj.m_PositiveBlockTable = {}
	Obj.m_NegativeBlockTable = nil

	if (a_PositiveBlocks ~= nil) then
		local BlockArray, ErrorBlock = RetrieveBlockTypes(a_PositiveBlocks)
		if (not BlockArray) then
			return false, ErrorBlock
		end
		Obj.m_PositiveBlockTable = ParseBlockArray(BlockArray)
	end

	if (a_NegativeBlocks ~= nil) then
		local BlockArray, ErrorBlock = RetrieveBlockTypes(a_NegativeBlocks)
		if (not BlockArray) then
			return false, ErrorBlock
		end
		Obj.m_NegativeBlockTable = ParseBlockArray(BlockArray)
	end

	return Obj
end





-- Checks if the given blocktype exists in the blocktable.
function cMask:Contains(a_BlockType, a_BlockMeta)
	if (self.m_NegativeBlockTable ~= nil and not Contains(self.m_NegativeBlockTable, a_BlockType, a_BlockMeta)) then
		return true;
	end

	if (not Contains(self.m_PositiveBlockTable, a_BlockType, a_BlockMeta)) then
		return false;
	end

	return true;
end
