-------------------------------------------------
--------------------WORLDEDIT--------------------
-------------------------------------------------
-- Sends the version of the plugin.
function HandleWorldEditVersionCommand(Split, Player)
	Player:SendMessage(cChatColor.LightPurple .. "This is version " .. PLUGIN:GetVersion())
	return true
end


-- Reloads the WorldEdit plugun.
function HandleWorldEditReloadCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "worldedit.reload") then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission to reload WorldEdit.")
		return true
	end
	Player:SendMessage(cChatColor.LightPurple .. "Worldedit is reloading")
	PluginManager:DisablePlugin(PLUGIN:GetName()) -- disable the plugin
	DisablePlugin = true -- make sure the plugin loads again ;)
	return true
end


-- Sends all the available commands to the player.
function HandleWorldEditHelpCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "worldedit.help") then
		Player:SendMessage(cChatColor.Rose .. "You do not have permission for this command.")
		return true
	end
	local Commands = ""
	for Command, Information in pairs(g_PluginInfo.Commands) do
		Commands = Commands .. cChatColor.LightPurple .. Command .. ", "
	end
	Player:SendMessage(cChatColor.LightPurple .. "Available commands:")
	Player:SendMessage(string.sub(Commands, 1, string.len(Commands) - 2)) -- Remove the last ", "
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




