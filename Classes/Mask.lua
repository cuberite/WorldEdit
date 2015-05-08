
-- Mask.lua

-- Contains the cMask class representing blocks that can be replaced. Used for example in masks and the replace command.





cMask = {}





function cMask:new(a_Blocks)
	-- Get all the different blocks from the string
	local BlockArray, ErrorBlock = RetrieveBlockTypes(a_Blocks)
	if (not BlockArray) then
		return false, ErrorBlock
	end
	
	-- Make from the array a table with the blocktypes as keys.
	-- In there create a table a boolean value called TypeOnly, and a table containing blockmetas
	-- If TypeOnly is set to true the Contains function will only check if the blocktype exists. Else it will look if the blockmeta exists in the BlockMetas table.
	local BlockTable = {}
	for Idx, Block in ipairs(BlockArray) do
		local BlockInfo = BlockTable[Block.BlockType] or {TypeOnly = false, BlockMetas = {}}
		BlockInfo.TypeOnly = BlockInfo.TypeOnly or Block.TypeOnly
		if (not BlockInfo.TypeOnly) then
			BlockInfo.BlockMetas[Block.BlockMeta] = true
		end
		
		-- Save the blockinfo in the table with the blocktype as key.
		BlockTable[Block.BlockType] = BlockInfo
	end
	
	local Obj = {}
	
	setmetatable(Obj, cMask)
	self.__index = self
	
	Obj.m_BlockTable = BlockTable
	
	return Obj
end





-- Checks if the given blocktype exists in the blocktable.
function cMask:Contains(a_BlockType, a_BlockMeta)
	local BlockInfo = self.m_BlockTable[a_BlockType]
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




