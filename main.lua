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
	
	PluginManager = cRoot:Get():GetPluginManager()
	
	LoadCommandFunctions(Plugin:GetLocalDirectory()) -- Load all the files that contains the command functions
	
	--Bind all the commands.
	dofile(PLUGIN:GetLocalFolder() .. "/Commands.lua") -- Reload the Commands file so the command handlers are initialized.
	for key, value in pairs(g_PluginInfo.Commands) do
		local Aliases = StringSplit(value.Command, ";")
		for I, k in pairs(Aliases) do
			if I == 1 then -- This is the main command. That is the only command that needs a help string.
				PluginManager:BindCommand(k, value.Permission, value.Handler, value.HelpString)
			else
				PluginManager:BindCommand(k, value.Permission, value.Handler, "")
			end
		end
	end
	
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