
-- InfoDump.lua

-- Implements the functions for dumping the g_PluginInfo into various text formats





--- Returns an array-table of all commands that are in the specified category
-- Each item is a table {Command = "/command string", Info = {<command info in PluginInfo>}}
local function GetCategoryCommands(a_CategoryName)
	local res = {};
	local function AppendCategoryCommand(a_Prefix, a_Commands)
		for cmd, info in pairs(a_Commands) do
			info.Category = info.Category or {};
			if (type(info.Category) == "string") then
				info.Category = {info.Category};
			end
			for idx, cat in ipairs(info.Category) do
				if (cat == a_CategoryName) then
					table.insert(res, {Command = a_Prefix .. cmd, Info = info});
				end
			end
			if (info.Subcommands ~= nil) then
				AppendCategory(a_Prefix .. cmd .. " ", info.Subcommands);
			end
		end
	end
	AppendCategoryCommand("", g_PluginInfo.Commands);
	return res;
end





--- Builds the g_PluginInfo.Categories' Commands arrays, if not already present.
-- The Commands array in each value is the table build by GetCategoryCommands()
local function BuildCategories()
	g_PluginInfo.Categories = g_PluginInfo.Categories or {};
	for name, desc in pairs(g_PluginInfo.Categories) do
		if (desc.Commands == nil) then
			-- The Commands array has not been built yet, calculate it now:
			desc.Commands = GetCategoryCommands(name);
		end
	end
end





function DumpPluginInfoForum()
	-- Make sure the categories have their command lists:
	BuildCategories();
	
	-- TODO
end





function DumpPluginInfoGitHub()
	-- Make sure the categories have their command lists:
	BuildCategories();
	
	-- TODO
end




