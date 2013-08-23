-----------------------------------------------
------------------LOADSETTINGS-----------------
-----------------------------------------------
function LoadSettings()
	SettingsIni = cIniFile( PLUGIN:GetLocalDirectory() .. "/Config.ini" )
	SettingsIni:ReadFile()
	Wand = ConsoleGetBlockTypeMeta(SettingsIni:GetValueSet("General", "WandItem", 271 ))
	if not Wand then
		LOGWARN("The given wand ID is not valid. Using wooden axe.")
		Wand = E_ITEM_WOODEN_AXE
	end
	ButcherRadius = SettingsIni:GetValueSetI("General", "ButcherRadius", 0 )
	SettingsIni:WriteFile()
end


-----------------------------------------------
------------------CREATETABLES-----------------
-----------------------------------------------
function CreateTables()
	OnePlayer = {}
	TwoPlayer = {}
	Blocks = {}
	PersonalBlockArea = {}
	PersonalUndo = {}
	PersonalRedo = {}
	PersonalClipboard = {}
	LastRedoCoords = {}
	LastCoords = {}
	SP = {}
	Repl = {}
	ReplItem = {}
	Count = {}
	GrowTreeItem = {}
	WandActivated = {}
	LeftClickCompassUsed = {}
end


--------------------------------------------
------------LOADCOMMANDFUNCTIONS------------
--------------------------------------------
function LoadCommandFunctions(PluginDir)
	dofile( PluginDir .. "/Commands/Tools.lua" ) -- Add lua file with functions for tools commands
	dofile( PluginDir .. "/Commands/Selection.lua" ) -- Add lua file with functions for selection commands
	dofile( PluginDir .. "/Commands/functions.lua" ) -- Add lua file with helper functions
	dofile( PluginDir .. "/Commands/AlterLandscape.lua" ) -- Add lua file with functions for landscape editting commands
	dofile( PluginDir .. "/Commands/Entitys.lua" ) -- Add lua file with functions for entity commands
	dofile( PluginDir .. "/Commands/Navigation.lua" ) -- Add lua file with functions for navigation commands
	dofile( PluginDir .. "/Commands/Other.lua" ) -- Add lua file with functions for all the other commands
end


---------------------------------------------
--------------LOADONLINEPLAYERS--------------
---------------------------------------------
function LoadOnlinePlayers()
	cRoot:Get():ForEachPlayer(
	function(Player)
		LoadPlayer(Player)
	end )
end


---------------------------------------------
-------------------GETSIZE-------------------
---------------------------------------------
function GetSize( Player )
	if OnePlayer[Player:GetName()].x > TwoPlayer[Player:GetName()].x then -- check what number is bigger becouse otherwise you can get a negative number.
		X = OnePlayer[Player:GetName()].x - TwoPlayer[Player:GetName()].x + 1
	else
		X = TwoPlayer[Player:GetName()].x - OnePlayer[Player:GetName()].x + 1
	end
	if OnePlayer[Player:GetName()].y > TwoPlayer[Player:GetName()].y then -- check what number is bigger becouse otherwise you can get a negative number.
		Y = OnePlayer[Player:GetName()].y - TwoPlayer[Player:GetName()].y + 1
	else
		Y = TwoPlayer[Player:GetName()].y - OnePlayer[Player:GetName()].y + 1
	end
	if OnePlayer[Player:GetName()].z > TwoPlayer[Player:GetName()].z then -- check what number is bigger becouse otherwise you can get a negative number.
		Z = OnePlayer[Player:GetName()].z - TwoPlayer[Player:GetName()].z + 1
	else
		Z = TwoPlayer[Player:GetName()].z - OnePlayer[Player:GetName()].z + 1
	end
	return X * Y * Z -- calculate the area.
end


---------------------------------------------
------------GET_BIOME_FROM_STRING------------
---------------------------------------------
function GetBiomeFromString( Split, Player ) -- this simply checks what the player said and then returns the network number that that biome has
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


