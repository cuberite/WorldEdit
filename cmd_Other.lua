-------------------------------------------------
--------------------WORLDEDIT--------------------
-------------------------------------------------
function HandleWorldEditCommand(Split, Player)
	if Split[2] == nil then
		Player:SendMessage(cChatColor.Rose .. "/we <help:reload:version>")
	elseif string.upper(Split[2]) == "VERSION" or string.upper(Split[2]) == "VER" then -- check if the player wants to get the version of the plugin
		Player:SendMessage(cChatColor.LightPurple .. "This is version " .. PLUGIN:GetVersion())
	elseif string.upper(Split[2]) == "RELOAD" then -- check if the player wants to reload the plugin
		if Player:HasPermission("worldedit.reload") or Player:HasPermission("worldedit.*") then
			Player:SendMessage(cChatColor.LightPurple .. "Worldedit is reloading")
			PluginManager:DisablePlugin(PLUGIN:GetName()) -- disable the plugin
			DisablePlugin = true -- make sure the plugin loads again ;)
		end
	elseif string.upper(Split[2]) == "HELP" then -- check if the player wants to know all the commands.
		if Player:HasPermission("worldedit.help") or Player:HasPermission("worldedit.*") then
			local Commands = ""
			for Command, Information in pairs(g_PluginInfo.Commands) do
				local Split = StringSplit(Information.Command, ";")
				Commands = Commands .. cChatColor.LightPurple .. table.concat(Split, ", ") .. ", "
			end
			Player:SendMessage(string.sub(Commands, 1, string.len(Commands) - 2)) -- Remove the last ", "
		end
	else
		Player:SendMessage(cChatColor.Rose .. "/we <help:reload:version>") -- command not found
	end
	return true
end


------------------------------------------------
----------------------WAND----------------------
------------------------------------------------
function HandleWandCommand(Split, Player)
	Item = cItem(Wand, 1) -- create the cItem object
	if (Player:GetInventory():AddItem(Item)) then -- check if the player got the item
		Player:SendMessage(cChatColor.Green .. "You have a wooden axe now.")
	else
		Player:SendMessage(cChatColor.Green .. "Not enough inventory space")
	end
	return true
end


------------------------------------------------
-----------------TOGGLEEDITWAND-----------------
------------------------------------------------
function HandleToggleEditWandCommand(Split, Player)
	if not WandActivated[Player:GetName()] or WandActivated[Player:GetName()] == nil then
		WandActivated[Player:GetName()] = true
		Player:SendMessage(cChatColor.LightPurple .. "Edit wand enabled.")
	else
		WandActivated[Player:GetName()] = false
		Player:SendMessage(cChatColor.LightPurple .. "Edit wand disabled.")
	end
	return true
end




