
local g_ExcludedFolders =
{
	"craftscripts",
}

-- Include all the lua files in the folders
local g_WorldEditPath = cPluginManager:GetCurrentPlugin():GetLocalFolder()
local Folders = cFile:GetFolderContents(g_WorldEditPath)
for _, Folder in ipairs(Folders) do repeat
	if ((Folder == ".") or (Folder == "..")) then
		break -- Is a continue due to a do-while directly after the for
	end
	
	local Path = g_WorldEditPath .. "/" .. Folder
	if (not cFile:IsFolder(Path)) then
		break -- Is a continue due to a do-while directly after the for
	end
	
	local IsExcludedFolder = false
	for _, ExcludedFolder in ipairs(g_ExcludedFolders) do
		if (Folder == ExcludedFolder) then
			IsExcludedFolder = true
			break
		end
	end
	
	if (IsExcludedFolder) then
		break -- Is a continue due to a do-while directly after the for
	end
	
	local FolderContents= cFile:GetFolderContents(Path)
	for _, FileName in ipairs(FolderContents) do repeat
		if (not cFile:IsFile(Path .. "/" .. FileName)) then
			break -- Is a continue due to a do-while directly after the for
		end
		
		local FileExtension = StringSplit(FileName, ".")
		FileExtension = FileExtension[#FileExtension]
		
		if (FileExtension ~= "lua") then
			break -- Is a continue due to a do-while directly after the for
		end
		
		dofile(Path .. "/" .. FileName)
	until true end
until true end





E_SELECTIONPOINT_LEFT  = 0
E_SELECTIONPOINT_RIGHT = 1

E_DIRECTION_NORTH1 = 0
E_DIRECTION_NORTH2 = 4
E_DIRECTION_EAST = 1
E_DIRECTION_SOUTH = 2
E_DIRECTION_WEST = 3

PLUGIN = nil


function Initialize(a_Plugin)
	PLUGIN = a_Plugin
	PLUGIN:SetName(g_PluginInfo.Name)
	PLUGIN:SetVersion(g_PluginInfo.Version)
	
	-- Load the InfoReg shared library:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	
	--Bind all the commands:
	RegisterPluginInfoCommands();
	
	InitializeTables() -- create all the tables
	InitializeConfiguration(a_Plugin:GetLocalFolder() .. "/config.cfg")
	
	cFile:CreateFolder("schematics")
	
	LOG("[WorldEdit] Enabling WorldEdit v" .. a_Plugin:GetVersion())
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


