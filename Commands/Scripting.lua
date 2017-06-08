
-- Scripting.lua

-- Contains command handlers that are in the Scripting category.





-- Loads and executes a craftscript
function HandleCraftScriptCommand(a_Split, a_Player)
	-- /cs <scriptname>

	local PlayerState = GetPlayerState(a_Player)

	if (not a_Split[2]) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /cs <scriptname>")
		return true
	end

	local Succes, Err = PlayerState.CraftScript:SelectScript(a_Split[2])
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. Err)
		return true
	end

	local Arguments = a_Split
	table.remove(Arguments, 1); table.remove(Arguments, 1)

	local Succes, Err = PlayerState.CraftScript:Execute(a_Player, Arguments)
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. Err)
		return true
	end

	a_Player:SendMessage(cChatColor.LightPurple .. "Script executed.")
	return true
end





-- Executes the last used craftscript.
function HandleLastCraftScriptCommand(a_Split, a_Player)
	-- /.s

	local PlayerState = GetPlayerState(a_Player)

	local Arguments = a_Split
	table.remove(Arguments, 1)

	local Succes, Err = PlayerState.CraftScript:Execute(a_Player, Arguments)
	if (not Succes) then
		a_Player:SendMessage(cChatColor.Rose .. Err)
		return true
	end

	a_Player:SendMessage(cChatColor.Rose .. "Script Executed")
	return true
end
