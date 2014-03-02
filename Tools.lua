
-- Tools.lua

-- Implements the cTools class representing the tools for a single player





--- Class for storing the player's selection
cTools = {}





--- Creates a new instance of the class
function cTools:new(a_Obj, a_PlayerState)
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cTools)
	self.__index = self
	
	-- Initialize the object members:
	a_Obj.SuperPickaxe = false
	a_Obj.ReplaceTool  = {ToHoldItem = -1, ToChangeBlock = cItem()}
	a_Obj.GrowTreeTool = -1
	
	return a_Obj
end





-- Swiches the superpickaxe state between true and false.
function cTools:SwichSuperPickaxeActivated()
	if (self.SuperPickaxe) then
		self.SuperPickaxe = false
	else
		self.SuperPickaxe = true
	end
	
	-- Return in what state the SuperPickaxe now is.
	return self.SuperPickaxe
end





-- Sets the superpickaxe state to the given state.
function cTools:SetSuperPickaxeActivated(a_Bool)
	assert(type(a_Bool) == 'bool')
	
	self.SuperPickaxe = a_Bool
end





-- Returns true if superpickaxe is activated.
function cTools:HasSuperPickaxeActivated()
	return self.SuperPickaxe;
end





-- Returns true if the given itemtype is the GrowTreeTool
function cTools:IsGrowTreeTool(a_ItemType)
	return (self.GrowTreeTool == a_ItemType)
end





-- Enables the GrowTreeTool and sets the tool to given itemtype
function cTools:EnableGrowTreeTool(a_ItemType)
	assert(type(a_ItemType) == 'number')
	
	self.GrowTreeTool = a_ItemType
end





-- Disables the GrowTreeTool
function cTools:DisableGrowTreeTool()
	self.GrowTreeTool = -1
end





-- Returns true if the ReplaceTool is activated
function cTools:IsReplaceToolActivated()
	return (self.ReplaceTool.ToHoldItem ~= -1)
end





-- Returns true if the given ItemType is the ReplaceTool
function cTools:IsReplaceTool(a_ItemType)
	return (self.ReplaceTool.ToHoldItem == a_ItemType)
end


	
	

-- Activates the ReplaceTool and sets the ToChangeBlock type and meta.
function cTools:SetReplaceTool(a_Tool, a_BlockType, a_BlockMeta)
	assert(type(a_Tool) ==  'number')
	assert(type(a_BlockType) ==  'number')
	assert(type(a_BlockMeta) ==  'number')
	
	self.ReplaceTool.ToHoldItem = a_Tool
	self.ReplaceTool.ToChangeBlock.m_ItemType = a_BlockType
	self.ReplaceTool.ToChangeBlock.m_ItemDamage = a_BlockMeta
end





-- Disables the ReplaceTool
function cTools:DisableReplaceTool()
	self.ReplaceTool.ToHoldItem = -1
	self.ReplaceTool.ToChangeBlock:Clear()
end





function cTools:ReplaceToolGetToChangeBlock()
	assert(self:IsReplaceToolActivated())
	
	return self.ReplaceTool.ToChangeBlock.m_ItemType, self.ReplaceTool.ToChangeBlock.m_ItemDamage
end
		