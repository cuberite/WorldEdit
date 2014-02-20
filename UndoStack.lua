
-- UndoStack.lua

-- Implements the cUndoStack class representing a single stack of Undo / Redo operations





cUndoStack = {}





function cUndoStack:new(a_Obj, a_MaxDepth, a_PlayerState)
	assert(a_MaxDepth ~= nil)
	assert(a_PlayerState ~= nil)
	
	-- Create the class instance:
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cUndoStack)
	self.__index = self
	
	-- Initialize the object members:
	a_Obj.MaxDepth = a_MaxDepth
	a_Obj.UndoStack = {}
	a_Obj.RedoStack = {}
	
	return a_Obj
end





--- Removes all items from the Redo stack
function cUndoStack:DropAllRedo()
	-- Clear all the areas now so that they don't keep their blocktypes in memory until GC kicks in
	for idx, redo in ipairs(self.RedoStack) do
		redo.Area:Clear()
	end
	
	self.RedoStack = {}
end





--- Pushes one level of Undo onto the Undo stack and clears the Redo stack
-- a_World is the world where the area belongs
-- a_Area is expected to have its origin set to where the Undo is located in the world
-- a_Name is the optional display name for the Undo
function cUndoStack:PushUndo(a_World, a_Area, a_Name)
	assert(a_World ~= nil)
	assert(a_Area ~= nil)
	
	-- Drop all Redo from the Redo stack (they have just been invalidated):
	self:DropAllRedo()
	
	-- Push the new Undo onto the stack:
	table.insert(self.UndoStack, {WorldName = a_World:GetName(), Area = a_Area, Name = a_Name})
	
	-- If the stack is too big, trim the oldest item:
	if (#self.UndoStack > self.MaxDepth) then
		-- Clear the area now so that it doesn't keep its blocktypes in memory until GC kicks in
		self.UndoStack[1].Area:Clear()
		table.remove(self.UndoStack, 1)
	end
end




