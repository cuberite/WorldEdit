
-- cmd_schematic.lua

-- Command handlers for the "//schematic" subcommands




function HandleSchematicFormatsCommand(a_Split, a_Player)
	-- //schematic listformats

	-- We support only one format, MCEdit:
	a_Player:SendMessage(cChatColor.LightPurple .. 'Available formats: "MCEdit"')
	return true
end





function HandleSchematicListCommand(a_Split, a_Player)
	-- //schematic list

	-- Retrieve all the objects in the folder:
	local FolderContents = cFile:GetFolderContents("schematics")

	-- Filter out non-files and non-".schematic" files:
	local FileList = {}
	for idx, fnam in ipairs(FolderContents) do
		if (
			cFile:IsFile("schematics/" .. fnam) and
			fnam:match(".*%.schematic")
		) then
			table.insert(FileList, fnam:sub(1, fnam:len() - 10))  -- cut off the ".schematic" part of the name
		end
	end
	table.sort(FileList,
		function(f1, f2)
			return (string.lower(f1) < string.lower(f2))
		end
	)

	a_Player:SendMessage(cChatColor.LightPurple .. "Available schematics: " .. table.concat(FileList, ", "))
	return true
end





function HandleSchematicLoadCommand(a_Split, a_Player)
	-- //schematic load <FileName>

	-- Check the FileName parameter:
	if (#a_Split ~= 3) then
		a_Player:SendMessage(cChatColor.Rose .. "Usage: /schematic load <FileName>")
		return true
	end
	local FileName = a_Split[3]

	-- Check if the file exists:
	local Path = "schematics/" .. FileName .. ".schematic"
	if not(cFile:IsFile(Path)) then
		a_Player:SendMessage(cChatColor.Rose .. FileName .. " schematic does not exist.")
		return true
	end

	-- Load the file into clipboard:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:LoadFromSchematicFile(Path)) then
		a_Player:SendMessage(cChatColor.Rose .. FileName .. " schematic does not exist.")
		return true
	end
	a_Player:SendMessage(cChatColor.LightPurple .. FileName .. " schematic was loaded into your clipboard.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	return true
end





function HandleSchematicSaveCommand(a_Split, a_Player)
	-- //schematic save [<format>] <FileName>

	-- Get the parameters from the command arguments:
	local FileName
	if (#a_Split == 4) then
		FileName = a_Split[4]
	elseif (#a_Split == 3) then
		FileName = a_Split[3]
	else
		a_Player:SendMessage(cChatColor.Rose .. "Usage: //schematic save [<format>] <FileName>")
		return true
	end

	-- Check if there already is a schematic with that name, and if so if we are allowed to override it.
	if (not g_Config.Schematics.OverrideExistingFiles and cFile:IsFile("schematics/" .. FileName .. ".schematic")) then
		a_Player:SendMessage(cChatColor.Rose .. "There already is a schematic with that name.")
		return true
	end

	-- Check that there's data in the clipboard:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "There's no data in the clipboard. Use //copy or //cut first.")
		return true
	end

	-- Save the clipboard:
	State.Clipboard:SaveToSchematicFile("schematics/" .. FileName .. ".schematic")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard saved to " .. FileName .. ".")
	return true
end
