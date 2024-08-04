
-- Schematic.lua

-- Contains classes for saving and loading a clipboard depending on the requested format.





--- Default values for cubeset metadata.
local g_CubesetDefaultValues =
{
	Metadata =
	{
		CubesetFormatVersion = 1,
		IntendedUse = "SinglePieceStructures",
		["AllowedBiomes"] = "",
		["GridSizeX"] = "750",
		["GridSizeZ"] = "750",
		["MaxOffsetX"] = "100",
		["MaxOffsetZ"] = "100",
	},
	PiecesMetadata =
	{
		IsStarting = "1",
		MergeStrategy = "msSpongePrint",
		MoveToGround = "0",
		ExpandFloorStrategy = "RepeatBottomTillNonAir",
		VerticalStrategy = "TerrainOrOceanTop|-2",
		DefaultWeight = "100",
		AllowedRotations = "7",
	}
}




local g_FormatExtensionMap = {
	["mcedit"] = ".schematic",
	["cubeset"] = ".cubeset"
}




cClipboardStorage = {}





function cClipboardStorage:new(a_Obj, a_Clipboard)
	local obj = a_Obj or {}
	setmetatable(obj, cClipboardStorage)
	self.__index = self

	self.Clipboard = a_Clipboard
	return obj
end





-- Returns a sorted list containing all schematic and cubeset files in the schematics folder.
-- If there are files with the same name, but different extensions then those are shown explicitly with their extensions.
function cClipboardStorage:ListFiles()
	local dict = {}
	local files = cFile:GetFolderContents("schematics")

	local validExtensions = table.todictionary({".schematic", ".cubeset"})
	for _, file in ipairs(files) do
		local filename, extension = file:match("^(%w+)(%.%w+)$")
		if (validExtensions[extension]) then
			dict[filename] = dict[filename] or {}
			table.insert(dict[filename], {name = filename, fullname = file})
		end
	end
	local output = {}
	for fileWithoutExtension, variants in pairs(dict) do
		if (#variants == 1) then
			table.insert(output, fileWithoutExtension)
		else
			for _, variant in ipairs(variants) do
				table.insert(output, variant.fullname)
			end
		end
	end
	table.sort(output,
		function(f1, f2)
			return (string.lower(f1) < string.lower(f2))
		end
	)
	return output
end





--- Maps the requested format to the right file extension.
function cClipboardStorage:GetExtension(a_Format)
	return g_FormatExtensionMap[a_Format] or false
end





--- Returns a path for the provided file. The extension depends on the requested format.
function cClipboardStorage:FormatPath(a_FileName, a_Format)
	local Extension = ""
	if (a_Format) then
		Extension = cClipboardStorage:GetExtension(a_Format)
		if (not Extension) then
			return false, "Format not recognized."
		end
	end
	return "schematics/" .. a_FileName .. Extension
end





--- Searches for the requested file and loads it into the user's clipboard.
-- Can load mcedit files and cubeset files.
function cClipboardStorage:Load(a_FileName, a_Options)
	if (not a_FileName:match("^([%w%.]+)$")) then
		return false, "Filename must only contain letters with an extension being optional."
	end
	local foundPath, foundFormat
	for format, extension in pairs(g_FormatExtensionMap) do
		local path = cClipboardStorage:FormatPath(a_FileName, not a_FileName:endswith(extension) and format or nil)
		if (cFile:IsFile(path)) then
			foundPath = path
			foundFormat = format
			break
		end
	end

	if (not foundPath) then
		return false, "File not found."
	end

	if (foundFormat == "mcedit") then
		return self:LoadMCEdit(foundPath)
	elseif (foundFormat == "cubeset") then
		return self:LoadCubeset(foundPath, a_Options)
	end
end





--- Loads the provided file as a schematic file.
function cClipboardStorage:LoadMCEdit(a_Path)
	self.Clipboard.Area:LoadFromSchematicFile(a_Path)
	return true
end





--- Tries to load the provided file as a cubeset file.
function cClipboardStorage:LoadCubeset(a_Path, a_Options)
	local loader, err = loadfile(a_Path)
	if (not loader) then
		return false, "Unable to parse cubeset file."
	end
	local env = {}
	setfenv(loader, env)
	local success, err = pcall(loader)
	if (not success) then
		return false, "Unable to load cubeset file."
	end

	if (not env.Cubeset or not env.Cubeset.Metadata) then
		return false, "Cubeset file doesn't contain any metadata."
	end
	if (env.Cubeset.Metadata.CubesetFormatVersion == 1) then
		return self:LoadCubesetV1(env, a_Options)
	else
		return false, "Unknown Cubeset version."
	end
end





--- Loads the provided cubeset environment into the users clipboard.
function cClipboardStorage:LoadCubesetV1(a_Env, a_Options)
	local options, err = ParseOptionsToDictionary(a_Options)
	if (not options) then
		return false, err
	end
	local pieceIdx = options.pieceIdx or 1
	local piece = a_Env.Cubeset.Pieces[pieceIdx]
	if (not piece) then
		return false, "The requested piece in the Cubeset file does not exist."
	end

	-- Create a dictionary symbol -> block type/meta based on the blockdefinitions.
	local blockDefinitions = {}
	for idx, blockDefinition in ipairs(piece.BlockDefinitions) do
		local split = StringSplitAndTrim(blockDefinition, ":")
		if (#split ~= 3) then
			return false, "Block Definitions in cubeset is corrupt at definition nr. " .. idx
		end
		blockDefinitions[split[1]] = {type = split[2], meta = split[3]}
	end

	-- Set all blocks in the cubeset blockdata to a new blockarea.
	-- A new blockarea is used so the user's current clipboard isn't corrupted if something is wrong in the cubeset's blockdata.
	local area = cBlockArea()
	area:Create(piece.Size.x, piece.Size.y, piece.Size.z)
	local blockdata = table.concat(piece.BlockData)
	for y = 0, piece.Size.y - 1 do
		for z = 0, piece.Size.z - 1 do
			for x = 0, piece.Size.x - 1 do
				local index = (x + z * piece.Size.x + y * piece.Size.x * piece.Size.z) + 1 -- Lua is 1-based.
				local symbol = blockdata:sub(index, index)
				local definition = blockDefinitions[symbol]
				if (not definition) then
					return false, ('Unknown block definition "%s" at (%s, %s, %s) in cubeset file.'):format(symbol, x, y, z)
				end
				area:SetRelBlockTypeMeta(x, y, z, definition.type, definition.meta)
			end
		end
	end

	-- Move the new blockarea to the user's clipboard.
	area:CopyTo(self.Clipboard.Area)
	return true
end





function cClipboardStorage:Save(a_Name, a_Format, a_Options)
	if (not a_Name:match("^(%w+)$")) then
		return false, "Filename must only contain letters."
	end

	local Format = a_Format:lower()
	local Path, Error = self:FormatPath(a_Name, Format)
	if (not Path) then
		return false, Error
	end

	-- Check if there already is a schematic with that name, and if so if we are allowed to override it.
	if (not g_Config.Schematics.OverrideExistingFiles and cFile:IsFile(Path)) then
		return false, "There already is a schematic with that name."
	end

    if (Format == "mcedit") then
		return self:SaveMCEdit(Path)
	elseif (Format == "cubeset") then
		return self:SaveCubesetV1(Path, a_Name, a_Options)
	end
end





function cClipboardStorage:SaveMCEdit(a_FileName)
	self.Clipboard.Area:SaveToSchematicFile(a_FileName)
	return true
end





--- Parses an array of key=value strings into an array with objects containing the key and value.
-- If a name is prefixed with "piece." it's used as metadata of the piece itself, not as metadata of the cubeset file.
function cClipboardStorage:ParseOptions(a_Options)
	local output = {}
	local isXZOption = table.todictionary({"MaxOffset", "GridSize"})
	for _, option in ipairs(a_Options) do
		local optionName, value = option:match("^(.-)%=(.-)$")
		local isPieceOption, name = optionName:match("^(piece%.)(.-)$")
		name = name or optionName
		if (isXZOption[name]) then
			table.insert(output, {isPieceOption = isPieceOption ~= nil, name = name .. "X", value = value})
			table.insert(output, {isPieceOption = isPieceOption ~= nil, name = name .. "Z", value = value})
		else
			table.insert(output, {isPieceOption = isPieceOption ~= nil, name = name, value = value})
		end
	end
	return output
end





--- Saves the current clipboard into a v1 cubeset format in the provided file.
function cClipboardStorage:SaveCubesetV1(a_FileName, a_StructureName, a_Options)
	local area = self.Clipboard.Area
	local blockdata, definitions = self:GetBlockDefinitions(area)
	local output = {
		Metadata = table.merge({}, g_CubesetDefaultValues.Metadata),
		Pieces =
		{
			{
				Metadata = table.merge({}, g_CubesetDefaultValues.PiecesMetadata),
				OriginData =
				{
					ExportName = a_StructureName,
					Name = a_StructureName,
				},
				Size =
				{
					x = area:GetSizeX(),
					y = area:GetSizeY(),
					z = area:GetSizeZ(),
				},
				Hitbox =
				{
					MinX = 0,
					MinY = 0,
					MinZ = 0,
					MaxX = area:GetSizeX() - 1,
					MaxY = area:GetSizeY() - 1,
					MaxZ = area:GetSizeZ() - 1,
				},
				StructureBox =
				{
					MinX = 0,
					MinY = 0,
					MinZ = 0,
					MaxX = area:GetSizeX() - 1,
					MaxY = area:GetSizeY() - 1,
					MaxZ = area:GetSizeZ() - 1,
				},
				Connectors = {},
				BlockDefinitions =
				{
					unpack(definitions)
				},
				BlockData =
				{
					unpack(blockdata)
				}
			}
		}
	}

	-- Allow the user to override the default metadata.
	for _, option in ipairs(self:ParseOptions(a_Options)) do
		if (option.isPieceOption) then
			output.Pieces[1].Metadata[option.name] = option.value
		else
			output.Metadata[option.name] = option.value
		end
	end

	local file = io.open(a_FileName, "w")
	if (not file) then
		return false, "Could not open file"
	end
	file:write("Cubeset = \n{\n")

	-- Recursive function to dump the Lua table to the output file.
	local function write(a_Tabs, a_Obj)
		local prefix = string.rep("\t", a_Tabs)
		-- Prioritize the metadata table.
		-- Cuberite checks the first 8KiB for the Cubeset version when loading prefabs.
		-- If the file is too large and the metadata is at the end Cuberite won't be able to find it.
		if (a_Obj["Metadata"]) then
			file:write(prefix, '["Metadata"] =')
			file:write("\n", prefix, "{\n")
			write(a_Tabs + 1, a_Obj["Metadata"])
			file:write("\n", prefix, "},\n")
		end
		for k, v in pairs(a_Obj) do
			if (k ~= "Metadata") then
				if (k == "CubesetFormatVersion") then
					file:write(prefix, k, ' =')
				elseif (type(k) == "string") then
					file:write(prefix, '["', k, '"] =')
				elseif (type(k) == "number") then
					file:write(prefix, '[', k, '] =')
				end
				if (type(v) == "table") then
					file:write("\n", prefix, "{\n")
					write(a_Tabs + 1, v)
					file:write("\n", prefix, "},\n")
				elseif (type(v) == "string") then
					file:write(' "', v, '",\n')
				elseif (type(v) == "number") then
					file:write(" ", v, ",\n")
				end
			end
		end
	end
	write(1, output)
	file:write("}")
	file:close()
	return true
end





--- Parses the provided cBlockArea into an array of blockdata and an array of blockdefinitions.
function cClipboardStorage:GetBlockDefinitions(a_Area)
	local symbols = "abcdefghijklnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*,<>/?;[{]}|_-=+~"
	local currentSymbol = 1

	-- In order to be similar to the GalExport plugin air always uses '.' and sponges always use 'm'
	local definitionDictionary = {["0:0"] = ".", ["19:0"] = "m"}
	local definitions = {".:0:0", "m:19:0"}
	local blockdata = {}
	local sizeX, sizeY, sizeZ = a_Area:GetCoordRange()

	for y = 0, sizeY do
		for z = 0, sizeZ do
			local blockline = ""
			for x = 0, sizeX do
				local blocktype, blockmeta = a_Area:GetRelBlockTypeMeta(x, y, z)
				local key = blocktype .. ":" .. blockmeta
				local symbol = definitionDictionary[key]
				if (not symbol) then
					symbol = symbols:sub(currentSymbol, currentSymbol)
					currentSymbol = currentSymbol + 1
					definitionDictionary[key] = symbol
					table.insert(definitions, symbol .. ":" .. key)
				end
				blockline = blockline .. symbol
			end
			table.insert(blockdata, blockline)
		end
	end
	return blockdata, definitions
end





