
-- PlayerSelection.lua

-- Implements the cPlayerSelection class representing a selection for a single player





--- Class for storing the player's selection
cPlayerSelection = {}





--- Creates a new instance of the class
function cPlayerSelection:new(a_Obj, a_PlayerState)
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cPlayerSelection)
	self.__index = self
	
	-- Initialize the object members:
	a_Obj.Cuboid = cCuboid()
	a_Obj.IsFirstPointSet = false
	a_Obj.IsSecondPointSet = false
	a_Obj.PlayerState = a_PlayerState
	a_Obj.OnChangeCallbacks = {}
	
	return a_Obj
end





-- Expands the selection in each direction by the specified amount of blocks
function cPlayerSelection:Expand(a_SubMinX, a_SubMinY, a_SubMinZ, a_AddMaxX, a_AddMaxY, a_AddMaxZ)
	-- Check the params:
	assert(a_SubMinX ~= nil)
	assert(a_SubMinY ~= nil)
	assert(a_SubMinZ ~= nil)
	assert(a_AddMaxX ~= nil)
	assert(a_AddMaxY ~= nil)
	assert(a_AddMaxZ ~= nil)
	
	if (self.Cuboid.p1.x < self.Cuboid.p2.x) then
		self.Cuboid.p1.x = self.Cuboid.p1.x - a_SubMinX
	else
		self.Cuboid.p2.x = self.Cuboid.p2.x - a_SubMinX
	end
	
	if (self.Cuboid.p1.y < self.Cuboid.p2.y) then
		self.Cuboid.p1.y = self.Cuboid.p1.y - a_SubMinY
	else
		self.Cuboid.p2.y = self.Cuboid.p2.y - a_SubMinY
	end
	
	if (self.Cuboid.p1.z < self.Cuboid.p2.z) then
		self.Cuboid.p1.z = self.Cuboid.p1.z - a_SubMinZ
	else
		self.Cuboid.p2.z = self.Cuboid.p2.z - a_SubMinZ
	end
	
	if (self.Cuboid.p1.x > self.Cuboid.p2.x) then
		self.Cuboid.p1.x = self.Cuboid.p1.x + a_AddMaxX
	else
		self.Cuboid.p2.x = self.Cuboid.p2.x + a_AddMaxX
	end
	
	if (self.Cuboid.p1.y > self.Cuboid.p2.y) then
		self.Cuboid.p1.y = self.Cuboid.p1.y + a_AddMaxY
	else
		self.Cuboid.p2.y = self.Cuboid.p2.y + a_AddMaxY
	end
	
	if (self.Cuboid.p1.z > self.Cuboid.p2.z) then
		self.Cuboid.p1.z = self.Cuboid.p1.z + a_AddMaxZ
	else
		self.Cuboid.p2.z = self.Cuboid.p2.z + a_AddMaxZ
	end

	self:NotifySelectionChanged() -- Notify the changes to the client.
end





--- Returns the absolute differences in each coord, as three numbers
function cPlayerSelection:GetCoordDiffs()
	assert(self:IsValid())

	local DifX = self.Cuboid.p2.x - self.Cuboid.p1.x
	local DifY = self.Cuboid.p2.y - self.Cuboid.p1.y
	local DifZ = self.Cuboid.p2.z - self.Cuboid.p1.z
	if (DifX < 0) then
		DifX = -DifX
	end
	if (DifY < 0) then
		DifY = -DifY
	end
	if (DifZ < 0) then
		DifZ = -DifZ
	end
	return DifX, DifY, DifZ
end





--- Returns the smaller of each coord-pair
function cPlayerSelection:GetMinCoords()
	local MinX, MinY, MinZ
	if (self.Cuboid.p1.x < self.Cuboid.p2.x) then
		MinX = self.Cuboid.p1.x
	else
		MinX = self.Cuboid.p2.x
	end
	if (self.Cuboid.p1.y < self.Cuboid.p2.y) then
		MinX = self.Cuboid.p1.y
	else
		MinX = self.Cuboid.p2.y
	end
	if (self.Cuboid.p1.z < self.Cuboid.p2.z) then
		MinX = self.Cuboid.p1.z
	else
		MinX = self.Cuboid.p2.z
	end
	return MinX, MinY, MinZ
end





--- Returns a string describing the selection size ("X * Y * Z, volume V blocks")
function cPlayerSelection:GetSizeDesc()
	assert(self:IsValid())
	
	local DifX, DifY, DifZ = self:GetCoordDiffs()
	DifX = DifX + 1
	DifY = DifY + 1
	DifZ = DifZ + 1
	local Volume = DifX * DifY * DifZ
	local Dimensions = tostring(DifX) .. " * " .. DifY .. " * " .. DifZ
	if (Volume == 1) then
		return Dimensions .. ", volume 1 block"
	else
		return Dimensions .. ", volume " .. Volume .. " blocks"
	end
end





--- Returns a new cuboid with the selection's bounds, sorted
function cPlayerSelection:GetSortedCuboid()
	assert(self:IsValid())
	
	local SCuboid = cCuboid(self.Cuboid)
	SCuboid:Sort()
	return SCuboid;
end





--- Returns the 3D volume of the selection
function cPlayerSelection:GetVolume()
	assert(self:IsValid())
	
	local Volume = self.Cuboid.p2.x - self.Cuboid.p1.x
	Volume = Volume * (self.Cuboid.p2.y - self.Cuboid.p1.y)
	Volume = Volume * (self.Cuboid.p2.z - self.Cuboid.p1.z)
	if (Volume < 0) then
		return -Volume
	end
	return Volume
end





