PLUGIN = nil

function Initialize(Plugin)
	
	PLUGIN = Plugin
	PLUGIN:SetName(g_PluginInfo.Name)
	PLUGIN:SetVersion(g_PluginInfo.Version)
		
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, SelectFirstPointHook);
	
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    SelectSecondPointHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    RightClickCompassHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK,    ToolsHook);
	
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,     LeftClickCompassHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,     SuperPickaxeHook);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_JOINED,         OnPlayerJoined);
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_ANIMATION,      OnPlayerAnimation);
	
	cPluginManager:AddHook(cPluginManager.HOOK_PLUGIN_MESSAGE,        OnPluginMessage);
	
	--Bind all the commands:
	RegisterPluginInfoCommands();
	
	CreateTables() -- create all the tables
	LoadOnlinePlayers() -- Load all the online players
	LoadSettings(PLUGIN:GetLocalDirectory() .. "/Config.ini") -- load all the settings
	
	cFile:CreateFolder("Schematics")
	
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
