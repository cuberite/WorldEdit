This plugin is not in collaboration with the developpers of the real WorldEdit plugin.
I am currently trying to create WorldEdit for [MCServer](http://www.mc-server.org/). This plugin is in early Beta stage.<br />
### How to install<br />
Put the `WorldEdit-master` folder in the plugins folder and add `Plugin=WorldEdit-master` to the settings.ini in the `[Plugins]` section.<br /><br />

### Commands<br />
##### Terraforming
<pre>
//drain        worldedit.drain        Drain a pool
//ex           worldedit.extinguish   Extinguish nearby fire.
//green        worldedit.green        Greens the area
//removeabove  worldedit.removeabove  Remove blocks above your head.
//removebelow  worldedit.removebelow  Remove blocks below you.
/snow          worldedit.snow         Simulates snow
/thaw          worldedit.thaw         Thaws the area
</pre>
##### Region
<pre>
//faces    worldedit.region.faces    Build the walls, ceiling, and floor of a selection
//replace  worldedit.region.replace  Replace all the blocks in the selection with another
//set      worldedit.region.set      Set all the blocks inside the selection to a block
//walls    worldedit.region.walls    Build the four sides of the selection
</pre>
##### Special
<pre>
//wand           worldedit.wand         Get the wand object
/toggleeditwand  worldedit.wand.toggle  Toggle functionality of the edit wand
/we                                     World edit command
</pre>
##### Biome
<pre>
//setbiome  worldedit.biome.set   Set the biome of the region.
/biomeinfo  worldedit.biome.info  Get the biome of the targeted block.
/biomelist  worldedit.biomelist   Gets all biomes available.
</pre>
##### History
<pre>
//redo  worldedit.history.redo  Redoes the last action (from history)
//undo  worldedit.history.undo  Undoes the last action
</pre>
##### Generation
<pre>
/pumpkins  worldedit.generation.pumpkins  Generate pumpkin patches
</pre>
##### Clipboard
<pre>
//copy      worldedit.clipboard.copy                                                      Copy the selection to the clipboard
//cut       worldedit.clipboard.cut                                                       Cut the selection to the clipboard
//paste     worldedit.clipboard.paste                                                     Pastes the clipboard's contents.
//rotate    worldedit.clipboard.rotate                                                    Rotate the contents of the clipboard
/schematic  worldedit.schematic.save worldedit.schematic.load worldedit.schematic.delete  Schematic-related commands
</pre>
##### Navigation
<pre>
/ascend   worldedit.navigation.ascend          Go up a floor
/ceil     worldedit.navigation.ceiling         Go to the celing
/descend  worldedit.navigation.descend         Go down a floor
/jumpto   worldedit.navigation.jumpto.command  Teleport to a location
/thru     worldedit.navigation.thru.command    Passthrough walls
/up       worldedit.navigation.up              Go upwards some distance
</pre>
##### Entities
<pre>
/butcher  worldedit.butcher  Kills nearby mobs, based on radius, if none is given uses default in configuration.
</pre>
##### Tool
<pre>
//       worldedit.superpickaxe   Toggle the super pickaxe pickaxe function
/remove  worldedit.remove         Remove all entities of a type
/repl    worldedit.tool.replacer  Block replace tool
/tree    worldedit.tool.tree      Tree generator tool
/none                             Unbind a bound tool from your current item
</pre>
##### Selection
<pre>
//pos1  worldedit.selection.pos   Set position 1
//pos2  worldedit.selection.pos   Set position 2
//size  worldedit.selection.size  Get the size of the selection
</pre>
