
-- functions.lua

-- Contains global functions.





-- Loads all the settings.
function LoadSettings(a_Path)
	SettingsIni = cIniFile()
	SettingsIni:ReadFile(a_Path)
	Wand = GetBlockTypeMeta(SettingsIni:GetValueSet("General", "WandItem", 271))
	if (not Wand) then
		LOGWARN("The given wand ID is not valid. Using wooden axe.")
		Wand = E_ITEM_WOODEN_AXE
	end
	ButcherRadius = SettingsIni:GetValueSetI("General", "ButcherRadius", 0)
	SettingsIni:WriteFile(a_Path)
end





-- Creates tables used to manage players actions or plugins
function CreateTables()
	SP = {}
	LeftClickCompassUsed = {}
	ExclusionAreaPlugins = {}
	PlayerSelectPointHooks = {}
	cRoot:Get():ForEachWorld(
		function(World)
			ExclusionAreaPlugins[World:GetName()] = {}
		end
	)
end





-- Returns the block type (and block meta) from a string. This can be something like "1", "1:0", "stone" and "stone:0"
function GetBlockTypeMeta(a_BlockString)
	local BlockID = tonumber(a_BlockString)
	
	-- Check if it was a normal number
	if (BlockID) then
		return BlockID, 0, true
	end
	
	-- Check if it was a name.
	local Item = cItem()
	if (not StringToItem(a_BlockString, Item)) then
		return false
	else
		return Item.m_ItemType, Item.m_ItemDamage
	end
	
	-- Check if it was an BlockType + Meta
	local Block = StringSplit(a_BlockString, ":")		
	if (not tonumber(Block[1])) then
		return false
	else
		if (not Block[2]) then
			return Block[1], 0
		else
			return Block[1], Block[2]
		end
	end
end





-- Rounds the number.
function Round(a_GivenNumber)
	assert(type(a_GivenNumber) == 'number')
	
	local Number, Decimal = math.modf(a_GivenNumber)
	if Decimal >= 0.5 then
		return math.ceil(a_GivenNumber)
	else
		return Number
	end
end





--- Returns a table of chunk coords for all chunks that insersect the given cuboid
-- The table is formatted for cWorld:ChunkStay():
-- { {Chunk1X, Chunk1z}, {Chunk2x, Chunk2z}, ... }
-- Assumes that the cuboid is sorted
function ListChunksForCuboid(a_Cuboid)
	-- Check the params:
	assert(tolua.type(a_Cuboid) == "cCuboid")
	
	-- Get the min / max chunk coords:
	local MinChunkX = math.floor(a_Cuboid.p1.x / 16)
	local MinChunkZ = math.floor(a_Cuboid.p1.z / 16)
	local MaxChunkX = math.floor((a_Cuboid.p2.x + 15.5) / 16)
	local MaxChunkZ = math.floor((a_Cuboid.p2.z + 15.5) / 16)
	
	-- Create the coords table:
	local res = {}
	local idx = 1
	for x = MinChunkX, MaxChunkX do for z = MinChunkZ, MaxChunkZ do
		res[idx] = {x, z}
		idx = idx + 1
	end end
	
	return res
end




