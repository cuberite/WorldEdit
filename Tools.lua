
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





function cTools:SetGrowTreeTool(a_ItemType)
	assert(type(a_ItemType) == 'number')
	
	self.GrowTreeTool = a_ItemType
end