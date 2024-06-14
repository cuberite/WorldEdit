
-- main.lua

-- Contains the Initialize and OnDisable functions. It also loads all the necessary files.





-- First of all load all the library expansions
dofolder(cPluginManager:Get():GetCurrentPlugin():GetLocalFolder() .. "/LibrariesExpansion")





--- All the folders that shouldn't be loaded by
g_ExcludedFolders = table.todictionary{
	"craftscripts",
	"LibrariesExpansion",
	"Tests",
	".",
	"..",
}





-- Load all the folders
local WorldEditPath = cPluginManager:GetCurrentPlugin():GetLocalFolder()
for _, Folder in ipairs(cFile:GetFolderContents(WorldEditPath)) do repeat
	local Path = WorldEditPath .. "/" .. Folder
	if (not cFile:IsFolder(Path)) then
		break -- Is a continue due to a do-while directly after the for
	end

	if (g_ExcludedFolders[Folder]) then
		break -- Is a continue due to a do-while directly after the for
	end

	dofolder(Path)
until true end





function Initialize(a_Plugin)
	a_Plugin:SetName(g_PluginInfo.Name)
	a_Plugin:SetVersion(g_PluginInfo.Version)
	
	InitializeConfiguration(a_Plugin:GetLocalFolder() .. "/config.cfg")

	-- Load the InfoReg shared library:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")

	--Bind all the commands:
	RegisterPluginInfoCommands();

	if (g_Config.Updates.CheckForUpdates) then
		cUpdater:CheckForNewerVersion()
	end

	-- Initialize SQL Storage
	cSQLStorage:Get()

	cFile:CreateFolder("schematics")

	LOG("Enabling v" .. g_PluginInfo.DisplayVersion)
	return true
end





function OnDisable()
	LOG("Disabling v" .. g_PluginInfo.DisplayVersion)
	ForEachPlayerState(
		function(a_State)
			a_State:Save(a_State:GetUUID())
		end
	)
end