--- Returns the two X coords, smaller first
function cPlayerSelection:GetXCoordsSorted()
	assert(self:IsValid())
	
	if (self.Cuboid.p1.x < self.Cuboid.p2.x) then
		return self.Cuboid.p1.x, self.Cuboid.p2.x
	else
		return self.Cuboid.p2.x, self.Cuboid.p1.x
	end
end





--- Returns the two Y coords, smaller first
function cPlayerSelection:GetYCoordsSorted()
	assert(self:IsValid())
	
	if (self.Cuboid.p1.y < self.Cuboid.p2.y) then
		return self.Cuboid.p1.y, self.Cuboid.p2.y
	else
		return self.Cuboid.p2.y, self.Cuboid.p1.y
	end
end





--- Returns the two Z coords, smaller first
function cPlayerSelection:GetZCoordsSorted()
	assert(self:IsValid())
	
	if (self.Cuboid.p1.z < self.Cuboid.p2.z) then
		return self.Cuboid.p1.z, self.Cuboid.p2.z
	else
		return self.Cuboid.p2.z, self.Cuboid.p1.z
	end
end





--- Returns true if the selection is valid - both points are set
function cPlayerSelection:IsValid()
	return (self.IsFirstPointSet and self.IsSecondPointSet)
end





--- Notifies all registered callbacks that the selection has changed
-- a_PointChanged is optional, assigned to the point that has just changed
-- If nil, the entire selection is assumed changed
function cPlayerSelection:NotifySelectionChanged(a_PointChanged)
	-- TODO: Call the registered callbacks
	
	-- Set the player's WECUI, if present:
	if (self.PlayerState.IsWECUIActivated) then
		local Volume = -1
		if (self:IsValid()) then
			Volume = self:GetVolume()
		end
		local c = self.Cuboid
		if (self.IsFirstPointSet and ((a_PointChanged == nil) or (a_PointChanged == 1))) then
			self.PlayerState:DoWithPlayer(
				function(a_Player)
					a_Player:GetClientHandle():SendPluginMessage("WECUI", string.format(
						"p|0|%i|%i|%i|%i",
						c.p1.x, c.p1.y, c.p1.z, Volume
					))
				end
			)
		end
		if (self.IsSecondPointSet and ((a_PointChanged == nil) or (a_PointChanged == 2))) then
			self.PlayerState:DoWithPlayer(
				function(a_Player)
					a_Player:GetClientHandle():SendPluginMessage("WECUI", string.format(
						"p|1|%i|%i|%i|%i",
						c.p2.x, c.p2.y, c.p2.z, Volume
					))
				end
			)
		end
	end
end





--- Moves the entire cuboid to the given Offset
function cPlayerSelection:Move(a_OffsetX, a_OffsetY, a_OffsetZ)
	-- Check the parameters
	assert(a_OffsetX ~= nil)
	assert(a_OffsetY ~= nil)
	assert(a_OffsetZ ~= nil)
	
	-- Move the cuboid
	self.Cuboid:Move(a_OffsetX, a_OffsetY, a_OffsetZ)

	-- Notify the client
	self:NotifySelectionChanged()
end





--- Sets the first point in the selection
function cPlayerSelection:SetFirstPoint(a_BlockX, a_BlockY, a_BlockZ)
	-- Check the params:
	local BlockX = tonumber(a_BlockX)
	local BlockY = tonumber(a_BlockY)
	local BlockZ = tonumber(a_BlockZ)
	assert(BlockX ~= nil)
	assert(BlockY ~= nil)
	assert(BlockZ ~= nil)
	
	-- Set the point:
	self.Cuboid.p1:Set(BlockX, BlockY, BlockZ)
	self.IsFirstPointSet = true
	self:NotifySelectionChanged(1)
end





--- Sets the second point in the selection
function cPlayerSelection:SetSecondPoint(a_BlockX, a_BlockY, a_BlockZ)
	-- Check the params:
	local BlockX = tonumber(a_BlockX)
	local BlockY = tonumber(a_BlockY)
	local BlockZ = tonumber(a_BlockZ)
	assert(BlockX ~= nil)
	assert(BlockY ~= nil)
	assert(BlockZ ~= nil)
	
	-- Set the point:
	self.Cuboid.p2:Set(BlockX, BlockY, BlockZ)
	self.IsSecondPointSet = true
	self:NotifySelectionChanged(2)
end





--- Common code to set selection position based on player clicking somewhere
function cPlayerSelection:SetPos(a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_PosName, a_ForceSet)
	-- Check if a valid click:
	if (a_BlockFace == BLOCK_FACE_NONE) then
		return false
	end
	
	-- Check the wand activation state:
	if (not self.PlayerState.WandActivated and not a_ForceSet) then
		return false
	end
	
	local Abort = false
	self.PlayerState:DoWithPlayer(
		function(a_Player)
			-- Check the WE permission:
			if not(a_Player:HasPermission("worldedit.selection.pos")) then
				Abort = true
				return true
			end
			
			-- When shift is pressed, use the air block instead of the clicked block:
			if (a_Player:IsCrouched()) then
				a_BlockX, a_BlockY, a_BlockZ = AddFaceDirection(a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
			end
		end
	)
	
	-- The callback decided to abort.
	if (Abort) then
		return false
	end
	
	-- Determine what point we're trying to set and get the proper set function for it.
	local SetFunc = (a_PosName == "First") and cPlayerSelection.SetFirstPoint or cPlayerSelection.SetSecondPoint
	
	-- Set the position in the internal representation:
	SetFunc(self, a_BlockX, a_BlockY, a_BlockZ)
	
	-- Return a success message:
	return true, cChatColor.LightPurple .. a_PosName .. " position set to {" .. a_BlockX .. ", " .. a_BlockY .. ", " .. a_BlockZ .. "}."
end




