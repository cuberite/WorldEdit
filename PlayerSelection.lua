
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





--- Returns the two X coords, smaller first
function cPlayerSelection:GetXCoordsSorted()
	if (self.Cuboid.p1.x < self.Cuboid.p2.x) then
		return self.Cuboid.p1.x, self.Cuboid.p2.x
	else
		return self.Cuboid.p2.x, self.Cuboid.p1.x
	end
end





--- Returns the two Y coords, smaller first
function cPlayerSelection:GetXCoordsSorted()
	if (self.Cuboid.p1.y < self.Cuboid.p2.y) then
		return self.Cuboid.p1.y, self.Cuboid.p2.y
	else
		return self.Cuboid.p2.y, self.Cuboid.p1.y
	end
end





--- Returns the two Z coords, smaller first
function cPlayerSelection:GetZCoordsSorted()
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
function cPlayerSelection:NotifySelectionChanged()
	-- TODO: Call the registered callbacks
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
	self:NotifySelectionChanged()
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
	self:NotifySelectionChanged()
end




