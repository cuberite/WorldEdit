
-- Clipboard.lua

-- Implements the cClipboard clas representing a player's clipboard





--- Class for storing the player's clipboard
cClipboard = {}





function cClipboard:new(a_Obj)
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cClipboard)
	self.__index = self
	
	-- Initialize the object members:
	a_Obj.Area = cBlockArea()
	
	return a_Obj
end





--- Copies the blocks in the specified sorted cuboid into clipboard
function cClipboard:Copy(a_World, a_Cuboid, a_Offset)
	assert(tolua.type(a_World) == "cWorld")
	assert(tolua.type(a_Cuboid) == "cCuboid")
	
	local Offset = a_Offset or Vector3i()
	self.Area:Read(a_World,
		a_Cuboid.p1.x, a_Cuboid.p2.x,
		a_Cuboid.p1.y, a_Cuboid.p2.y,
		a_Cuboid.p1.z, a_Cuboid.p2.z,
		cBlockArea.baTypes + cBlockArea.baMetas
	)
	self.Area:SetWEOffset(Offset)
	
	return self.Area:GetVolume()
end





--- Cuts the blocks from the specified sorted cuboid into clipboard
-- Replaces the cuboid with air blocks
function cClipboard:Cut(a_World, a_Cuboid, a_Offset)
	self:Copy(a_World, a_Cuboid, a_Offset)
	
	-- Replace everything with air:
	local Area = cBlockArea()
	Area:Create(a_Cuboid:DifX() + 1, a_Cuboid:DifY() + 1, a_Cuboid:DifZ() + 1, cBlockArea.baTypes + cBlockArea.baMetas)
	Area:Write(a_World, a_Cuboid.p1.x, a_Cuboid.p1.y, a_Cuboid.p1.z)
	
	-- Wake up the simulators in the area:
	a_World:WakeUpSimulatorsInArea(
		a_Cuboid.p1.x - 1, a_Cuboid.p2.x + 1,
		a_Cuboid.p1.y - 1, a_Cuboid.p2.y + 1,
		a_Cuboid.p1.z - 1, a_Cuboid.p2.z + 1
	)
	
	return self.Area:GetVolume()
end





--- Returns the cuboid that holds the area which would be affected by a paste operation
function cClipboard:GetPasteDestCuboid(a_Player)
	assert(tolua.type(a_Player) == "cPlayer")
	assert(self:IsValid())
	
	-- Base the cuboid on the player position:
	local Offset = self.Area:GetWEOffset()
	local MinX = math.floor(a_Player:GetPosX()) - Offset.x
	local MinY = math.floor(a_Player:GetPosY()) - Offset.y
	local MinZ = math.floor(a_Player:GetPosZ()) - Offset.z
	local XSize, YSize, ZSize = self.Area:GetSize()
	return cCuboid(MinX, MinY, MinZ, MinX + XSize, MinY + YSize, MinZ + ZSize)
end





--- Returns a string describing the clipboard size
-- Format: "X * Y * Z (volume: N blocks)"
-- If the clipboard isn't valid, returns a placeholder text
function cClipboard:GetSizeDesc()
	if not(self:IsValid()) then
		return "no clipboard data"
	end
	
	local XSize, YSize, ZSize = self.Area:GetSize()
	local Volume = XSize * YSize * ZSize
	local Dimensions = XSize .. " * " .. YSize .. " * " .. ZSize .. " (volume: "
	if (Volume == 1) then
		return Dimensions .. "1 block)"
	else
		return Dimensions .. Volume .. " blocks)"
	end
end





--- Returns true if there's any content in the clipboard
function cClipboard:IsValid()
	return (self.Area:GetDataTypes() ~= 0)
end





--- Loads the specified schematic file into the clipboard
-- Returns true if successful, false if not
function cClipboard:LoadFromSchematicFile(a_FileName)
	return self.Area:LoadFromSchematicFile(a_FileName)
end





--- Pastes the clipboard contents into the world relative to the player
-- a_DstPoint is the optional min-coord Vector3i where to paste; if not specified, the default is used
-- Returns the number of blocks pasted
function cClipboard:Paste(a_Player, a_DstPoint, a_UseOffset)
	local World = a_Player:GetWorld()
	if (not a_UseOffset) then
		local Offset = self.Area:GetWEOffset()
		a_DstPoint = a_DstPoint - Offset
	end
	
	-- Write the area:
	self.Area:Write(World, a_DstPoint.x, a_DstPoint.y, a_DstPoint.z)
	
	-- Wake up simulators in the area:
	local XSize, YSize, ZSize = self.Area:GetSize()
	World:WakeUpSimulatorsInArea(
		a_DstPoint.x - 1, a_DstPoint.x + XSize + 1,
		a_DstPoint.y - 1, a_DstPoint.y + YSize + 1,
		a_DstPoint.z - 1, a_DstPoint.z + ZSize + 1
	)
	
	return XSize * YSize * ZSize
end





--- Rotates the clipboard around the Y axis the specified number of quarter-rotations (90 degrees)
-- Positive number of rotations turn CCW, negative number of rotations turn CW
-- Intelligent rotating - does CW instead of 3 CCW rotations etc.
-- TODO: Also rotates the player-relative offsets
function cClipboard:Rotate(a_NumCCWQuarterRotations)
	local NumRots = math.fmod(a_NumCCWQuarterRotations, 4)
	if ((NumRots == -3) or (NumRots == 1)) then
		-- 3 CW rotations = 1 CCW rotation
		self.Area:RotateCCW()
	elseif ((NumRots == -2) or (NumRots == 2)) then
		-- -2 or 2 rotations is the same, use any rotation function twice
		self.Area:RotateCCW()
		self.Area:RotateCCW()
	elseif ((NumRots == -1) or (NumRots == 3)) then
		-- 3 CCW rotation = 1 CW rotation
		self.Area:RotateCW()
	elseif (NumRots == 0) then
		-- No rotation needed
	else
		error("Bad fmod result: " .. NumRots)
	end
end





--- Saves the clipboard to the specified .schematic file
-- Assumes the clipboard is valid
-- Returns true on success, false on failure
function cClipboard:SaveToSchematicFile(a_FileName)
	assert(self:IsValid())
	
	return self.Area:SaveToSchematicFile(a_FileName)
end




