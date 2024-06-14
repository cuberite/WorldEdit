
-- Info.lua

-- Implements the g_PluginInfo standard plugin description

g_PluginInfo =
{
	Name = "WorldEdit",
	Version = 19,
	DisplayVersion = "0.1.18",
	Date = "2023-05-18", -- yyyy-mm-dd
	SourceLocation = "https://github.com/cuberite/WorldEdit",
	Description = [[This plugin allows you to easily manage the world, edit the world, navigate around or get information. It bears similarity to the Bukkit's WorldEdit plugin and aims to have the same set of commands,however, it has no affiliation to that plugin.
	]],
	Commands =
	{
---------------------------------------------------------------------------------------------------
-- double-slash commands:

		["//"] =
		{
			Alias = "/",
			Permission = "worldedit.superpickaxe",
			Handler = HandleSuperPickCommand,
			HelpString = "Toggle the super pickaxe pickaxe function",
			Category = "Tool",
		},

		["//addleaves"] =
		{
			Alias = "/addleaves",
			Permission = "worldedit.region.addleaves",
			Handler = HandleAddLeavesCommand,
			HelpString = "Adds leaves next to log blocks",
			Category = "Region",
		},

		["//chunk"] =
		{
			Permission = "worldedit.selection.chunk",
			Handler = HandleChunkCommand,
			HelpString = "Select the chunk you are currently in",
			Category = "Selection",
		},

		["//count"] =
		{
			Permission = "worldedit.selection.count",
			Handler = HandleCountCommand,
			HelpString = "Count the number of blocks in the region",
			Category = "Selection",
		},

		["//contract"] =
		{
			Permission = "worldedit.selection.contract",
			Handler = HandleExpandContractCommand,
			HelpString = "Contract the selection area",
			Category = "Selection",
		},

		["//copy"] =
		{
			Permission = "worldedit.clipboard.copy",
			Handler = HandleCopyCommand,
			HelpString = "Copy the selection to the clipboard",
			Category = "Clipboard",
		},

		["//cut"] =
		{
			Permission = "worldedit.clipboard.cut",
			Handler = HandleCutCommand,
			HelpString = "Cut the selection to the clipboard",
			Category = "Clipboard",
		},

		["//cyl"] =
		{
			Permission = "worldedit.generation.cylinder",
			Handler = HandleCylCommand,
			HelpString = "Generates a cylinder",
			Category = "Generation",
		},

		["//deselect"] =
		{
			Alias = "//desel",
			Permission = "worldedit.selection.deselect",
			Handler = HandleDeselectCommand,
			HelpString = "Deselect the current selection",
			Category = "Selection",
		},

		["//distr"] =
		{
			Permission = "worldedit.selection.distr",
			Handler = HandleDistrCommand,
			HelpString = "Inspect the block distribution of the current selection",
			Category = "Selection",
		},

		["//drain"] =
		{
			Permission = "worldedit.drain",
			Handler = HandleDrainCommand,
			HelpString = "Drains all water around you in the given radius",
			Category = "Terraforming",
		},

		["//ellipsoid"] =
		{
			Permission = "worldedit.region.ellipsoid",
			Handler = HandleEllipsoidCommand,
			HelpString = "Creates an ellipsoid in the selected region",
			Category = "Region",
		},

		["//expand"] =
		{
			Permission = "worldedit.selection.expand",
			Handler = HandleExpandContractCommand,
			HelpString = "Expand the selection area",
			Category = "Selection",
		},

		["//extinguish"] =
		{
			Alias = { "//ex", "//ext", "/ex", "/ext", "/extinguish", },
			Permission = "worldedit.extinguish",
			Handler = HandleExtinguishCommand,
			HelpString = "Removes all the fires around you in the given radius",
			Category = "Terraforming",
		},

		["//faces"] =
		{
			Alias = "//outline",
			Permission = "worldedit.region.faces",
			Handler = HandleFacesCommand,
			HelpString = " Build the walls, ceiling, and floor of a selection",
			Category = "Region",
		},

		["//fillr"] =
		{
			Permission = "worldedit.fill.recursive",
			Handler = HandleFillrCommand,
			HelpString = "Fill a hole recursively",
			Category = "Terraforming"
		},

		["//fill"] =
		{
			Permission = "worldedit.fill",
			Handler = HandleFillCommand,
			HelpString = "Fill a hole",
			Category = "Terraforming",
		},

		["//generate"] =
		{
			Alias = {"//g", "//gen"},
			Permission = "worldedit.generation.shape",
			Handler = HandleGenerationShapeCommand,
			HelpString = "Generates a shape according to a formula",
			Category = "Generation",
		},

		["//green"] =
		{
			Alias = "/green",
			Permission = "worldedit.green",
			Handler = HandleGreenCommand,
			HelpString = " Changes all the dirt to grass",
			Category = "Terraforming",
		},

		["//hcyl"] =
		{
			Permission = "worldedit.selection.cylinder",
			Handler = HandleCylCommand,
			HelpString = "Generates a hollow cylinder",
			Category = "Generation",
		},

		["//help"] =
		{
			Permission = "worldedit.help",
			Handler = HandleWorldEditHelpCommand,
			HelpString = "Sends all the available commands to the player",
			Category = "Special",
		},

		["//hpos1"] =
		{
			Permission = "worldedit.selection.pos",
			Handler = HandleHPosCommand,
			HelpString = "Set position 1 to the position you are looking at",
			Category = "Selection",
		},

		["//hpos2"] =
		{
			Permission = "worldedit.selection.pos",
			Handler = HandleHPosCommand,
			HelpString = "Set position 2 to the position you are looking at",
			Category = "Selection",
		},

		["//hpyramid"] =
		{
			Permission = "worldedit.generation.pyramid",
			Handler = HandlePyramidCommand,
			HelpString = "Generate a hollow pyramid",
			Category = "Generation",
		},

		["//hsphere"] =
		{
			Permission = "worldedit.generation.hsphere",
			Handler = HandleSphereCommand,
			HelpString = "Generates a hollow sphere",
			Category = "Generation",
		},

		["//leafdecay"] =
		{
			Permission = "worldedit.region.leafdecay",
			Handler = HandleLeafDecayCommand,
			HelpString = "Removes all the leaves in the selection that would decay",
			Category = "Region",
		},

		["//loadsel"] =
		{
			Permission = "worldedit.selection.loadselection",
			Handler = HandleSaveLoadSelectionCommand,
			HelpString = "Loads a selection that was saved before",
			Category = "Selection",
		},

		["//mirror"] =
		{
			Permission = "worldedit.region.mirror",
			Handler = HandleMirrorCommand,
			HelpString = "Mirrors the selection by the specified plane",
			Category = "Region",
			ParameterCombinations =
			{
				{
					Params = "plane",
					Help = "Mirrors the selection by the specified plane",
				},
			},
		},

		["//paste"] =
		{
			Permission = "worldedit.clipboard.paste",
			Handler = HandlePasteCommand,
			HelpString = "Pastes the clipboard's contents",
			Category = "Clipboard",
		},

		["//pos1"] =
		{
			Permission = "worldedit.selection.pos",
			Handler = HandlePosCommand,
			HelpString = "Set position 1",
			Category = "Selection",
		},

		["//pos2"] =
		{
			Permission = "worldedit.selection.pos",
			Handler = HandlePosCommand,
			HelpString = "Set position 2",
			Category = "Selection",
		},

		["//pyramid"] =
		{
			Permission = "worldedit.generation.pyramid",
			Handler = HandlePyramidCommand,
			HelpString = "Generate a filled pyramid",
			Category = "Generation",
		},

		["//redo"] =
		{
			Alias = "/redo",
			Permission = "worldedit.history.redo",
			Handler = HandleRedoCommand,
			HelpString = "Redoes the last action (from history)",
			Category = "History",
		},

		["//replace"] =
		{
			Alias = { "//re", "//rep", },
			Permission = "worldedit.region.replace",
			Handler = HandleReplaceCommand,
			HelpString = "Replace all the blocks in the selection with another",
			Category = "Region",
		},

		["//replacenear"] =
		{
			Alias = "/replacenear",
			Permission = "worldedit.replacenear",
			Handler = HandleReplaceNearCommand,
			HelpString = "Replace nearby blocks",
			Category = "Terraforming",
		},

		["//rotate"] =
		{
			Permission = "worldedit.clipboard.rotate",
			Handler = HandleRotateCommand,
			HelpString = "Rotates the contents of the clipboard",
			Category = "Clipboard",
		},

		["//savesel"] =
		{
			Permission = "worldedit.selection.saveselection",
			Handler = HandleSaveLoadSelectionCommand,
			HelpString = "Saves the current selection so it can be used later",
			Category = "Selection",
		},

		["//schematic"] =
		{
			Alias = "//schem",
			Permission = "",  -- Multi-commands shouldn't specify a permission
			Handler = nil,  -- Provide a standard multi-command handler
			HelpString = "",  -- Don't show in help
			Category = "Schematic",
			Subcommands =
			{
				save =
				{
					HelpString = "Saves the current clipboard to a file with the given filename",
					Permission = "worldedit.schematic.save",
					Handler = HandleSchematicSaveCommand,
					Alias = "s",
					Category = "Schematic",
				},
				load =
				{
					HelpString = "Loads the given schematic file",
					Permission = "worldedit.schematic.load",
					Handler = HandleSchematicLoadCommand,
					Alias = "l",
					Category = "Schematic",
				},
				formats =
				{
					HelpString = "List available schematic formats",
					Permission = "worldedit.schematic.list",
					Handler = HandleSchematicFormatsCommand,
					Alias = {"listformats", "f" },
					Category = "Schematic",
				},
				list =
				{
					HelpString = "List available schematics",
					Permission = "worldedit.schematic.list",
					Handler = HandleSchematicListCommand,
					Alias = { "all", "ls", },
					Category = "Schematic",
				},
			},
		},

		["//set"] =
		{
			Permission = "worldedit.region.set",
			Handler = HandleSetCommand,
			HelpString = "Set all the blocks inside the selection to a block",
			Category = "Region",
		},

		["//setbiome"] =
		{
			Permission = "worldedit.biome.set",
			Handler = HandleSetBiomeCommand,
			HelpString = "Set the biome of the region",
			Category = "Biome",
		},

		["//shift"] =
		{
			Permission = "worldedit.selection.size",
			Handler = HandleShiftCommand,
			HelpString = "Move the selection area",
			Category = "Selection",
		},

		["//shrink"] =
		{
			Permission = "worldedit.selection.shrink",
			Handler = HandleShrinkCommand,
			HelpString = "Shrink the current selection to exclude air-only layers of the selection",
			Category = "Selection"
		},

		["//size"] =
		{
			Permission = "worldedit.selection.size",
			Handler = HandleSizeCommand,
			HelpString = "Get the size of the selection",
			Category = "Selection",
		},

		["//snow"] =
		{
			Alias = "/snow",
			Permission = "worldedit.snow",
			Handler = HandleSnowCommand,
			HelpString = "Makes it look like it has snown",
			Category = "Terraforming",
		},

		["//sphere"] =
		{
			Permission = "worldedit.generation.sphere",
			Handler = HandleSphereCommand,
			HelpString = "Generates a filled sphere",
			Category = "Generation",
		},

		["//stack"] =
		{
			Permission = "worldedit.region.stack",
			Handler = HandleStackCommand,
			HelpString = "Repeat the contents of the selection",
			Category = "Region",
		},

		["//thaw"] =
		{
			Alias = "/thaw",
			Permission = "worldedit.thaw",
			Handler = HandleThawCommand,
			HelpString = "Removes all the snow around you in the given radius",
			Category = "Terraforming",
		},

		["//undo"] =
		{
			Alias = "/undo",
			Permission = "worldedit.history.undo",
			Handler = HandleUndoCommand,
			HelpString = "Undoes the last action",
			Category = "History",
		},

		["//vmirror"] =
		{
			Permission = "worldedit.region.vmirror",
			Handler = HandleVMirrorCommand,
			HelpString = "Mirrors the selection vertically",
			Category = "Region",
		},

		["//walls"] =
		{
			Permission = "worldedit.region.walls",
			Handler = HandleWallsCommand,
			HelpString = "Build the four sides of the selection",
			Category = "Region",
		},

		["//wand"] =
		{
			Permission = "worldedit.wand",
			Handler = HandleWandCommand,
			HelpString = "Get the wand object",
			Category = "Special",
		},

---------------------------------------------------------------------------------------------------
-- Single-slash commands:

		["/.s"] =
		{
			Permission = "worldedit.scripting.execute",
			Handler = HandleLastCraftScriptCommand,
			HelpString = "Execute last CraftScript",
			Category = "Scripting",
		},

		["/ascend"] =
		{
			Alias = "/asc",
			Permission = "worldedit.navigation.ascend",
			Handler = HandleAscendCommand,
			HelpString = "Go up a floor",
			Category = "Navigation",
		},

		["/biomeinfo"] =
		{
			Permission = "worldedit.biome.info",
			Handler = HandleBiomeInfoCommand,
			HelpString = "Get the biome of the targeted block(s)",
			Category = "Biome",
		},

		["/biomelist"] =
		{
			Alias = "/biomels",
			Permission = "worldedit.biomelist",
			Handler = HandleBiomeListCommand,
			HelpString = "Gets all biomes available",
			Category = "Biome",
		},

		["/brush"] =
		{
			Alias = { "//brush", "/br", "//br", },
			Permission = "",
			Handler = nil,
			HelpString = "Brush commands",
			Category = "Brush",
			Subcommands =
			{
				sphere =
				{
					HelpString = "Switch to the sphere brush tool",
					Permission = "worldedit.brush.sphere",
					Handler = HandleSphereBrush,
					Alias = "s",
					Category = "Brush",
				},
				cylinder =
				{
					HelpString = "Switch to the cylinder brush tool",
					Permission = "worldedit.brush.cylinder",
					Handler = HandleCylinderBrush,
					Alias = { "c", "cyl", },
					Category = "Brush",
				},
			},
		},

		["/butcher"] =
		{
			Permission = "worldedit.butcher",
			Handler = HandleButcherCommand,
			HelpString = "Kills nearby mobs based on the given radius, if no radius is given it uses the default in configuration",
			Category = "Entities",
		},

		["/ceil"] =
		{
			Permission = "worldedit.navigation.ceiling",
			Handler = HandleCeilCommand,
			HelpString = "Go to the celing",
			Category = "Navigation",
		},

		["/cs"] =
		{
			Permission = "worldedit.scripting.execute",
			Handler = HandleCraftScriptCommand,
			HelpString = "Execute a CraftScript",
			Category = "Scripting",
		},

		["/descend"] =
		{
			Alias = "/desc",
			Permission = "worldedit.navigation.descend",
			Handler = HandleDescendCommand,
			HelpString = "Go down a floor",
			Category = "Navigation",
		},

		["/farwand"] =
		{
			Permission = "worldedit.tool.farwand",
			Handler = HandleFarwandCommand,
			HelpString = "Use the wand from a distance",
			Category = "Tool",
		},

		["/jumpto"] =
		{
			Alias = "/j",
			Permission = "worldedit.navigation.jumpto.command",
			Handler = HandleJumpToCommand,
			HelpString = "Teleport to a location",
			Category = "Navigation",
		},

		["/mask"] =
		{
			Permission = "worldedit.brush.options.mask",
			Handler = HandleMaskCommand,
			HelpString = "Set the brush mask",
			Category = "Brush",
		},

		["/none"] =
		{
			Handler = HandleNoneCommand,
			HelpString = "Unbind a bound tool from your current item",
			Category = "Tool",
		},

		["/pumpkins"] =
		{
			Permission = "worldedit.generation.pumpkins",
			Handler = HandlePumpkinsCommand,
			HelpString = "Generates pumpkins at the surface",
			Category = "Terraforming",
		},

		["/remove"] =
		{
			Alias = { "/rem", "/rement", },
			Permission = "worldedit.remove",
			Handler = HandleRemoveCommand,
			HelpString = "Removes all entities of a type",
			Category = "Entities",
		},

		["/removeabove"] =
		{
			Alias = "//removeabove",
			Permission = "worldedit.removeabove",
			Handler = HandleRemoveColumnCommand,
			HelpString = "Remove all the blocks above you",
			Category = "Terraforming",
		},

		["/removebelow"] =
		{
			Alias = "//removebelow",
			Permission = "worldedit.removebelow",
			Handler = HandleRemoveColumnCommand,
			HelpString = "Remove all the blocks below you",
			Category = "Terraforming",
		},

		["/repl"] =
		{
			Permission = "worldedit.tool.replacer",
			Handler = HandleReplCommand,
			HelpString = "Block replace tool",
			Category = "Tool",
		},

		["/thru"] =
		{
			Permission = "worldedit.navigation.thru.command",
			Handler = HandleThruCommand,
			HelpString = "Passthrough walls",
			Category = "Navigation",
		},

		["/toggleeditwand"] =
		{
			Permission = "worldedit.wand.toggle",
			Handler = HandleToggleEditWandCommand,
			HelpString = "Toggle functionality of the edit wand",
			Category = "Special",
		},

		["/tool"] =
		{
			Permission = "",
			Handler = nil,
			HelpString = "Select a tool to bind",
			Category = "Tool",
			Subcommands =
			{
				none =
				{
					HelpString = "Unbind a bound tool from your current item",
					Handler = HandleNoneCommand,
					Category = "Tool",
				},
				tree =
				{
					HelpString = "Tree generator tool",
					Permission = "worldedit.tool.tree",
					Handler = HandleTreeCommand,
					Category = "Tool",
				},
				repl =
				{
					HelpString = "Block replace tool",
					Permission = "worldedit.tool.replacer",
					Handler = HandleReplCommand,
					Category = "Tool",
				},
				sphere =
				{
					HelpString = "Switch to the sphere brush tool",
					Permission = "worldedit.brush.sphere",
					Handler = HandleSphereBrush,
					Alias = "s",
					Category = "Tool",
				},
				cylinder =
				{
					HelpString = "Switch to the cylinder brush tool",
					Permission = "worldedit.brush.cylinder",
					Handler = HandleCylinderBrush,
					Alias = { "c", "cyl", },
					Category = "Tool",
				},
				farwand =
				{
					HelpString = "Use the wand from a distance",
					Permission = "worldedit.tool.farwand",
					Handler = HandleFarwandCommand,
					Category = "Tool",
				},
			},
		},

		["/tree"] =
		{
			Permission = "worldedit.tool.tree",
			Handler = HandleTreeCommand,
			HelpString = "Tree generator tool",
			Category = "Tool",
		},

		["/up"] =
		{
			Permission = "worldedit.navigation.up",
			Handler = HandleUpCommand,
			HelpString = "Go upwards some distance",
			Category = "Navigation",
		},

		["/we"] =
		{
			Alias = "/worldedit",
			Permission = "",
			Handler = nil,
			HelpString = "WorldEdit command",
			Category = "Special",
			Subcommands =
			{
				cui =
				{
					HelpString = "Complete CUI handshake",
					Permission = "",
					Handler = HandleWorldEditCuiCommand,
					Category = "Special",
				},
				version =
				{
					HelpString = "Sends the plugin version to the player",
					Permission = "",
					Handler = HandleWorldEditVersionCommand,
					Alias = "ver",
					Category = "Special",
				},
				help =
				{
					HelpString = "Sends all the available commands to the player",
					Permission = "worldedit.help",
					Handler = HandleWorldEditHelpCommand,
					Category = "Special",
				},
			},
		},

	},  -- Commands

	Categories =
	{
		Navigation =
		{
			Description = "Commands that helps the player moving to locations.",
		},
		Clipboard =
		{
			Description = "All the commands that have anything todo with a players clipboard.",
		},
		Tool =
		{
			Description = "Commands that activate a tool. If a tool is activated you can use it by right or left clicking with your mouse.",
		},
		Region =
		{
			Description = "Commands in this category will allow the player to edit the region he/she has selected using //pos[1/2] or using the wand item.",
		},
		Schematic =
		{
			Description = "Commands that load or save schematic's",
		},
		Selection =
		{
			Description = "Commands that give info/help setting the region you have selected.",
		},
		Generation =
		{
			Description = "Commands that generates structures.",
		},
		History =
		{
			Description = "Commands that can undo/redo past WorldEdit actions.",
		},
		Terraforming =
		{
			Description = "Commands that help you Modifying the terrain.",
		},
		Biome =
		{
			Description = "Any biome specific commands.",
		},
		Special =
		{
			Description = "Commands that don't realy fit in another category.",
		},
	},

	AdditionalInfo =
	{
		{
			Header = "API",
			Contents = [[
			]],
		},
		{
			Header = "Config",
			Contents = [[
			]],
		},
		{
			Title = "Saving to Cubeset files",
			Contents =
[[
Cuberite can generate single structures using its SinglePieceStructures generator. This generator uses preset areas which are saved in the Prefab/SinglePieceStructures folder.
The files in this folder are Cubeset files which is a custom file format made by Cuberite's developers which stores the blocks, but also additional information like how spread out each structure has to be and in which biome(s) they can spawn.
WorldEdit is able to generate these files though while Cubeset files can contain more than one structure WorldEdit only generates one per file.
If you want more advanced cubeset files or create multi-piece structures you will have to use the Gallery and GalExport plugin.
These plugins were used for example to create the cubeset files for villages and (nether) fortresses.

WorldEdit generates schematic files using the '//schematic save [format] (filename) [options...]' command. This command takes your current clipboard and saves it as the requested format in the "schematics" folder.
By default this command uses the mcedit format with the ".schematic" extension. This is the default because most external programs use this format.
In order to generate cubeset files you have to explicitly specify that you want the cubeset format. A valid command would look like this: "//schematic save cubeset myfile".

There are numerous adittional options which can be changed to modify how Cuberite's SinglePieceStructures generator handles the structure. The most important of these are:
{%list}
{%li} {%b}AllowedBiomes{%/b} In which biomes can the structure generate. If not specified it can generate in every biome.{%/li}
{%li} {%b}GridSize{%/b} What is the space between structures on the grid.{%/li}
{%li} {%b}MaxOffset{%/b} Used to make the placement less predictable. What is the maximum distance a structure can deviate from the grid.{%/li}
{%li} {%b}piece.VerticalStrategy{%/b} How should the generator determine the Y (vertical) coordinate. The choices for this option are listed below.{%/li}
{%li} {%b}piece.ExpandFloorStrategy{%/b} What should the generator do with the lowest layer once the piece is placed. The choices for this option are listed below.{%/li}
{%/list}

{%b}piece.VerticalStrategy{%/b}

How should the generator determine the Y (vertical) coordinate. Sometimes a the options require one or more extra parameters. These parameters are added and then separated using a pipe character "|"
{%list}
{%li}{%b}Range|{%i}Min{%/i}|{%i}Max{%/i}{%/b} Places the structure between the provided min and max parameters. Requires two parameters.{%/li}
{%li}{%b}TerrainOrOceanTop|{%i}Offset{%/i}{%/b} Places the structure on the highest terrain or on ocean level. Requires one extra parameter with an offset.{%/li}
{%li}{%b}TerrainTop|{%i}Offset{%/i}{%/b} Places the structure on the highest terrain. This can also be underwater. Requires one extra parameter with an offset.{%/li}
{%li}{%b}Fixed|{%i}Height{%/i}{%/b} Always places the structure at the exact height.{%/li}
{%/list}

{%b}piece.ExpandFloorStrategy{%/b}

What should the generator do with the lowest layer once the piece is placed.
{%list}
{%li}{%b}RepeatBottomTillNonAir{%/b} Repeats every block of the lowest layer downwards until a non-air block is reached.{%/li}
{%li}{%b}RepeatBottomTillNonSolid{%/b} Repeats every block of the lowest layer downwards until a non-solid block is reached. This will make it go through water and foliage.{%/li}
{%li}{%b}None{%/b} Don't repeat the lowest layer at all.{%/list}
{%/list}
]]
		},
		{
			Title = "Loading Cubeset files to clipboard",
			Contents =
[[
WorldEdit can also load cubeset files back into the users clipboard. This is done using the "//schematic load (filename) [options...]".
If there are multiple structures in the cubeset file then it's possible to specify which one using "pieceIdx=(number)". Do note though that WorldEdit will only look in the "schematics" folder.
]]
		},
		{
			Title = "Loading Cubeset file in Cuberite's world generator",
			Contents =
[[
After saving your clipboard to a cubeset file it's possible to load it in the world generator.
First you have to copy the file from the "schematics" folder into "Prefabs/SinglePieceStructures" and then enabling it in your world's world.ini file.
This is done by adding "SinglePieceStructures: (CubesetFilename)" into your world.ini's Finishers list.
]]
		}
	},  -- AdditionalInfo
}
