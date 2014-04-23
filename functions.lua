-----------------------------------------------
------------------LOADSETTINGS-----------------
-----------------------------------------------
function LoadSettings(Path)
	SettingsIni = cIniFile()
	SettingsIni:ReadFile(Path)
	Wand = ConsoleGetBlockTypeMeta(SettingsIni:GetValueSet("General", "WandItem", 271))
	if not Wand then
		LOGWARN("The given wand ID is not valid. Using wooden axe.")
		Wand = E_ITEM_WOODEN_AXE
	end
	ButcherRadius = SettingsIni:GetValueSetI("General", "ButcherRadius", 0)
	SettingsIni:WriteFile(Path)
end


-----------------------------------------------
------------------CREATETABLES-----------------
-----------------------------------------------
function CreateTables()
	SP = {}
	Repl = {}
	ReplItem = {}
	GrowTreeItem = {}
	LeftClickCompassUsed = {}
	ExclusionAreaPlugins = {}
	PlayerSelectPointHooks = {}
	cRoot:Get():ForEachWorld(function(World)
		ExclusionAreaPlugins[World:GetName()] = {}
	end)
end





---------------------------------------------
------------GET_BIOME_FROM_STRING------------
---------------------------------------------
function GetBiomeFromString(Split, Player) -- this simply checks what the player said and then returns the network number that that biome has
	Split[2] = string.upper(Split[2])
	if Split[2] == "OCEAN" then
		return 0
	elseif Split[2] == "PLAINS" then
		return 1
	elseif Split[2] == "DESERT" then
		return 2
	elseif Split[2] == "EXTEME_HILLS" then
		return 3
	elseif Split[2] == "FOREST" then
		return 4
	elseif Split[2] == "TAIGA" then
		return 5
	elseif Split[2] == "SWAMPLAND" then
		return 6
	elseif Split[2] == "RIVER" then
		return 7
	elseif Split[2] == "HELL" then
		return 8
	elseif Split[2] == "SKY" then
		return 9
	elseif Split[2] == "FROZENOCEAN" then
		return 10
	elseif Split[2] == "FROZENRIVER" then
		return 11
	elseif Split[2] == "ICE_PLAINS" then
		return 12
	elseif Split[2] == "ICE_MOUNTAINS" then
		return 13
	elseif Split[2] == "MUSHROOMISLAND" then
		return 14
	elseif Split[2] == "MUSHROOMISLANDSHORE" then
		return 15
	elseif Split[2] == "BEACH" then
		return 16
	elseif Split[2] == "DESERTHILLS" then
		return 17
	elseif Split[2] == "FORESTHILLS" then
		return 18
	elseif Split[2] == "TAIGAHILLS" then
		return 19
	elseif Split[2] == "EXTEME_HILLS_EDGE" then
		return 20
	elseif Split[2] == "JUNGLE" then
		return 21
	elseif Split[2] == "JUNGLEHILLS" then
		return 22
	else
		return false
	end
end





----------------------------------------------
---------------GETBLOCKTYPEMETA---------------
----------------------------------------------
function GetBlockTypeMeta(Blocks)
	local Tonumber = tonumber(Blocks)
	if Tonumber == nil then	
		local Item = cItem()
		if StringToItem(Blocks, Item) == false then
			return false
		else
			return Item.m_ItemType, Item.m_ItemDamage
		end
		local Block = StringSplit(Blocks, ":")		
		if tonumber(Block[1]) == nil then
			return false
		else
			if Block[2] == nil then
				return Block[1], 0
			else
				return Block[1], Block[2]
			end
		end
	else
		return Tonumber, 0, true
	end
end


-----------------------------------------------
------------CONSOLEGETBLOCKTYPEMETA------------
-----------------------------------------------
function ConsoleGetBlockTypeMeta(Blocks)
	local Tonumber = tonumber(Blocks)
	if Tonumber == nil then	
		local Item = cItem()
		if StringToItem(Blocks, Item) == false then
			return false
		else
			return Item.m_ItemType, Item.m_ItemDamage
		end
		local Block = StringSplit(Blocks, ":")		
		if tonumber(Block[1]) == nil then
			return false
		else
			if Block[2] == nil then
				return Block[1], 0
			else
				return Block[1], Block[2]
			end
		end
	else
		return Tonumber, 0, true
	end
