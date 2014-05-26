local Player, Split = ...

local BlockType, BlockMeta = GetBlockTypeMeta(Split[3] or "glass")

local World = Player:GetWorld()
World:SetBlock(math.floor(Player:GetPosX()), math.floor(Player:GetPosY()) - 1, math.floor(Player:GetPosZ()), BlockType, BlockMeta)
