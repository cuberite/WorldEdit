
-- BlockDstClipboard.lua

-- Implements the cBlockDstClipboard class that allows doing actions using the player's clipboard
-- If used in for example //set you'll see the clipboard in a repeating pattern.





cBlockDstClipboard = {}





function cBlockDstClipboard:new(a_Player)
	local State = GetPlayerState(a_Player)
	if (not State.Clipboard:IsValid()) then
		return false, "no clipboard data"
	end
	
	local Area = State.Clipboard.Area
	local Size = Vector3i(Area:GetSize())
	
	local Obj = {}
	
	setmetatable(Obj, cBlockDstClipboard)
	self.__index = self
	
	Obj.m_Area = Area
	Obj.m_Size = Size
	
	return Obj
end





-- Returns a block from the clipboard.
function cBlockDstClipboard:Get(a_X, a_Y, a_Z)
	local PosX = math.floor(a_X % self.m_Size.x)
	local PosY = math.floor(a_Y % self.m_Size.y)
	local PosZ = math.floor(a_Z % self.m_Size.z)
	
	return self.m_Area:GetRelBlockTypeMeta(PosX, PosY, PosZ)
end



