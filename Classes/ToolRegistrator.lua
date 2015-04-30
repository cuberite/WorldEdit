
-- ToolRegistrator.lua

-- Implements the cToolRegistrator class representing the tools used by a player.





cToolRegistrator = {}





function cToolRegistrator:new(a_Obj)
	-- Create the class instance:
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cToolRegistrator)
	self.__index = self
	
	-- Initialize the object members:
	a_Obj.RightClickTools = {}
	a_Obj.LeftClickTools  = {}
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
-- If an array is given then the function will loop through it calling itself with the itemtypes in the array. The returned error will be a table with errors.
-- The callback is called when the player right clicks with the tool in hand.
-- The toolname is the name of the tool
function cToolRegistrator:BindRightClickTool(a_ItemType, a_UsageCallback, a_ToolName)
	if (type(a_ItemType) == "table") then
		local Succes, Error = nil, {}
		for Idx, ItemType in ipairs(a_ItemType) do
			local Suc, Err = self:BindRightClickTool(ItemType, a_UsageCallback, a_ToolName)
			Succes = Succes and Suc, not Suc and table.insert(Error, Err)
		end
		
		return Succes, Error
	end
	
	if (not ItemCategory.IsTool(a_ItemType)) then
		return false, "Can't bind tool to \"" .. ItemTypeToString(a_ItemType) .. "\": Only tools can be used."
	end
	
	self.RightClickTools[a_ItemType] = {Callback = a_UsageCallback, ToolName = a_ToolName}
	return true
end





-- Uses the right click tool. Returns false when it fails. Else it returns what the callback returns.
function cToolRegistrator:UseRightClickTool(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_ItemType)
	if (self.RightClickTools[a_ItemType] == nil) then
		return false
	end
	
	-- Let the handler decide if the callback from MCServer should return true or false.
	return self.RightClickTools[a_ItemType].Callback(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
end





-- Returns the info about a left click registered tool. This is a table with the callback, and the name of the tool. If there was no tool for the item type it returns false
function cToolRegistrator:GetRightClickCallbackInfo(a_ItemType)
	return self.RightClickTools[a_ItemType] or false
end





-- Binds an callback to a given item. Returns true on succes and returns false + errormessage when it fails.
-- If an array is given then the function will loop through it calling itself with the itemtypes in the array. The returned error will be a table with errors.
-- The callback is called when the player left clicks with the tool in hand.
-- The toolname is the name of the tool
function cToolRegistrator:BindLeftClickTool(a_ItemType, a_UsageCallback, a_ToolName)
	if (type(a_ItemType) == "table") then
		local Succes, Error = nil, {}
		for Idx, ItemType in ipairs(a_ItemType) do
			local Suc, Err = self:BindLeftClickTool(ItemType, a_UsageCallback, a_ToolName)
			Succes = Succes and Suc, not Suc and table.insert(Error, Err)
		end
		
		return Succes, Error
	end
	
	if (not ItemCategory.IsTool(a_ItemType)) then
		return false, "Can't bind tool to \"" .. ItemTypeToString(a_ItemType) .. "\": Only tools can be used."
	end
	
	self.LeftClickTools[a_ItemType] = {Callback = a_UsageCallback, ToolName = a_ToolName}
	return true
end





-- Uses the left click tool. Returns false when it fails. Else it returns what the callback returns.
function cToolRegistrator:UseLeftClickTool(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_ItemType)
	if (self.LeftClickTools[a_ItemType] == nil) then
		return false
	end
	
	return self.LeftClickTools[a_ItemType].Callback(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
end





-- Returns the info about a left click registered tool. This is a table with the callback, and the name of the tool. If there was no tool for the item type it returns false
function cToolRegistrator:GetLeftClickCallbackInfo(a_ItemType)
	return self.LeftClickTools[a_ItemType] or false
end





-- Unbinds a tool from it's callback. Returns true on succes and returns false + errormessage when it fails.
-- The itemtype can also be an array with itemtypes. If this is the case then the function will loop through the array and call itself with the itemtypes in the array.
-- The result will in that case be a boolean + an array with errors.
-- a_ToolName is a string or nil. If it's a string then the tool will only be unbound if the current tool is a_ToolName
function cToolRegistrator:UnbindTool(a_ItemType, a_ToolName)
	if (type(a_ItemType) == "table") then
		local Succes, Errors = nil, {}
		for Idx, ItemType in ipairs(a_ItemType) do
			local Suc, Err = self:UnbindTool(ItemType, a_ToolName)
			Succes = Succes and Suc, not Suc and table.insert(Errors, Err)
		end
		
		return Succes, Errors
	end
	
	if ((self.RightClickTools[a_ItemType] == nil) and (self.LeftClickTools[a_ItemType] == nil)) then
		return false, "The item didn't have any tools bound to it."
	end
	
	if (a_ToolName) then
		if ((self.RightClickTools[a_ItemType] or {}).ToolName == a_ToolName) then
			self.RightClickTools[a_ItemType] = nil
		end
		if ((self.LeftClickTools[a_ItemType] or {}).ToolName == a_ToolName) then
			self.LeftClickTools[a_ItemType] = nil
		end
		
		return true
	end
	
	self.LeftClickTools[a_ItemType] = nil
	self.RightClickTools[a_ItemType] = nil
	return true
end





