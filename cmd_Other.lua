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





function HandleWandCommand(Split, Player)
	-- //wand
	Item = cItem(Wand, 1) -- create the cItem object
	if (Player:GetInventory():AddItem(Item)) then -- check if the player got the item
		Player:SendMessageSuccess("You have received the wand.")
	else
		Player:SendMessageFailure("Not enough inventory space.")
	end
	return true
end





function HandleToggleEditWandCommand(a_Split, a_Player)
	-- //togglewand
	
	local State = GetPlayerState(a_Player)
	if not(State.WandActivated) then
		State.WandActivated = true
		a_Player:SendMessageSuccess("Edit wand enabled.")
	else
		State.WandActivated = false
		a_Player:SendMessageSuccess("Edit wand disabled.")
	end
	return true
end