---------------------------------------------
-----------------GETXZCOORDS-----------------
---------------------------------------------
function GetXZCoords( Player )
	if OnePlayer[Player:GetName()] == nil or TwoPlayer[Player:GetName()] == nil then -- check if there is a region. Needed for plugins that are going to use this plugin.
		return false
	end
	if OnePlayer[Player:GetName()].x < TwoPlayer[Player:GetName()].x then -- check what number is bigger becouse otherwise you can get a negative number.
		OneX = OnePlayer[Player:GetName()].x
		TwoX = TwoPlayer[Player:GetName()].x
	else
		OneX = TwoPlayer[Player:GetName()].x
		TwoX = OnePlayer[Player:GetName()].x
	end
	if OnePlayer[Player:GetName()].z < TwoPlayer[Player:GetName()].z then -- check what number is bigger becouse otherwise you can get a negative number.
		OneZ = OnePlayer[Player:GetName()].z
		TwoZ = TwoPlayer[Player:GetName()].z
	else
		OneZ = TwoPlayer[Player:GetName()].z
		TwoZ = OnePlayer[Player:GetName()].z
	end
	return OneX, TwoX, OneZ, TwoZ -- return the right coordinates
end


----------------------------------------------
-----------------GETXYZCOORDS-----------------
----------------------------------------------
function GetXYZCoords( Player )
	if OnePlayer[Player:GetName()] == nil or TwoPlayer[Player:GetName()] == nil then -- check if there is a region. Needed for plugins that are going to use this plugin.
		return false
	end
	if OnePlayer[Player:GetName()].x < TwoPlayer[Player:GetName()].x then -- check what number is bigger becouse otherwise you can get a negative number.
		OneX = OnePlayer[Player:GetName()].x
		TwoX = TwoPlayer[Player:GetName()].x
	else
		OneX = TwoPlayer[Player:GetName()].x
		TwoX = OnePlayer[Player:GetName()].x
	end
	if OnePlayer[Player:GetName()].y < TwoPlayer[Player:GetName()].y then -- check what number is bigger becouse otherwise you can get a negative number.
		OneY = OnePlayer[Player:GetName()].y
		TwoY = TwoPlayer[Player:GetName()].y
	else
		OneY = TwoPlayer[Player:GetName()].y
		TwoY = OnePlayer[Player:GetName()].y
	end
	if OnePlayer[Player:GetName()].z < TwoPlayer[Player:GetName()].z then -- check what number is bigger becouse otherwise you can get a negative number.
		OneZ = OnePlayer[Player:GetName()].z
		TwoZ = TwoPlayer[Player:GetName()].z
	else
		OneZ = TwoPlayer[Player:GetName()].z
		TwoZ = OnePlayer[Player:GetName()].z
	end
	return OneX, TwoX, OneY, TwoY, OneZ, TwoZ -- return the right coordinates
end


----------------------------------------------
---------------GETBLOCKTYPEMETA---------------
----------------------------------------------
function GetBlockTypeMeta(Player, Blocks)
	local Tonumber = tonumber(Blocks)
	if Tonumber == nil then	
		local Item = cItem()
		if StringToItem(Blocks, Item) == false then
			Player:SendMessage(cChatColor.Rose .. "unexpected character.")
			return false
		else
			return Item.m_ItemType, Item.m_ItemDamage
		end
		local Block = StringSplit(Blocks, ":")		
		if tonumber(Block[1]) == nil then
			Player:SendMessage( cChatColor.Rose .. "unexpected character." )
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
----------------LOADPLAYER------------------
--------------------------------------------
function LoadPlayer(Player)
	if PersonalBlockArea[Player:GetName()] == nil then
		PersonalBlockArea[Player:GetName()] = cBlockArea()
	end
	if PersonalUndo[Player:GetName()] == nil then
		PersonalUndo[Player:GetName()] = cBlockArea()
	end
	if PersonalRedo[Player:GetName()] == nil then
		PersonalRedo[Player:GetName()] = cBlockArea()
	end
	if PersonalClipboard[Player:GetName()] == nil then
		PersonalClipboard[Player:GetName()] = cBlockArea()
	end
	if WandActivated[Player:GetName()] == nil then
		WandActivated[Player:GetName()] = true
	end
end


--------------------------------------------
-----------GETBLOCKXYZFROMTRACE-------------
--------------------------------------------
function GetBlockXYZFromTrace(Player)
	local World = Player:GetWorld()
	local Tracer = cTracer( World )
					
	local EyePos = Vector3f(Player:GetEyePosition().x, Player:GetEyePosition().y, Player:GetEyePosition().z)
	local EyeVector = Vector3f(Player:GetLookVector().x, Player:GetLookVector().y, Player:GetLookVector().z)
	Tracer:Trace(EyePos , EyeVector, 10)
	return Tracer.BlockHitPosition.x, Tracer.BlockHitPosition.y, Tracer.BlockHitPosition.z
end