
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
				AppendCategoryCommand(a_Prefix .. cmd .. " ", info.Subcommands);
			end
		end
	end
	AppendCategoryCommand("", g_PluginInfo.Commands);
	table.sort(res,
		function (cmd1, cmd2)
			return (string.lower(cmd1.Command) < string.lower(cmd2.Command));
		end
	);
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





local function DumpCommandsForum(f)
	-- Copy all Categories from a dictionary into an array:
	local Categories = {};
	for name, cat in pairs(g_PluginInfo.Categories) do
		table.insert(Categories, {Name = name, Info = cat});
	end
	
	-- Sort the categories by name:
	table.sort(Categories,
		function(cat1, cat2)
			return (string.lower(cat1.Name) < string.lower(cat2.Name));
		end
	);
	
	-- Dump per-category commands:
	for idx, cat in ipairs(Categories) do
		f:write("\n[size=Large]", cat.Name, "[/size]\n", cat.Info.Description, "\n[list]");
		for idx2, cmd in ipairs(cat.Info.Commands) do
			f:write("Command: [b]", cmd.Command, "[/b] - ", cmd.Info.HelpString, "\n");
			if (cmd.Info.Permission ~= nil) then
				f:write("Permission required: ", cmd.Info.Permission, "\n");
			end
			if (cmd.Info.DetailedDescription ~= nil) then
				f:write(cmd.Info.DetailedDescription);
			end
			f:write("\n");
		end
		f:write("[/list]")
	end
end





function DumpPluginInfoForum()
	-- Make sure the categories have their command lists:
	BuildCategories();
	
	local f, msg = io.open(cPluginManager:GetCurrentPlugin():GetName() .. "_forum.txt", "w");
	if (f == nil) then
		LOG("Cannot dump forum info: " .. msg);
		return;
	end

	-- Write the description:
	f:write(g_PluginInfo.Description);
	
	DumpCommandsForum(f);
	
	-- TODO: Write the AdditionalInfo

	f:close();
end





function DumpPluginInfoGitHub()
	-- Make sure the categories have their command lists:
	BuildCategories();
	
	-- TODO
end




