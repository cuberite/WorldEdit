-----------------------------------------------
------------------LOADSETTINGS-----------------
-----------------------------------------------
function LoadSettings()
	SettingsIni = cIniFile( PLUGIN:GetLocalDirectory() .. "/Config.ini" )
	SettingsIni:ReadFile()
	Wand = SettingsIni:GetValueSetI("General", "WandItem", 271 )
	ButcherRadius = SettingsIni:GetValueSetI("General", "ButcherRadius", 0 )
	SettingsIni:WriteFile()
end


-----------------------------------------------
------------------CREATETABLES-----------------
-----------------------------------------------
function CreateTables()
	OnePlayerX = {}
	OnePlayerY = {}
	OnePlayerZ = {}
	TwoPlayerX = {}
	TwoPlayerY = {}
	TwoPlayerZ = {}
	LandScapeOneX = {}
	LandScapeOneY = {}
	LandScapeOneZ = {}
	LandScapeTwoX = {}
	LandScapeTwoY = {}
	LandScapeTwoZ = {}
	Blocks = {}
	PersonalBlockArea = {}
	PersonalUndo = {}
	PersonalRedo = {}
	PersonalClipboard = {}
	LastRedoCoords = {}
	LastCoords = {}
	SP = {}
	Air = {}
	X = {}
	PosX = {}
	PosY = {}
	PosZ = {}
	Z = {}
	Repl = {}
	ReplItem = {}
	Count = {}
	GrowTreeItem = {}
	RemoveAbove = {}
	WandActivated = {}
end


--------------------------------------------
------------LOADCOMMANDFUNCTIONS------------
--------------------------------------------
function LoadCommandFunctions()
	dofile( PLUGIN:GetLocalDirectory() .. "/Commands/Tools.lua" ) -- Add lua file with functions for tools commands
	dofile( PLUGIN:GetLocalDirectory() .. "/Commands/Selection.lua" ) -- Add lua file with functions for selection commands
	dofile( PLUGIN:GetLocalDirectory() .. "/Commands/functions.lua" ) -- Add lua file with helper functions
	dofile( PLUGIN:GetLocalDirectory() .. "/Commands/AlterLandscape.lua" ) -- Add lua file with functions for landscape editting commands
	dofile( PLUGIN:GetLocalDirectory() .. "/Commands/Entitys.lua" ) -- Add lua file with functions for entity commands
	dofile( PLUGIN:GetLocalDirectory() .. "/Commands/Navigation.lua" ) -- Add lua file with functions for navigation commands
	dofile( PLUGIN:GetLocalDirectory() .. "/Commands/Other.lua" ) -- Add lua file with functions for all the other commands
end


---------------------------------------------
--------------LOADONLINEPLAYERS--------------
---------------------------------------------
function LoadOnlinePlayers()
	cRoot:Get():ForEachPlayer(
	function( Player )
		PersonalBlockArea[Player:GetName()] = cBlockArea()
		PersonalUndo[Player:GetName()] = cBlockArea()
		PersonalRedo[Player:GetName()] = cBlockArea()
		PersonalClipboard[Player:GetName()] = cBlockArea()
		WandActivated[Player:GetName()] = true
	end )
