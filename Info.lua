
-- Info.lua

-- Implements the g_PluginInfo standard plugin description

g_PluginInfo = 
{
	Name = "WorldEdit",
	Version = "0.1",
	Date = "2013-12-29",
	Description = [[
		This plugin allows you to easily manage the world, edit the world, navigate around or get information. It bears similarity to the Bukkit's WorldEdit plugin and aims to have the same set of commands,however, it has no affiliation to that plugin.
	]],
	Commands =
	{
		Descend = 
		{
			Command = "/descend;/desc",
			Permission = "worldedit.navigation.descend",
			Handler = HandleDescendCommand, 
			HelpString = " go down a floor",
			Category = "Navigation",
		},
		
		Ascend =
		{
			Command = "/ascend;/asc",
			Permission = "worldedit.navigation.ascend", 
			Handler = HandleAscendCommand, 
			HelpString = " go down a floor",
			Category = "Navigation",
		},
		
		Thru =
		{
			Command = "/thru",
			Permission = "worldedit.navigation.thru.command",
			Handler = HandleThruCommand,
			HelpString = " Passthrough walls",
			Category = "Navigation",
		},
		
		JumpTo =
		{
			Command = "/jumpto",
			Permission = "worldedit.navigation.jumpto.command",
			Handler = HandleJumpToCommand,
			HelpString = " Teleport to a location",
			Category = "Navigation",
		},
		
		Up =
		{
			Command = "/up",
			Permission = "worldedit.navigation.up",
			Handler = HandleUpCommand,
			HelpString = " go upwards some distance",
			Category = "Navigation",
		},
		
		Set =
		{
			Command = "//set",
			Permission = "worldedit.region.set",
			Handler = HandleSetCommand,
			HelpString = " Set all the blocks inside the selection to a block",
			Category = "Region",
		},
		
		Replace =
		{
			Command = "//replace",
			Permission = "worldedit.region.replace",
			Handler = HandleReplaceCommand,
			HelpString = " Replace all the blocks in the selection with another",
			Category = "Region",
		},
		
		Walls =
		{
			Command = "//walls",
			Permission = "worldedit.region.walls",
			Handler = HandleWallsCommand,
			HelpString = " Build the four sides of the selection",
			Category = "Region",
		},
		
		Faces =
		{
			Command = "//faces",
			Permission = "worldedit.region.faces",
			Handler = HandleFacesCommand,
			HelpString = " Build the walls, ceiling, and floor of a selection",
			Category = "Region",
		},
		
		SetBiome =
		{
			Command = "//setbiome",
			Permission = "worldedit.biome.set",
			Handler = HandleSetBiomeCommand,
			HelpString = " Set the biome of the region.",
			Category = "Biome",
		},
		
		BiomeInfo =
		{
			Command = "/biomeinfo",
			Permission = "worldedit.biome.info",
			Handler = HandleBiomeInfoCommand,
			HelpString = " Get the biome of the targeted block(s).",
			Category = "Biome",
		},
		
		Size =
		{
			Command = "//size",
			Permission = "worldedit.selection.size",
			Handler = HandleSizeCommand,
			HelpString = " Get the size of the selection",
			Category = "Selection",
		},
		
		Rotate =
		{
			Command = "//rotate",
			Permission = "worldedit.clipboard.rotate",
			Handler = HandleRotateCommand,
			HelpString = " Rotates the contents of the clipboard",
			Category = "Clipboard",
		},
		
		Paste =
		{
			Command = "//paste",
			Permission = "worldedit.clipboard.paste",
			Handler = HandlePasteCommand,
			HelpString = " Pastes the clipboard's contents",
			Category = "Clipboard",
		},
		
		Copy =
		{
			Command = "//copy",
			Permission = "worldedit.clipboard.copy",
			Handler = HandleCopyCommand,
			HelpString = " Copy the selection to the clipboard",
			Category = "Clipboard",
		},
		
		Cut =
		{
			Command = "//cut",
			Permission = "worldedit.clipboard.cut",
			Handler = HandleCutCommand,
			HelpString = " Cut the selection to the clipboard",
			Category = "Clipboard",
		},
		
		Schematic =
		{
			Command = "//schematic",
			Permission = "",
			Handler = HandleSchematicCommand,
			HelpString = " Schematic-related commands",
			Category = "Clipboard",
		},
		
		Redo =
		{
			Command = "//redo",
			Permission = "worldedit.history.redo",
			Handler = HandleRedoCommand,
			HelpString = " redoes the last action (from history)",
			Category = "History",
		},
		
		Undo =
		{
			Command = "//undo",
			Permission = "worldedit.history.undo",
			Handler = HandleUndoCommand,
			HelpString = " Undoes the last action",
			Category = "History",
		},
		
		Butcher =
		{
			Command = "/butcher",
			Permission = "worldedit.butcher",
			Handler = HandleButcherCommand,
			HelpString = " Kills nearby mobs based on the given radius, if no radius is given it uses the default in configuration.",
			Category = "Entities",
		},
		
		Remove =
		{
			Command = "/remove;/rem;/rement",
			Permission = "worldedit.remove",
			Handler = HandleRemoveCommand,
			HelpString = " Removes all entities of a type",
			Category = "Entities",
		},
		
		ToggleEditWand =
		{
			Command = "/toggleeditwand",
			Permission = "worldedit.wand.toggle",
			Handler = HandleToggleEditWandCommand,
			HelpString = " Toggle functionality of the edit wand",
			Category = "Special",
		},
		
		Tree =
		{
			Command = "/tree",
			Permission = "worldedit.tool.tree",
			Handler = HandleTreeCommand,
			HelpString = " Tree generator tool",
			Category = "Tool",
		},
		
		Repl =
		{
			Command = "/repl",
			Permission = "worldedit.tool.replacer",
			Handler = HandleReplCommand,
			HelpString = " Block replace tool",
			Category = "Tool",
		},
		
		None =
		{
			Command = "/none",
			Permission = "",
			Handler = HandleNoneCommand,
			HelpString = " Unbind a bound tool from your current item",
			Category = "Tool",
		},
		
		Wand =
		{
			Command = "//wand",
			Permission = "worldedit.wand",
			Handler = HandleWandCommand,
			HelpString = " Get the wand object",
			Category = "Special",
		},
		
		SuperPick =
		{
			Command = "//;/",
			Permission = "worldedit.superpickaxe",
			Handler = HandleSuperPickCommand,
			HelpString = " Toggle the super pickaxe pickaxe function",
			Category = "Tool",
		},
		
		Pos1 =
		{
			Command = "//pos1",
			Permission = "worldedit.selection.pos",
			Handler = HandlePos1Command,
			HelpString = " Set position 1",
			Category = "Selection",
		},
		
		Pos2 =
		{
			Command = "//pos2",
			Permission = "worldedit.selection.pos",
			Handler = HandlePos2Command,
			HelpString = " Set position 2",
			Category = "Selection",
		},
		
		BiomeList =
		{
			Command = "/biomelist",
			Permission = "worldedit.biomelist",
			Handler = HandleBiomeListCommand,
			HelpString = " Gets all biomes available",
			Category = "Biome",
		},
		
		WE =
		{
			Command = "/we",
			Permission = "",
			Handler = HandleWorldEditCommand,
			HelpString = " World edit command",
			Category = "Special",
		},
		
		RemoveBelow =
		{
			Command = "/removebelow;//removebelow",
			Permission = "worldedit.removebelow",
			Handler = HandleRemoveBelowCommand,
			HelpString = " Remove all the blocks below you.",
			Category = "Terraforming",
		},
		
		RemoveAbove =
		{
			Command = "/removeabove;//removeabove",
			Permission = "worldedit.removeabove",
			Handler = HandleRemoveAboveCommand,
			HelpString = " Remove all the blocks above you.",
			Category = "Terraforming",
		},
		
		Drain =
		{
			Command = "//drain",
			Permission = "worldedit.drain",
			Handler = HandleDrainCommand,
			HelpString = " Drains all water around you in the given radius.",
			Category = "Terraforming",
		},
		
		Extinguish =
		{
			Command = "//ex;//ext;//extinguish;/ex;/ext;/extinguish",
			Permission = "worldedit.extinguish",
			Handler = HandleExtinguishCommand,
			HelpString = " Removes all the fires around you in the given radius.",
			Category = "Terraforming",
		},
		
		Green =
		{
			Command = "//green",
			Permission = "worldedit.green",
			Handler = HandleGreenCommand,
			HelpString = " Changes all the dirt to grass.",
			Category = "Terraforming",
		},
		
		Snow =
		{
			Command = "/snow",
			Permission = "worldedit.snow",
			Handler = HandleSnowCommand,
			HelpString = " Makes it look like it has snown.",
			Category = "Terraforming",
		},
		
		Thaw =
		{
			Command = "/thaw",
			Permission = "worldedit.thaw",
			Handler = HandleThawCommand,
			HelpString = " Removes all the snow around you in the given radius.",
			Category = "Terraforming",
		},
		
		Pumpkins =
		{
			Command = "/pumpkins",
			Permission = "worldedit.generation.pumpkins",
			Handler = HandlePumpkinsCommand,
			HelpString = " Generates pumpkins at the surface.",
			Category = "Terraforming",
		},	
	},
	Categories =
	{
		Navigation =
		{
			Desc = "Commands that helps the player moving to locations.",
		},
		Clipboard =
		{
			Desc = "All the commands that have anything todo with a players clipboard.",
		},
		Tool =
		{
			Desc = "Commands that activate a tool. If a tool is activated you can use it by right or left clicking with your mouse.",
		},
		Region =
		{
			Desc = "Commands in this category will allow the player to edit the region he/she has selected using //pos[1/2] or using the wand item.",
		},
		Selection =
		{
			Desc = "Commands that give info/help setting the region you have selected.",
		},
		History =
		{
			Desc = "Commands that can undo/redo past WorldEdit actions.",
		},
		Terraforming =
		{
			Desc = "Commands that help you Modifying the terrain.",
		},
		Biome =
		{
			Desc = "Any biome specific commands.",
		},
		Special =
		{
			Desc = "Commands that don't realy fit in another category.",
		},
	}
}	