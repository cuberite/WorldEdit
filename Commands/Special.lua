
-- cmd_Other.lua

-- Has the commands that don't really fit in a category.





-- Complete CUI handshake
function HandleWorldEditCuiCommand(a_Split, a_Player)
	-- /we cui

	local State = GetPlayerState(a_Player)
	State.IsWECUIActivated = true
	State.Selection:NotifySelectionChanged()
	return true
end





-- Sends the version of the plugin.
function HandleWorldEditVersionCommand(a_Split, a_Player)
	-- /we version
	
	a_Player:SendMessage(cChatColor.LightPurple .. "This is version " .. cPluginManager:GetCurrentPlugin():GetVersion())
	return true
end





-- Sends all the available commands to the player.
function HandleWorldEditHelpCommand(a_Split, a_Player)
	-- /we help

	if (not a_Player:HasPermission("worldedit.help")) then
		a_Player:SendMessage(cChatColor.Rose .. "You do not have permission for this command.")
		return true
	end

	local Commands = ""
	for Command, CommandInfo in pairs(g_PluginInfo.Commands) do
		if (a_Player:HasPermission(CommandInfo.Permission)) then
			Commands = Commands .. cChatColor.LightPurple .. Command .. ", "
		end
	end

	a_Player:SendMessage(cChatColor.LightPurple .. "Available commands:")
	a_Player:SendMessage(string.sub(Commands, 1, string.len(Commands) - 2)) -- Remove the last ", "
	return true
end





-- Gives the player the wand item.
function HandleWandCommand(a_Split, a_Player)
	-- //wand

	local Item = cItem(g_Config.WandItem) -- create the cItem object
	if (a_Player:GetInventory():AddItem(Item)) then -- check if the player got the item
		a_Player:SendMessage(cChatColor.Green .. "You have received the wand.")
	else
		a_Player:SendMessage(cChatColor.Green .. "Not enough inventory space.")
	end
	return true
end





-- Toggles if the wand is active or not.
function HandleToggleEditWandCommand(a_Split, a_Player)
	-- //togglewand

	local State = GetPlayerState(a_Player)
	if not(State.WandActivated) then
		State.WandActivated = true
		a_Player:SendMessage(cChatColor.LightPurple .. "Edit wand enabled.")
	else
		State.WandActivated = false
		a_Player:SendMessage(cChatColor.LightPurple .. "Edit wand disabled.")
	end
	return true
end
