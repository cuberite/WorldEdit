
-- InfoReg.lua

-- Implements registration functions that use g_PluginInfo




--- Registers all commands specified in the g_PluginInfo.Commands
function RegisterPluginInfoCommands()
	-- A sub-function that registers all subcommands of a single command, using the command's Subcommands table
	-- The a_Prefix param already contains the space after the previous command
	local function RegisterSubcommands(a_Prefix, a_Subcommands)
		assert(a_Subcommands ~= nil);
		
		for cmd, info in pairs(a_Subcommands) do
			local CmdName = a_Prefix .. cmd;
			if (info.Handler == nil) then
				LOGWARNING(g_PluginInfo.Name .. ": Invalid handler for command " .. CmdName .. ", command will not be registered.");
			else
				cPluginManager.BindCommand(cmd, info.Permission or "", info.Handler, info.HelpString or "");
				-- Register all aliases for the command:
				if (info.Alias ~= nil) then
					if (type(info.Alias) == "string") then
						info.Alias = {info.Alias};
					end
					for idx, alias in ipairs(info.Alias) do
						cPluginManager.BindCommand(a_Prefix .. alias, info.Permission or "", info.Handler, info.HelpString or "");
					end
				end
			end
			-- Recursively register any subcommands:
			if (info.Subcommands ~= nil) then
				RegisterSubcommands(a_Prefix .. cmd .. " ", info.Subcommands);
			end
		end
	end
	
	-- Loop through all commands in the plugin info, register each:
	RegisterSubcommands("", g_PluginInfo.Commands);
end





--- Registers all console commands specified in the g_PluginInfo.ConsoleCommands
function RegisterPluginInfoConsoleCommands()
	-- A sub-function that registers all subcommands of a single command, using the command's Subcommands table
	-- The a_Prefix param already contains the space after the previous command
	local function RegisterSubcommands(a_Prefix, a_Subcommands)
		assert(a_Subcommands ~= nil);
		
		for cmd, info in pairs(a_Subcommands) do
			local CmdName = a_Prefix .. cmd;
			cPluginManager.BindConsoleCommand(cmd, info.Handler, info.HelpString or "");
			-- Recursively register any subcommands:
			if (info.Subcommands ~= nil) then
				RegisterSubcommands(a_Prefix .. cmd .. " ", info.Subcommands);
			end
		end
	end
	
	-- Loop through all commands in the plugin info, register each:
	RegisterSubcommands("", g_PluginInfo.ConsoleCommands);
end




