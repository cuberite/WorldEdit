
-- ToolRegistrator.lua

-- Implements the cToolRegistrator class representing the tools used by a player.





cToolRegistrator = {}





function cToolRegistrator:new(a_Obj)
	-- Create the class instance:
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cToolRegistrator)
	self.__index = self
	
	-- Initialize the object members:
	a_Obj.Tools = {}
	a_Obj.Masks = {}
	
	return a_Obj
end





-- Get the blocks from the mask on this item. If the item hasn't a mask, it returns nil.
function cToolRegistrator:GetMask(a_ItemType)
	if (self.Masks[a_ItemType] == nil) then
		return nil
	end

	return self.Masks[a_ItemType]
end





-- Binds a mask to a given item. Returns true on success and returns false + errormessage when it fails.
function cToolRegistrator:BindMask(a_ItemType, a_Blocks)
	if (not ItemCategory.IsTool(a_ItemType)) then
		return false, "Can't bind tool to \"" .. ItemToString(cItem(a_ItemType)) .. "\": Only tools can be used."
	end

	self.Masks[a_ItemType] = a_Blocks
	return true
end





function cToolRegistrator:UnbindMask(a_ItemType)
	if (self.Masks[a_ItemType] == nil) then
		return false, "The item didn't have any masks bound on it."
	end

	self.Masks[a_ItemType] = nil
	return true
end





-- Binds an callback to a given item. Returns true on succes and returns false + errormessage when it fails.
function cToolRegistrator:BindTool(a_ItemType, a_UsageCallback)
	if (not ItemCategory.IsTool(a_ItemType)) then
		return false, "Can't bind tool to \"" .. ItemToString(cItem(a_ItemType)) .. "\": Only tools can be used."
	end
	
	self.Tools[a_ItemType] = a_UsageCallback
	return true
end





-- Unbinds a tool from it's callback. Returns true on succes and returns false + errormessage when it fails.
function cToolRegistrator:UnbindTool(a_ItemType)
	if (self.Tools[a_ItemType] == nil) then
		return false, "The item didn't have any tools bound to it."
	end
	
	self.Tools[a_ItemType] = nil
	return true
end





-- Uses the tool. Returns false when it fails. Else it returns what the callback returns.
function cToolRegistrator:UseTool(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_ItemType)
	if (self.Tools[a_ItemType] == nil) then
		return false
	end
	
	-- Let the handler decide if the callback from MCServer should return true or false.
	return self.Tools[a_ItemType](a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
end





