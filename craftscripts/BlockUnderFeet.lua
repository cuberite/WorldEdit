local Player, Split = ...
local BlockType, BlockMeta = GetBlockTypeMeta(Split[1] or "glass")

if (not BlockType) then
	a_Player:SendMessage(cChatColor.Rose .. "Unknown block given.")
	return
end

local World = Player:GetWorld()
World:SetBlock(math.floor(Player:GetPosX()), math.floor(Player:GetPosY()) - 1, math.floor(Player:GetPosZ()), BlockType, BlockMeta)
