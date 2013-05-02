function Initialize(Plugin)
	
	PLUGIN = Plugin
	PLUGIN:SetName("WorldEdit")
	PLUGIN:SetVersion(0)
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_BREAKING_BLOCK)
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_RIGHT_CLICK)
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_LEFT_CLICK)
	
	PluginManager:BindCommand("/tree",          "worldedit.tool.tree",            HandleTreeCommand,           " Block replace tool" )	
	PluginManager:BindCommand("/repl",          "worldedit.tool.replacer",        HandleReplCommand,           " Block replace tool" )	
	PluginManager:BindCommand("/descend",       "worldedit.navigation.descend",   HandleDescendCommand,        " Go down a floor" )	
	PluginManager:BindCommand("/ascend",        "worldedit.navigation.ascend",    HandleAscendCommand,         " Go up a floor" )
	PluginManager:BindCommand("/butcher",       "worldedit.butcher",              HandleButcherCommand,        " Kills nearby mobs, based on radius, if none is given uses default in configuration." )	
	PluginManager:BindCommand("//green",        "worldedit.green",                HandleGreenCommand,          " [radius] - Greens the area" )	
	PluginManager:BindCommand("//size",	        "worldedit.selection.size",       HandleSizeCommand,           " Get the size of the selection")
	PluginManager:BindCommand("//paste",        "worldedit.clipboard.paste",	  HandlePasteCommand,          " Pastes the clipboard's contents.")
	PluginManager:BindCommand("//copy",	        "worldedit.clipboard.copy",       HandleCopyCommand,           " Copy the selection to the clipboard")
	PluginManager:BindCommand("//cut",	        "worldedit.clipboard.cut",        HandleCutCommand,            " Cut the selection to the clipboard")
	PluginManager:BindCommand("//schematic",    "",                               HandleSchematicCommand,      " Schematic-related commands")
	PluginManager:BindCommand("//set",	        "worldedit.region.set",           HandleSetCommand,   	       " Set all the blocks inside the selection to a block")
	PluginManager:BindCommand("//replace",      "worldedit.region.replace",       HandleReplaceCommand,        " Replace all the blocks in the selection with another")
	PluginManager:BindCommand("//walls",        "worldedit.region.walls",         HandleWallsCommand,          " Build the four sides of the selection")
	PluginManager:BindCommand("//wand",	        "worldedit.wand",                 HandleWandCommand,           " Get the wand object")
	PluginManager:BindCommand("//setbiome",	    "worldedit.biome.set",            HandleSetBiomeCommand,       " Set the biome of the region.")
	PluginManager:BindCommand("/biomelist",	    "worldedit.biomelist",            HandleBiomeListCommand,      " Gets all biomes available.")
	PluginManager:BindCommand("/snow",	        "worldedit.snow",                 HandleSnowCommand,           " Simulates snow")
	PluginManager:BindCommand("/thaw",	        "worldedit.thaw",                 HandleThawCommand,           " Thaws the area")
	PluginManager:BindCommand("//",	            "worldedit.superpickaxe",         HandleSuperPickCommand,      " Toggle the super pickaxe pickaxe function")
	PluginManager:BindCommand("/none",          "",                               HandleNoneCommand,           " Unbind a bound tool from your current item" )	

	CreateTables()
	LoadSettings()
	BlockArea = cBlockArea()
	LOG("Initialized " .. PLUGIN:GetName() .. " v" .. PLUGIN:GetVersion())
	return true
end

function OnDisable()
	LOG( PLUGIN:GetName() .. " v" .. PLUGIN:GetVersion() .. " is shutting down..." )
end