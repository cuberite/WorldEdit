




cBlockSrc = {}





function cBlockSrc:new(a_Blocks)
	local BlockArray, ErrorBlock = RetrieveBlockTypes(a_Blocks)
	if (not BlockArray) then
		return false, ErrorBlock
	end
	
	local BlockTable = {}
	
	for Idx, Block in ipairs(BlockArray) do
		local BlockInfo = BlockTable[Block.BlockType] or {TypeOnly = false, BlockMetas = {}}
		BlockInfo.TypeOnly = BlockInfo.TypeOnly or Block.TypeOnly
		if (not BlockInfo.TypeOnly) then
			BlockInfo.BlockMetas[Block.BlockMeta] = true
		end
		
		BlockTable[Block.BlockType] = BlockInfo
	end
	
	local Obj = {}
	
	setmetatable(Obj, cBlockSrc)
	self.__index = self
	
	Obj.m_BlockTable = BlockTable
	
	return Obj
end





function cBlockSrc:Contains(a_BlockType, a_BlockMeta)
	local BlockInfo = self.m_BlockTable[a_BlockType]
	if (not BlockInfo) then
		return false
	end
	
	if (BlockInfo.TypeOnly) then
		return true
	end
	
	return BlockInfo.BlockMetas[a_BlockMeta] or false
end




