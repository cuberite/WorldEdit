
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





--- Applies a snapshot from src stack, saving the world contents into the dst stack first.
-- This performs the actual undo or redo, based on what stacks get passed in.
-- a_World is the world where the operation is performed. Only stack entries matching the world are considered.
-- Returns true if successful, false + reason if not
function cUndoStack:ApplySnapshot(a_SrcStack, a_DstStack, a_World)
	assert(type(a_SrcStack) == "table")
	assert(type(a_DstStack) == "table")
	assert(a_World ~= nil)
	
	-- Find the src snapshot to apply:
	local Src = PopLastSnapshotInWorld(a_SrcStack, a_World:GetName())
	if (Src == nil) then
		-- There's no snapshot to apply
		return false, "No snapshot to apply"
	end
	
	-- Save a snapshot to dst stack:
	local MinX = Src.Area:GetOriginX()
	local MinY = Src.Area:GetOriginY()
	local MinZ = Src.Area:GetOriginZ()
	local MaxX = MinX + Src.Area:GetSizeX()
	local MaxY = MinY + Src.Area:GetSizeY()
	local MaxZ = MinZ + Src.Area:GetSizeZ()
	BackupArea = cBlockArea()
	if not(BackupArea:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ, cBlockArea.baTypes + cBlockArea.baMetas)) then
		return false, "Cannot backup the destination"
	end
	table.insert(a_DstStack, {WorldName = Src.WorldName, Area = BackupArea, Name = Src.Name})
	
	-- Write the src snapshot:
	Src.Area:Write(a_World, MinX, MinY, MinZ)
	a_World:WakeUpSimulatorsInArea(MinX - 1, MaxX + 1, MinY - 1, MaxY + 1, MinZ - 1, MaxZ + 1)
	
	-- Clean up memory used by the snapshot:
	Src.Area:Clear()
	return true
end





--- Removes all items from the Redo stack
function cUndoStack:DropAllRedo()
	-- Clear all the areas now so that they don't keep their blocktypes in memory until GC kicks in
	for idx, redo in ipairs(self.RedoStack) do
		redo.Area:Clear()
	end
	
	self.RedoStack = {}
end





--- Returns the last snapshot that matches the worldname
-- Removes the snapshot from the stack.
-- Returns nil if no matching snapshot
function PopLastSnapshotInWorld(a_Stack, a_WorldName)
	assert(type(a_Stack) == "table")
	assert(type(a_WorldName) == "string")
	
	-- Walk the snapshots most-recent-first, check worldname:
	for idx = #a_Stack, 1, -1 do
		if (a_Stack[idx].WorldName == a_WorldName) then
			-- Found a suitable snapshot, return it and remove it from the stack:
			local res = a_Stack[idx]
			table.remove(a_Stack, idx)
			return res
		end
	end
	
	-- No matching snapshot found:
	return nil
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





--- Undoes one operation from the UndoStack (pushes previous to RedoStack)
-- Returns true if successful, false + reason if not
function cUndoStack:Undo(a_World)
	-- Apply one snapshot from UndoStack to RedoStack:
	return self:ApplySnapshot(self.UndoStack, self.RedoStack, a_World)
end