end
---------------------------------------------
-------------------GETSIZE-------------------
---------------------------------------------
function GetSize( Player )
	if OnePlayerX[Player:GetName()] > TwoPlayerX[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		X = OnePlayerX[Player:GetName()] - TwoPlayerX[Player:GetName()] + 1
	else
		X = TwoPlayerX[Player:GetName()] - OnePlayerX[Player:GetName()] + 1
	end
	if OnePlayerY[Player:GetName()] > TwoPlayerY[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		Y = OnePlayerY[Player:GetName()] - TwoPlayerY[Player:GetName()] + 1
	else
		Y = TwoPlayerY[Player:GetName()] - OnePlayerY[Player:GetName()] + 1
	end
	if OnePlayerZ[Player:GetName()] > TwoPlayerZ[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		Z = OnePlayerZ[Player:GetName()] - TwoPlayerZ[Player:GetName()] + 1
	else
		Z = TwoPlayerZ[Player:GetName()] - OnePlayerZ[Player:GetName()] + 1
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
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- check if there is a region. Needed for plugins that are going to use this plugin.
		return false
	end
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	return OneX, TwoX, OneZ, TwoZ -- return the right coordinates
end


----------------------------------------------
-----------------GETXYZCOORDS-----------------
----------------------------------------------
function GetXYZCoords( Player )
	if OnePlayerX[Player:GetName()] == nil or TwoPlayerX[Player:GetName()] == nil then -- check if there is a region. Needed for plugins that are going to use this plugin.
		return false
	end
	if OnePlayerX[Player:GetName()] < TwoPlayerX[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneX = OnePlayerX[Player:GetName()]
		TwoX = TwoPlayerX[Player:GetName()]
	else
		OneX = TwoPlayerX[Player:GetName()]
		TwoX = OnePlayerX[Player:GetName()]
	end
	if OnePlayerY[Player:GetName()] < TwoPlayerY[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneY = OnePlayerY[Player:GetName()]
		TwoY = TwoPlayerY[Player:GetName()]
	else
		OneY = TwoPlayerY[Player:GetName()]
		TwoY = OnePlayerY[Player:GetName()]
	end
	if OnePlayerZ[Player:GetName()] < TwoPlayerZ[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneZ = OnePlayerZ[Player:GetName()]
		TwoZ = TwoPlayerZ[Player:GetName()]
	else
		OneZ = TwoPlayerZ[Player:GetName()]
		TwoZ = OnePlayerZ[Player:GetName()]
	end
	return OneX, TwoX, OneY, TwoY, OneZ, TwoZ -- return the right coordinates
end


----------------------------------------------
-----------------GETXYZCOORDS-----------------
----------------------------------------------
function GetLandXYZCoords( Player )
	if LandScapeOneX[Player:GetName()] == nil or LandScapeTwoX[Player:GetName()] == nil then -- check if there is a region. Needed for plugins that are going to use this plugin.
		return false
	end
	if LandScapeOneX[Player:GetName()] < LandScapeTwoX[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneX = LandScapeOneX[Player:GetName()]
		TwoX = LandScapeTwoX[Player:GetName()]
	else
		OneX = LandScapeTwoX[Player:GetName()]
		TwoX = LandScapeOneX[Player:GetName()]
	end
	if LandScapeOneY[Player:GetName()] < LandScapeTwoY[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneY = LandScapeOneY[Player:GetName()]
		TwoY = LandScapeTwoY[Player:GetName()]
	else
		OneY = LandScapeTwoY[Player:GetName()]
		TwoY = LandScapeOneY[Player:GetName()]
	end
	if LandScapeOneZ[Player:GetName()] < LandScapeTwoZ[Player:GetName()] then -- check what number is bigger becouse otherwise you can get a negative number.
		OneZ = LandScapeTwoZ[Player:GetName()]
		TwoZ = LandScapeOneZ[Player:GetName()]
	else
		OneZ = LandScapeOneZ[Player:GetName()]
		TwoZ = LandScapeTwoZ[Player:GetName()]
	end
	return OneX, TwoX, OneY, TwoY, OneZ, TwoZ -- return the right coordinates
end


----------------------------------------------
---------------GETBLOCKTYPEMETA---------------
----------------------------------------------
function GetBlockTypeMeta( Player, Blocks )
	local Tonumber = tonumber(Blocks)
	if Tonumber == nil then	
		Item = cItem()
		if StringToItem(Blocks, Item) == false then
			Player:SendMessage(cChatColor.Rose .. "unexpected character.")
			return false
		else
			return Item.m_ItemType, Item.m_ItemDamage
		end
		Block = StringSplit(Blocks, ":")		
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
