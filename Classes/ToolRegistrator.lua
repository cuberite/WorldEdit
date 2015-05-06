
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
	
	-- Bind the tools like navigation.
	a_Obj:BindAbsoluteTools()
	
	return a_Obj
end





function cToolRegistrator:BindAbsoluteTools()
	local function RightClickCompassCallback(a_Player, _, _, _, a_BlockFace)
		-- The player can't use the navigation tool because he doesn't have permission use it.
		if (not a_Player:HasPermission("worldedit.navigation.thru.tool")) then
			return false
		end
		
		if (a_BlockFace ~= BLOCK_FACE_NONE) then
			return true
		end
		
		RightClickCompass(a_Player)
		return true
	end
	
	local LastLeftClick = -math.huge
	local function LeftClickCompassCallback(a_Player, _, _, _, a_BlockFace)
		-- The player can't use the navigation tool because he doesn't have permission use it.
		if (not a_Player:HasPermission("worldedit.navigation.jumpto.tool")) then
			return false
		end
		
		if (a_BlockFace ~= BLOCK_FACE_NONE) then
			return true
		end
		
		if ((os.clock() - LastLeftClick) < 0.20) then
			return true
		end
		
		LastLeftClick = os.clock()
		LeftClickCompass(a_Player)
		return true
	end
	
	local function OnPlayerRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		local Succ, Message = GetPlayerState(a_Player).Selection:SetPos(a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, "Second")
		if (not Succ) then
			return false
		end
		
		a_Player:SendMessage(Message)
		return true
	end
		
	local function OnPlayerLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
		local Succ, Message = GetPlayerState(a_Player).Selection:SetPos(a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, "First")
		if (not Succ) then
			return false
		end
		
		a_Player:SendMessage(Message)
		return true
	end
	
	self:BindRightClickTool(g_Config.NavigationWand.Item, RightClickCompassCallback, "thru tool", true)
	self:BindRightClickTool(g_Config.WandItem,            OnPlayerRightClick, "selection", true)
	self:BindLeftClickTool(g_Config.NavigationWand.Item,  LeftClickCompassCallback, "jumpto tool", true)
	self:BindLeftClickTool(g_Config.WandItem,             OnPlayerLeftClick, "selection", true)
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
-- IsAbsolute is a bool value. If false no other tool can bind that tool, and UnbindTool won't unbind it.
function cToolRegistrator:BindRightClickTool(a_ItemType, a_UsageCallback, a_ToolName, a_IsAbsolute)
	if (type(a_ItemType) == "table") then
		local Succes, Error = nil, {}
		for Idx, ItemType in ipairs(a_ItemType) do
			local Suc, Err = self:BindRightClickTool(ItemType, a_UsageCallback, a_ToolName)
			Succes = Succes and Suc, not Suc and table.insert(Error, Err)
		end
		
		return Succes, Error
	end
	
	if ((self.RightClickTools[a_ItemType] ~= nil) and self.RightClickTools[a_ItemType].IsAbsolute) then
		return false, "Can't bind tool to \"" .. ItemTypeToString(a_ItemType) .. "\": Already used for the " .. self.RightClickTools[a_ItemType].ToolName
	end
	
	self.RightClickTools[a_ItemType] = {Callback = a_UsageCallback, ToolName = a_ToolName, IsAbsolute = a_IsAbsolute}
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
-- IsAbsolute is a bool value. If false no other tool can bind that tool, and UnbindTool won't unbind it.
function cToolRegistrator:BindLeftClickTool(a_ItemType, a_UsageCallback, a_ToolName, a_IsAbsolute)
	if (type(a_ItemType) == "table") then
		local Succes, Error = nil, {}
		for Idx, ItemType in ipairs(a_ItemType) do
			local Suc, Err = self:BindLeftClickTool(ItemType, a_UsageCallback, a_ToolName)
			Succes = Succes and Suc, not Suc and table.insert(Error, Err)
		end
		
		return Succes, Error
	end
	
	if ((self.LeftClickTools[a_ItemType] ~= nil) and self.LeftClickTools[a_ItemType].IsAbsolute) then
		return false, "Can't bind tool to \"" .. ItemTypeToString(a_ItemType) .. "\": Already used for the " .. self.LeftClickTools[a_ItemType].ToolName
	end
	
	self.LeftClickTools[a_ItemType] = {Callback = a_UsageCallback, ToolName = a_ToolName, IsAbsolute = a_IsAbsolute}
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
	
	-- Only unbind the tool if it isn't absolute
	if ((self.LeftClickTools[a_ItemType] ~= nil) and (not self.LeftClickTools[a_ItemType].IsAbsolute)) then
		self.LeftClickTools[a_ItemType] = nil
	end
	
	if ((self.RightClickTools[a_ItemType] ~= nil) and (not self.RightClickTools[a_ItemType].IsAbsolute)) then
		self.RightClickTools[a_ItemType] = nil
	end
	return true
end





local function RightClickToolsHook(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
	local State = GetPlayerState(a_Player)
	
	return State.ToolRegistrator:UseRightClickTool(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Player:GetEquippedItem().m_ItemType)
end





local function LeftClickToolsHook(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
	if (a_Action ~= 0) then
		-- Left click is also called for other things like throwing items
		return false
	end
	
	local State = GetPlayerState(a_Player)
	return State.ToolRegistrator:UseLeftClickTool(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Player:GetEquippedItem().m_ItemType)
end





local function LeftClickToolsAnimationHook(a_Player, a_Animation)
	-- In 1.8.x the left click has a value of 0, while in 1.7.x it's 1
	local LeftClickAnimation = (a_Player:GetClientHandle():GetProtocolVersion() > 5) and 0 or 1
	if (a_Animation ~= LeftClickAnimation) then
		return false
	end
	
	local State = GetPlayerState(a_Player)
	return State.ToolRegistrator:UseLeftClickTool(a_Player, 0, 0, 0, BLOCK_FACE_NONE, a_Player:GetEquippedItem().m_ItemType)
end





-- Register the hooks needed:
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, RightClickToolsHook);
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,  LeftClickToolsHook);
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_ANIMATION,   LeftClickToolsAnimationHook);


