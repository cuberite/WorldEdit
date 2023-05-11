
-- cmd_schematic.lua

-- Command handlers for the "//schematic" subcommands




function HandleSchematicFormatsCommand(a_Split, a_Player)
	-- //schematic listformats

	-- We support only one format, MCEdit:
	a_Player:SendMessage(cChatColor.LightPurple .. 'Available formats: "MCEdit", "Cubeset"')
	return true
end





function HandleSchematicListCommand(a_Split, a_Player)
	-- //schematic list

	local State = GetPlayerState(a_Player);
	local FileList = State.ClipboardStorage:ListFiles();

	a_Player:SendMessage(cChatColor.LightPurple .. "Available schematics: " .. table.concat(FileList, ", "))
	return true
end





function HandleSchematicLoadCommand(a_Split, a_Player)
	-- //schematic load <FileName> [options]

	-- Check the FileName parameter:
	if (#a_Split < 3) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /schematic load <FileName> [options]")
		return true
	end
	local FileName = a_Split[3]
	local Options = {unpack(a_Split, 4)}

	-- Load the file into clipboard:
	local State = GetPlayerState(a_Player)
	local success, err = State.ClipboardStorage:Load(FileName, Options);
	if (success) then
		a_Player:SendMessage(cChatColor.LightPurple .. FileName .. " schematic was loaded into your clipboard.")
		a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	else
		a_Player:SendMessage(cChatColor.Rose .. err)
	end
	return true
end





function HandleSchematicSaveCommand(a_Split, a_Player)
	-- //schematic save [<format>] <FileName>

	-- Get the parameters from the command arguments:
	local FileName
	local Format = "mcedit"
	local Options = {}
	-- ToDo: Currently it's not possible to have additional options for the mcedit format.
	if (#a_Split >= 4) then
		Format = a_Split[3]
		FileName = a_Split[4]
		Options = {unpack(a_Split, 5)}
	elseif (#a_Split == 3) then
		FileName = a_Split[3]
	else
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //schematic save [format] <FileName> [options]")
		return true
	end

	-- Check that there's data in the clipboard:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "There's no data in the clipboard. Use //copy or //cut first.")
		return true
	end

	-- Save the clipboard:
	local success, err = State.ClipboardStorage:Save(FileName, Format, Options);
	if (success) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard saved to " .. FileName .. ".")
	else
		a_Player:SendMessage(cChatColor.Rose .. err)
	end
	return true
end
