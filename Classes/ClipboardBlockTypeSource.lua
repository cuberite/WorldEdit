
-- BlockDstClipboard.lua

-- Implements the cClipboardBlockTypeSource class that allows doing actions using the player's clipboard
-- If used in for example //set you'll see the clipboard in a repeating pattern.





cClipboardBlockTypeSource = {}





function cClipboardBlockTypeSource:new(a_Player)
	local State = GetPlayerState(a_Player)
	if (not State.Clipboard:IsValid()) then
		return false, "no clipboard data"
	end

	local Area = State.Clipboard.Area
	local Size = Vector3i(Area:GetSize())

	local Obj = {}

	setmetatable(Obj, cClipboardBlockTypeSource)
	self.__index = self

	Obj.m_Area = Area
	Obj.m_Size = Size

	return Obj
end





-- Returns a block from the clipboard.
function cClipboardBlockTypeSource:Get(a_X, a_Y, a_Z)
	local PosX = math.floor(a_X % self.m_Size.x)
	local PosY = math.floor(a_Y % self.m_Size.y)
	local PosZ = math.floor(a_Z % self.m_Size.z)

	return self.m_Area:GetRelBlockTypeMeta(PosX, PosY, PosZ)
end





-- Returns true if one of the blocks in the given table is in the clipboard.
function cClipboardBlockTypeSource:Contains(a_BlockTypeList)
	local SizeX, SizeY, SizeZ = self.m_Area:GetCoordRange()

	for X = 0, SizeX do
		for Y = 0, SizeY do
			for Z = 0, SizeZ do
				local BlockType = self.m_Area:GetRelBlockType(X, Y, Z)
				if (a_BlockTypeList[BlockType]) then
					return true, BlockType
				end
			end
		end
	end

	return false
end