end
----------------------------------------------
--------------GETSTRINGFROMBIOME--------------
----------------------------------------------
function GetStringFromBiome(Biome)
	if Biome == 0 then
		return "ocean"
	elseif Biome == 1 then
		return "plains"
	elseif Biome == 2 then
		return "desert"
	elseif Biome == 3 then
		return "extreme hills"
	elseif Biome == 4 then
		return "forest"
	elseif Biome == 5 then
		return "taiga"
	elseif Biome == 6 then
		return "swampland"
	elseif Biome == 7 then
		return "river"
	elseif Biome == 8 then
		return "hell"
	elseif Biome == 9 then
		return "sky"
	elseif Biome == 10 then
		return "frozen ocean"
	elseif Biome == 11 then
		return "frozen river"
	elseif Biome == 12 then
		return "ice plains"
	elseif Biome == 13 then
		return "ice mountains"
	elseif Biome == 14 then
		return "mushroom island"
	elseif Biome == 15 then
		return "mushroom island shore"
	elseif Biome == 16 then
		return "beach"
	elseif Biome == 17 then
		return "desert hills"
	elseif Biome == 18 then
		return "forest hills"
	elseif Biome == 19 then
		return "taiga hills"
	elseif Biome == 20 then
		return "extreme hills edge"
	elseif Biome == 21 then
		return "jungle"
	elseif Biome == 22 then
		return "jungle hills"
	elseif Biome == 23 then
		return "jungle edge"
	elseif Biome == 24 then
		return "deep ocean"
	elseif Biome == 25 then
		return "stone beach"
	elseif Biome == 26 then
		return "cold beach"
	elseif Biome == 27 then
		return "birch forest"
	elseif Biome == 28 then
		return "birch forest hills"
	elseif Biome == 29 then
		return "roofed forest"
	elseif Biome == 30 then
		return "cold taiga"
	elseif Biome == 31 then
		return "cold taiga hills"
	elseif Biome == 32 then
		return "mega taiga"
	elseif Biome == 33 then
		return "mega taiga hills"
	elseif Biome == 34 then
		return "extreme hills+"
	elseif Biome == 35 then
		return "savanna"
	elseif Biome == 36 then
		return "savanna plateau"
	elseif Biome == 37 then
		return "mesa"
	elseif Biome == 38 then
		return "mesa plateau f"
	elseif Biome == 39 then
		return "mesa plateau"
	end
end


---------------------------------------------
----------------TABLECONTAINS----------------
---------------------------------------------
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end




--------------------------------------------
-----------GETBLOCKXYZFROMTRACE-------------
--------------------------------------------
function GetBlockXYZFromTrace(Player)
	local World = Player:GetWorld()
	local Tracer = cTracer(World)
					
	local EyePos = Vector3f(Player:GetEyePosition().x, Player:GetEyePosition().y, Player:GetEyePosition().z)
	local EyeVector = Vector3f(Player:GetLookVector().x, Player:GetLookVector().y, Player:GetLookVector().z)
	Tracer:Trace(EyePos , EyeVector, 10)
	return Tracer.BlockHitPosition.x, Tracer.BlockHitPosition.y, Tracer.BlockHitPosition.z
end


-----------------------------------------
----------PLAYERHASWEPERMISSION----------
-----------------------------------------
function PlayerHasWEPermission(Player, ...)
	local arg = {...}
	if Player:HasPermission("worldedit.*") then
		return true
	end
	for Idx, Permission in ipairs(arg) do
		if Player:HasPermission(Permission) then
			return true
		end
	end
	return false
end




-----------------------------------------------
---------------------ROUND---------------------
-----------------------------------------------
function Round(GivenNumber)
	assert(type(GivenNumber) == 'number')
	local Number, Decimal = math.modf(GivenNumber)
	if Decimal >= 0.5 then
		return math.ceil(GivenNumber)
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
	assert(tolua.type(a_Cuboid) == "a_Cuboid")
	
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




