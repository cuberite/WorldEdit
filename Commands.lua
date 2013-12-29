g_PluginInfo = 
{
	Name = "WorldEdit",
	Version = "0.1",
	Date = "2013-12-29",
	Description = [[]],
	Commands =
	{
		Descend = 
		{
			Command = "/descend;/desc",
			Permission = "worldedit.navigation.descend",
			Handler = HandleDescendCommand, 
			HelpString = " go down a floor", 
		},
		
		Ascend =
		{
			Command = "/ascend;/asc",
			Permission = "worldedit.navigation.ascend", 
			Handler = HandleAscendCommand, 
			HelpString = " go down a floor",
		},
		
		Thru =
		{
			Command = "/thru",
			Permission = "worldedit.navigation.thru.command",
			Handler = HandleThruCommand,
			HelpString = " Passthrough walls",
		},
		
		JumpTo =
		{
			Command = "/jumpto",
			Permission = "worldedit.navigation.jumpto.command",
			Handler = HandleJumpToCommand,
			HelpString = " Teleport to a location",
		},
		
		Up =
		{
			Command = "/up",
			Permission = "worldedit.navigation.up",
			Handler = HandleUpCommand,
			HelpString = " go upwards some distance",
		},
		
		Set =
		{
			Command = "//set",
			Permission = "worldedit.region.set",
			Handler = HandleSetCommand,
			HelpString = " Set all the blocks inside the selection to a block",
		},
		
		Replace =
		{
			Command = "//replace",
			Permission = "worldedit.region.replace",
			Handler = HandleReplaceCommand,
			HelpString = " Replace all the blocks in the selection with another",
		},
		
		Walls =
		{
			Command = "//walls",
			Permission = "worldedit.region.walls",
			Handler = HandleWallsCommand,
			HelpString = " Build the four sides of the selection",
		},
		
		Faces =
		{
			Command = "//faces",
			Permission = "worldedit.region.faces",
			Handler = HandleFacesCommand,
			HelpString = " Build the walls, ceiling, and floor of a selection",
		},
		
		SetBiome =
		{
			Command = "//setbiome",
			Permission = "worldedit.biome.set",
			Handler = HandleSetBiomeCommand,
			HelpString = " Set the biome of the region.",
		},
		
		BiomeInfo =
		{
			Command = "/biomeinfo",
			Permission = "worldedit.biome.info",
			Handler = HandleBiomeInfoCommand,
			HelpString = " Get the biome of the targeted block(s).",
		},
		
		Size =
		{
			Command = "//size",
			Permission = "worldedit.selection.size",
			Handler = HandleSizeCommand,
			HelpString = " Get the size of the selection",
		},
		
		Rotate =
		{
			Command = "//rotate",
			Permission = "worldedit.clipboard.rotate",
			Handler = HandleRotateCommand,
			HelpString = " Rotates the contents of the clipboard",
		},
		
		Paste =
		{
			Command = "//paste",
			Permission = "worldedit.clipboard.paste",
			Handler = HandlePasteCommand,
			HelpString = " Pastes the clipboard's contents",
		},
		
		Copy =
		{
			Command = "//copy",
			Permission = "worldedit.clipboard.copy",
			Handler = HandleCopyCommand,
			HelpString = " Copy the selection to the clipboard",
		},
		
		Cut =
		{
			Command = "//cut",
			Permission = "worldedit.clipboard.cut",
			Handler = HandleCutCommand,
			HelpString = " Cut the selection to the clipboard",
		},
		
		Schematic =
		{
			Command = "//schematic",
			Permission = "",
			Handler = HandleSchematicCommand,
			HelpString = " Schematic-related commands",
		},
		
		Redo =
		{
			Command = "//redo",
			Permission = "worldedit.history.redo",
			Handler = HandleRedoCommand,
			HelpString = " redoes the last action (from history)",
		},
		
		Undo =
		{
			Command = "//undo",
			Permission = "worldedit.history.undo",
			Handler = HandleUndoCommand,
			HelpString = " Undoes the last action",
		},
		
		Butcher =
		{
			Command = "/butcher",
			Permission = "worldedit.butcher",
			Handler = HandleButcherCommand,
			HelpString = " Kills nearby mobs, based on radius, if none is given uses default in configuration."
		},
		
		Remove =
		{
			Command = "/remove;/rem;/rement",
			Permission = "worldedit.remove",
			Handler = HandleRemoveCommand,
			HelpString = " Removes all entities of a type",
		},
		
		ToggleEditWand =
		{
			Command = "/toggleeditwand",
			Permission = "worldedit.wand.toggle",
			Handler = HandleToggleEditWandCommand,
			HelpString = " Toggle functionality of the edit wand",
		},
		
		Tree =
		{
			Command = "/tree",
			Permission = "worldedit.tool.tree",
			Handler = HandleTreeCommand,
			HelpString = " Tree generator tool",
		},
		
		Repl =
		{
			Command = "/repl",
			Permission = "worldedit.tool.replacer",
			Handler = HandleReplCommand,
			HelpString = " Block replace tool",
		},
		
		None =
		{
			Command = "/none",
			Permission = "",
			Handler = HandleNoneCommand,
			HelpString = " Unbind a bound tool from your current item",
		},
		
		Wand =
		{
			Command = "//wand",
			Permission = "worldedit.wand",
			Handler = HandleWandCommand,
			HelpString = " Get the wand object",
		},
		
		SuperPick =
		{
			Command = "//;/",
			Permission = "worldedit.superpickaxe",
			Handler = HandleSuperPickCommand,
			HelpString = " Toggle the super pickaxe pickaxe function",
		},
		
		Pos1 =
		{
			Command = "//pos1",
			Permission = "worldedit.selection.pos",
			Handler = HandlePos1Command,
			HelpString = " Set position 1",
		},
		
		Pos2 =
		{
			Command = "//pos2",
			Permission = "worldedit.selection.pos",
			Handler = HandlePos2Command,
			HelpString = " Set position 2",
		},
		
		BiomeList =
		{
			Command = "/biomelist",
			Permission = "worldedit.biomelist",
			Handler = HandleBiomeListCommand,
			HelpString = " Gets all biomes available",
		},
		
		WE =
		{
			Command = "/we",
			Permission = "",
			Handler = HandleWorldEditCommand,
			HelpString = " World edit command",
		},
		
		RemoveBelow =
		{
			Command = "/removebelow;//removebelow",
			Permission = "worldedit.removebelow",
			Handler = HandleRemoveBelowCommand,
			HelpString = " Remove all the blocks below you.",
		},
		
		RemoveAbove =
		{
			Command = "/removeabove;//removeabove",
			Permission = "worldedit.removeabove",
			Handler = HandleRemoveAboveCommand,
			HelpString = " Remove all the blocks above you.",
		},
		
		Drain =
		{
			Command = "//drain",
			Permission = "worldedit.drain",
			Handler = HandleDrainCommand,
			HelpString = " Drains all water around you in the given radius.",
		},
		
		Extinguish =
		{
			Command = "//ex;//ext;//extinguish;/ex;/ext;/extinguish",
			Permission = "worldedit.extinguish",
			Handler = HandleExtinguishCommand,
			HelpString = " Removes all the fires around you in the given radius.",
		},
		
		Green =
		{
			Command = "//green",
			Permission = "worldedit.green",
			Handler = HandleGreenCommand,
			HelpString = " Changes all the dirt to grass.",
		},
		
		Snow =
		{
			Command = "/snow",
			Permission = "worldedit.snow",
			Handler = HandleSnowCommand,
			HelpString = " Makes it look like it has snown.",
		},
		
		Thaw =
		{
			Command = "/thaw",
			Permission = "worldedit.thaw",
			Handler = HandleThawCommand,
			HelpString = " Removes all the snow around you in the given radius.",
		},
		
		Pumpkins =
		{
			Command = "/pumpkins",
			Permission = "worldedit.generation.pumpkins",
			Handler = HandlePumpkinsCommand,
			HelpString = " Generates pumpkins at the surface.",
		},
			
	},
}	