
-- BlockDstConstant.lua

-- Implements the cBlockDstConstant class that always returns the same block





cBlockDstConstant = {}





function cBlockDstConstant:new(a_BlockString)
	local BlockType, BlockMeta = GetBlockTypeMeta(a_BlockString)
	if (not BlockType) then
		return false, BlockMeta -- On error the blockmeta is the block that isn't valid
	end
	
	local Obj = {}
	
	setmetatable(Obj, cBlockDstConstant)
	self.__index = self
	
	Obj.m_BlockType = BlockType
	Obj.m_BlockMeta = BlockMeta
	
	return Obj
end





function cBlockDstConstant:Get(a_X, a_Y, a_Z)
	return self.m_BlockType, self.m_BlockMeta
end




