function Initialize(Plugin)
	
	PLUGIN = Plugin
	PLUGIN:SetName("WorldEdit")
	PLUGIN:SetVersion(0.1)
	
	PluginManager = cRoot:Get():GetPluginManager()
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_BREAKING_BLOCK) -- Add hook OnPlayerBreakingBlock
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_RIGHT_CLICK) -- Add hook OnPlayerRightClick
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_LEFT_CLICK) -- Add hook OnPlayerLeftClick
	PluginManager:AddHook(PLUGIN, cPluginManager.HOOK_PLAYER_JOINED) -- Add hook OnPlayerJoined
	
	LoadCommandFunctions() -- Load all the files that contains the command functions
	
	--Bind all the commands.
	PluginManager:BindCommand("/biomeinfo",     "worldedit.biome.info",              HandleBiomeInfoCommand,      " Get the biome of the targeted block." )
	PluginManager:BindCommand("/toggleeditwand","worldedit.wand.toggle",             HandleToggleEditWandCommand, " Toggle functionality of the edit wand" )
	PluginManager:BindCommand("//redo",         "worldedit.history.redo",            HandleRedoCommand,           " Redoes the last action (from history)" )
	PluginManager:BindCommand("//undo",         "worldedit.history.undo",            HandleUndoCommand,           " Undoes the last action" )
	PluginManager:BindCommand("/remove",        "worldedit.remove",                  HandleRemoveCommand,         " Remove all entities of a type" )
	PluginManager:BindCommand("/removebelow",   "worldedit.removebelow",             HandleRemoveBelowCommand,    "" )
	PluginManager:BindCommand("/removeabove",   "worldedit.removeabove",             HandleRemoveAboveCommand,    "" )
	PluginManager:BindCommand("//removebelow",  "worldedit.removebelow",             HandleRemoveBelowCommand,    " Remove blocks below you." )
	PluginManager:BindCommand("//removeabove",  "worldedit.removeabove",             HandleRemoveAboveCommand,    " Remove blocks above your head." )
	PluginManager:BindCommand("/we",            "",                                  HandleWorldEditCommand,      " World edit command" )	
	PluginManager:BindCommand("//drain",        "worldedit.drain",                   HandleDrainCommand,          " Drain a pool" )
	PluginManager:BindCommand("//rotate",       "worldedit.clipboard.rotate",        HandleRotateCommand,         " Rotate the contents of the clipboard" )
	PluginManager:BindCommand("//ex",           "worldedit.extinguish",              HandleExtinguishCommand,     " Extinguish nearby fire." )
	PluginManager:BindCommand("//ext",          "worldedit.extinguish",              HandleExtinguishCommand,     "" )
	PluginManager:BindCommand("//extinguish",   "worldedit.extinguish",              HandleExtinguishCommand,     "" )
	PluginManager:BindCommand("/ex",            "worldedit.extinguish",              HandleExtinguishCommand,     "" )
	PluginManager:BindCommand("/ext",           "worldedit.extinguish",              HandleExtinguishCommand,     "" )
	PluginManager:BindCommand("/extinguish",    "worldedit.extinguish",              HandleExtinguishCommand,     "" )
	PluginManager:BindCommand("/tree",          "worldedit.tool.tree",               HandleTreeCommand,           " Tree generator tool" )	
	PluginManager:BindCommand("/repl",          "worldedit.tool.replacer",           HandleReplCommand,           " Block replace tool" )	
	PluginManager:BindCommand("/descend",       "worldedit.navigation.descend",      HandleDescendCommand,        " Go down a floor" )	
	PluginManager:BindCommand("/desc",          "worldedit.navigation.descend",      HandleDescendCommand,        "" )	
	PluginManager:BindCommand("/ascend",        "worldedit.navigation.ascend",       HandleAscendCommand,         " Go up a floor" )	
	PluginManager:BindCommand("/asc",           "worldedit.navigation.ascend",       HandleAscendCommand,         "" )
	PluginManager:BindCommand("/butcher",       "worldedit.butcher",                 HandleButcherCommand,        " Kills nearby mobs, based on radius, if none is given uses default in configuration." )	
	PluginManager:BindCommand("//green",        "worldedit.green",                   HandleGreenCommand,          " Greens the area" )
	PluginManager:BindCommand("//size",	        "worldedit.selection.size",          HandleSizeCommand,           " Get the size of the selection")
	PluginManager:BindCommand("//paste",        "worldedit.clipboard.paste",	     HandlePasteCommand,          " Pastes the clipboard's contents.")
	PluginManager:BindCommand("//copy",	        "worldedit.clipboard.copy",          HandleCopyCommand,           " Copy the selection to the clipboard")
	PluginManager:BindCommand("//cut",	        "worldedit.clipboard.cut",           HandleCutCommand,            " Cut the selection to the clipboard")
	PluginManager:BindCommand("//schematic",    "",                                  HandleSchematicCommand,      " Schematic-related commands")
	PluginManager:BindCommand("//set",	        "worldedit.region.set",              HandleSetCommand,   	       " Set all the blocks inside the selection to a block")
	PluginManager:BindCommand("//replace",      "worldedit.region.replace",          HandleReplaceCommand,        " Replace all the blocks in the selection with another")
	PluginManager:BindCommand("//walls",        "worldedit.region.walls",            HandleWallsCommand,          " Build the four sides of the selection")
	PluginManager:BindCommand("//faces",        "worldedit.region.faces",            HandleFacesCommand,          " Build the walls, ceiling, and floor of a selection")
	PluginManager:BindCommand("//wand",	        "worldedit.wand",                    HandleWandCommand,           " Get the wand object")
	PluginManager:BindCommand("//setbiome",	    "worldedit.biome.set",               HandleSetBiomeCommand,       " Set the biome of the region.")
	PluginManager:BindCommand("/biomelist",	    "worldedit.biomelist",               HandleBiomeListCommand,      " Gets all biomes available.")
	PluginManager:BindCommand("/snow",	        "worldedit.snow",                    HandleSnowCommand,           " Simulates snow")
	PluginManager:BindCommand("/thaw",	        "worldedit.thaw",                    HandleThawCommand,           " Thaws the area")
	PluginManager:BindCommand("//",	            "worldedit.superpickaxe",            HandleSuperPickCommand,      " Toggle the super pickaxe pickaxe function")
	PluginManager:BindCommand("/",	            "worldedit.superpickaxe",            HandleSuperPickCommand,      "")
	PluginManager:BindCommand("/none",          "",                                  HandleNoneCommand,           " Unbind a bound tool from your current item")	
	PluginManager:BindCommand("/thru",          "worldedit.navigation.thru.command", HandleThruCommand,           " Passthrough walls")
	
	--Experimental commands:
	PluginManager:BindCommand("/pumpkins",      "worldedit.generation.pumpkins",     HandlePumpkinsCommand,       "")
		
	CreateTables() -- create all the tables
	LoadOnlinePlayers() -- Load all the online players
	LoadSettings() -- load all the settings
	BlockArea = cBlockArea()
	LOG("[WorldEdit] Enabling WorldEdit v" .. PLUGIN:GetVersion())
	return true
end

function OnDisable()
	if (DisablePlugin) then -- if the plugin has to be reloaded then load the plugin again ;)
		LOGINFO( "Worldedit is reloading" )
		PluginManager:LoadPlugin( PLUGIN:GetName() )
	else
		LOG( "[WorldEdit] Disabling WorldEdit v" .. PLUGIN:GetVersion() )
	end
end