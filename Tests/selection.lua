-- selection.lua

-- These files are used with the CuberitePluginChecker script.
-- This test tests the selection and actions on the selection.
-- Usage: lua CuberitePluginChecker.lua -a AutoAPI -e ManualAPI.lua -i APIImpl/All.lua -p <WorldEditPath> -s <WorldEditPath>/selection.lua -f ^E_





scenario
{
	redirectPluginFiles
	{
		-- Redirect the default config file.
		-- This disables the update check and also works around a bug in the simulator which causes block/item enums to not be in the global environment.
		["config.cfg"] = "test.config.cfg"
	},
	world
	{
		name = "world"
	},
	initializePlugin(),
	connectPlayer
	{
		name = "TestUser"
	},
	playerCommand
	{
		playerName = "TestUser",
		command = "//pos1",
	},
	playerCommand
	{
		playerName = "TestUser",
		command = "//pos2",
	},
	playerCommand
	{
		playerName = "TestUser",
		command = "//set 0",
	},
}



