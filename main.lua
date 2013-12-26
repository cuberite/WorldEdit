PLUGIN = nil

function Initialize(Plugin)
	
	PLUGIN = Plugin
	PLUGIN:SetName("WorldEdit")
	PLUGIN:SetVersion(1)
		
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, SelectFirstPointHook);
	
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    SelectSecondPointHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    RightClickCompassHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    ToolsHook);
	
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,     LeftClickCompassHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,     SuperPickaxeHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_JOINED,         OnPlayerJoined);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_ANIMATION,      OnPlayerAnimation);
	
	PluginManager = cRoot:Get():GetPluginManager()
	
	LoadCommandFunctions(Plugin:GetLocalDirectory()) -- Load all the files that contains the command functions
	
	--Bind all the commands.
	
	-- Navigator commands:
	PluginManager:BindCommand("/descend",       "worldedit.navigation.descend",        HandleDescendCommand,        " Go down a floor")	
	PluginManager:BindCommand("/desc",          "worldedit.navigation.descend",        HandleDescendCommand,        "")
	PluginManager:BindCommand("/ascend",        "worldedit.navigation.ascend",         HandleAscendCommand,         " Go up a floor")
	PluginManager:BindCommand("/asc",           "worldedit.navigation.ascend",         HandleAscendCommand,         "")
	PluginManager:BindCommand("/thru",          "worldedit.navigation.thru.command",   HandleThruCommand,           " Passthrough walls")
	PluginManager:BindCommand("/jumpto",        "worldedit.navigation.jumpto.command", HandleJumpToCommand,         " Teleport to a location")
	PluginManager:BindCommand("/up",            "worldedit.navigation.up",             HandleUpCommand,             " Go upwards some distance")
	PluginManager:BindCommand("/ceil",          "worldedit.navigation.ceiling",        HandleCeilCommand,           " Go to the celing")

	-- Region commands:
	PluginManager:BindCommand("//set",	        "worldedit.region.set",                HandleSetCommand,   	       " Set all the blocks inside the selection to a block")
	PluginManager:BindCommand("//replace",      "worldedit.region.replace",            HandleReplaceCommand,        " Replace all the blocks in the selection with another")
	PluginManager:BindCommand("//walls",        "worldedit.region.walls",              HandleWallsCommand,          " Build the four sides of the selection")
	PluginManager:BindCommand("//faces",        "worldedit.region.faces",              HandleFacesCommand,          " Build the walls, ceiling, and floor of a selection")
	PluginManager:BindCommand("//setbiome",	    "worldedit.biome.set",                 HandleSetBiomeCommand,       " Set the biome of the region.")
	PluginManager:BindCommand("/biomeinfo",     "worldedit.biome.info",                HandleBiomeInfoCommand,      " Get the biome of the targeted block.")
	PluginManager:BindCommand("//size",	        "worldedit.selection.size",            HandleSizeCommand,           " Get the size of the selection")

	-- Clipboard commands:
	PluginManager:BindCommand("//rotate",       "worldedit.clipboard.rotate",          HandleRotateCommand,         " Rotate the contents of the clipboard")
	PluginManager:BindCommand("//paste",        "worldedit.clipboard.paste",	       HandlePasteCommand,          " Pastes the clipboard's contents.")
	PluginManager:BindCommand("//copy",	        "worldedit.clipboard.copy",            HandleCopyCommand,           " Copy the selection to the clipboard")
	PluginManager:BindCommand("//cut",	        "worldedit.clipboard.cut",             HandleCutCommand,            " Cut the selection to the clipboard")
	PluginManager:BindCommand("//schematic",    "",                                    HandleSchematicCommand,      " Schematic-related commands")
	
	-- History commands:
	PluginManager:BindCommand("//redo",         "worldedit.history.redo",              HandleRedoCommand,           " Redoes the last action (from history)")
	PluginManager:BindCommand("//undo",         "worldedit.history.undo",              HandleUndoCommand,           " Undoes the last action")
	
	-- Entity commands:
	PluginManager:BindCommand("/butcher",       "worldedit.butcher",                   HandleButcherCommand,        " Kills nearby mobs, based on radius, if none is given uses default in configuration.")	
	PluginManager:BindCommand("/remove",        "worldedit.remove",                    HandleRemoveCommand,         " Remove all entities of a type")
	PluginManager:BindCommand("/rem",           "worldedit.remove",                    HandleRemoveCommand,         "")
	PluginManager:BindCommand("/rement",        "worldedit.remove",                    HandleRemoveCommand,         "")

	-- Tool commands
	PluginManager:BindCommand("/toggleeditwand","worldedit.wand.toggle",               HandleToggleEditWandCommand, " Toggle functionality of the edit wand")
	PluginManager:BindCommand("/tree",          "worldedit.tool.tree",                 HandleTreeCommand,           " Tree generator tool")	
	PluginManager:BindCommand("/repl",          "worldedit.tool.replacer",             HandleReplCommand,           " Block replace tool")	
	PluginManager:BindCommand("/none",          "",                                    HandleNoneCommand,           " Unbind a bound tool from your current item")	
	PluginManager:BindCommand("//wand",	        "worldedit.wand",                      HandleWandCommand,           " Get the wand object")
	PluginManager:BindCommand("//",	            "worldedit.superpickaxe",              HandleSuperPickCommand,      " Toggle the super pickaxe pickaxe function")
	PluginManager:BindCommand("/",	            "worldedit.superpickaxe",              HandleSuperPickCommand,      "")
	PluginManager:BindCommand("//pos1",         "worldedit.selection.pos",             HandlePos1Command,            "Set position 1")
	PluginManager:BindCommand("//pos2",         "worldedit.selection.pos",             HandlePos2Command,            "Set position 2")
	
	-- Help commands:
	PluginManager:BindCommand("/biomelist",	    "worldedit.biomelist",                 HandleBiomeListCommand,      " Gets all biomes available.")
	PluginManager:BindCommand("/we",            "",                                    HandleWorldEditCommand,      " World edit command")	
	
	-- Terraforming commands:
	PluginManager:BindCommand("/removebelow",   "worldedit.removebelow",               HandleRemoveBelowCommand,    "")
	PluginManager:BindCommand("/removeabove",   "worldedit.removeabove",               HandleRemoveAboveCommand,    "")
	PluginManager:BindCommand("//removebelow",  "worldedit.removebelow",               HandleRemoveBelowCommand,    " Remove blocks below you.")
	PluginManager:BindCommand("//removeabove",  "worldedit.removeabove",               HandleRemoveAboveCommand,    " Remove blocks above your head.")
	PluginManager:BindCommand("//drain",        "worldedit.drain",                     HandleDrainCommand,          " Drain a pool")
	PluginManager:BindCommand("//ex",           "worldedit.extinguish",                HandleExtinguishCommand,     " Extinguish nearby fire.")
	PluginManager:BindCommand("//ext",          "worldedit.extinguish",                HandleExtinguishCommand,     "")
	PluginManager:BindCommand("//extinguish",   "worldedit.extinguish",                HandleExtinguishCommand,     "")
	PluginManager:BindCommand("/ex",            "worldedit.extinguish",                HandleExtinguishCommand,     "")
	PluginManager:BindCommand("/ext",           "worldedit.extinguish",                HandleExtinguishCommand,     "")
	PluginManager:BindCommand("/extinguish",    "worldedit.extinguish",                HandleExtinguishCommand,     "")
	PluginManager:BindCommand("//green",        "worldedit.green",                     HandleGreenCommand,          " Greens the area")
	PluginManager:BindCommand("/snow",	        "worldedit.snow",                      HandleSnowCommand,           " Simulates snow")
	PluginManager:BindCommand("/thaw",	        "worldedit.thaw",                      HandleThawCommand,           " Thaws the area")
	
	-- Experimental commands:
	PluginManager:BindCommand("/pumpkins",      "worldedit.generation.pumpkins",       HandlePumpkinsCommand,       "")
		
	CreateTables() -- create all the tables
	LoadOnlinePlayers() -- Load all the online players
	LoadSettings(PLUGIN:GetLocalDirectory() .. "/Config.ini") -- load all the settings
	LOG("[WorldEdit] Enabling WorldEdit v" .. PLUGIN:GetVersion())
	return true
end

function OnDisable()
	if (DisablePlugin) then -- if the plugin has to be reloaded then load the plugin again ;)
		LOGINFO("Worldedit is reloading")
		PluginManager:LoadPlugin(PLUGIN:GetName())
	else
		LOG("[WorldEdit] Disabling WorldEdit v" .. PLUGIN:GetVersion())
	end
end