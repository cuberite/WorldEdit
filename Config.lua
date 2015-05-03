
-- Config.lua

-- Contains the functions to initialize and write the configuration file.





g_Config = {}





local g_ConfigDefault =
[[
WandItem = woodenaxe,
Limits =
{
	ButcherRadius = -1,
	MaxBrushRadius = 5,
},

Defaults =
{
	ButcherRadius = 20,
},

NavigationWand =
{
	Item = compass,
	MaxDistance = 120,
	TeleportNoHit = true,
},
]]





-- Writes the default configuration to a_Path
local function WriteDefaultConfiguration(a_Path)
	LOGWARNING("[WorldEdit] Default configuration written to \"" .. a_Path .. "\"")
	local File = io.open(a_Path, "w")
	File:write(g_ConfigDefault)
	File:close()
end





-- Returns the default configuration table. This can be directly used in g_Config
local function GetDefaultConfigurationTable()
	return loadstring("return {" .. g_ConfigDefault .. "}")()
end





-- Sets g_Config to the default configuration
local function LoadDefaultConfiguration()
	LOGWARNING("[WorldEdit] The default configuration will be used.")
	g_Config = GetDefaultConfigurationTable()
end





-- Finds from an error message where the error occurred.
local function FindErrorPosition(a_ErrorMessage)
	local ErrorPosition = a_ErrorMessage:match(":(.-):") or 0
	return ErrorPosition
end





-- Loads the configuration from the given path. If it doesn't exist, or if there is an error in the config file it will load the defaults.
function InitializeConfiguration(a_Path)
	local ConfigContent = cFile:ReadWholeFile(a_Path)
	
	-- The configuration file doesn't exist or is empty. Write and load the default value
	if (ConfigContent == "") then
		WriteDefaultConfiguration(a_Path)
		LoadDefaultConfiguration()
		return
	end
	
	-- Load the content of the config file. Place brackets around it to make the whole thing a table.
	-- Also, return the table when executed
	local ConfigLoader, Error = loadstring("return {" .. ConfigContent .. "}")
	if (not ConfigLoader) then
		local ErrorPosition = FindErrorPosition(Error)
		LOGWARNING("[WorldEdit] Error in the configuration file near line " .. ErrorPosition)
		LoadDefaultConfiguration()
		return
	end
	
	-- Create an environment for the loader where the admin can use item names directly without quotes.
	local LoaderEnv = {}
	for Key, Value in pairs(_G) do
		if (Key:match("E_.*")) then
			LoaderEnv[ItemTypeToString(Value)] = Value
		end
	end
	
	-- Apply the environment to the configloader.
	setfenv(ConfigLoader, LoaderEnv)
	
	-- Execute the loader. It returns true + the configuration if it executed properly. Else it returns false with the error message.
	local Succes, Result = pcall(ConfigLoader)
	if (not Succes) then
		local ErrorPosition = FindErrorPosition(Result)
		LOGWARNING("[WorldEdit] Error in the configuration file at line " .. ErrorPosition)
		LoadDefaultConfiguration()
		return
	end
	
	-- Merge the configuration with the default configuration. 
	-- When the admin missed something in the configuration it will be set to the default value.
	local DefaultConfig = GetDefaultConfigurationTable()
	table.merge(Result, DefaultConfig)
	
	-- Set the g_Config table.
	g_Config = Result
end



