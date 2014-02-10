-------------------------------------------------
--------------------WORLDEDIT--------------------
-------------------------------------------------
-- Sends the version of the plugin.
function HandleWorldEditVersionCommand(Split, Player)
	Player:SendMessageInfo("This is WorldEdit version " .. PLUGIN:GetVersion())
	return true
end


-- Reloads the WorldEdit plugun.
function HandleWorldEditReloadCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "worldedit.reload") then
		Player:SendMessageFailure("You do not have permission to reload WorldEdit.")
		return true
	end
	Player:SendMessageWarning("Worldedit is reloading...")
	cRoot:Get():GetPluginManager():DisablePlugin(PLUGIN:GetName()) -- disable the plugin
	DisablePlugin = true -- make sure the plugin loads again ;)
	return true
end


-- Sends all the available commands to the player.
function HandleWorldEditHelpCommand(Split, Player)
	if not PlayerHasWEPermission(Player, "core.help") then
		Player:SendMessageFailure("You do not have permission to view help.")
		return true
	end
	local Commands = ""
	for Command, Information in pairs(g_PluginInfo.Commands) do
		Commands = Commands .. cChatColor.LightPurple .. Command .. ", "
	end
	Player:SendMessageInfo("Available commands:")
	Player:SendMessage(string.sub(Commands, 1, string.len(Commands) - 2)) -- Remove the last ", "
	return true
end


------------------------------------------------
----------------------WAND----------------------
------------------------------------------------
function HandleWandCommand(Split, Player)
	Item = cItem(Wand, 1) -- create the cItem object
	if (Player:GetInventory():AddItem(Item)) then -- check if the player got the item
		Player:SendMessageSuccess("Wooden axe acquired!")
	else
		Player:SendMessageFailure("Not enough inventory space!")
	end
	return true
end


------------------------------------------------
-----------------TOGGLEEDITWAND-----------------
------------------------------------------------
function HandleToggleEditWandCommand(Split, Player)
	if not WandActivated[Player:GetName()] or WandActivated[Player:GetName()] == nil then
		WandActivated[Player:GetName()] = true
		Player:SendMessageSuccess("Edit wand enabled.")
	else
		WandActivated[Player:GetName()] = false
		Player:SendMessageSuccess("Edit wand disabled.")
	end
	return true
end




