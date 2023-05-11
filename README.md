This plugin allows you to easily manage the world, edit the world, navigate around or get information. It bears similarity to the Bukkit's WorldEdit plugin and aims to have the same set of commands,however, it has no affiliation to that plugin.

# Saving to Cubeset files
Cuberite can generate single structures using its SinglePieceStructures generator. This generator uses preset areas which are saved in the Prefab/SinglePieceStructures folder. The files in this folder are Cubeset files which is a custom file format made by Cuberite's developers which stores the blocks, but also additional information like how spread out each structure has to be and in which biome(s) they can spawn.  WorldEdit is able to generate these files though while Cubeset files can contain more than one structure WorldEdit only generates one per file.  If you want more advanced cubeset files or create multi-piece structures you will have to use the Gallery and GalExport plugin.  These plugins were used for example to create the cubeset files for villages and (nether) fortresses.

WorldEdit generates schematic files using the '//schematic save [format] <filename> [options...]' command. This command takes your current clipboard and saves it as the requested format in the "schematics" folder.  By default this command uses the mcedit format with the ".schematic" extension. This is the default because most external programs use this format. In order to generate cubeset files you have to explicitly specify that you want the cubeset format. A valid command would look like this: "//schematic save cubeset myfile".

There are numerous adittional options which can be changed to modify how Cuberite's SinglePieceStructures generator handles the structure. The most important of these are: 
 
 -  **AllowedBiomes** In which biomes can the structure generate. If not specified it can generate in every biome. 
 -  **GridSize** What is the space between structures on the grid. 
 -  **MaxOffset** Used to make the placement less predictable. What is the maximum distance a structure can deviate from the grid. 
 -  **piece.VerticalStrategy** How should the generator determine the Y (vertical) coordinate. The choices for this option are listed below. 
 -  **piece.ExpandFloorStrategy** What should the generator do with the lowest layer once the piece is placed. The choices for this option are listed below. 


**piece.VerticalStrategy**

How should the generator determine the Y (vertical) coordinate. Sometimes a the options require one or more extra parameters. These parameters are added and then separated using a pipe character "|" 
 
 - **Range|*Min*|*Max*** Places the structure between the provided min and max parameters. Requires two parameters. 
 - **TerrainOrOceanTop|*Offset*** Places the structure on the highest terrain or on ocean level. Requires one extra parameter with an offset. 
 - **TerrainTop|*Offset*** Places the structure on the highest terrain. This can also be underwater. Requires one extra parameter with an offset. 
 - **Fixed|*Height*** Always places the structure at the exact height. 


**piece.ExpandFloorStrategy**

What should the generator do with the lowest layer once the piece is placed. 
 
 - **RepeatBottomTillNonAir** Repeats every block of the lowest layer downwards until a non-air block is reached. 
 - **RepeatBottomTillNonSolid** Repeats every block of the lowest layer downwards until a non-solid block is reached. This will make it go through water and foliage. 
 - **None** Don't repeat the lowest layer at all.
 
 

# Loading Cubeset files to clipboard
WorldEdit can also load cubeset files back into the users clipboard. This is done using the "//schematic load <filename> [options...]". If there are multiple structures in the cubeset file then it's possible to specify which one using "pieceIdx=<number>". Do note though that WorldEdit will only look in the "schematics" folder. 

# Loading cubeset file in Cuberite's world generator
After saving your clipboard to a cubeset file it's possible to load it in the world generator. First you have to copy your file from the "schematics" folder into "Prefabs/SinglePieceStructures" and then enabling it in your world's world.ini file.  This is done by adding SinglePieceStructures: <CubesetFilename> into your world.ini's Finishers list. 

# Commands

### Biome
Any biome specific commands.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//setbiome | worldedit.biome.set | Set the biome of the region|
|/biomeinfo | worldedit.biome.info | Get the biome of the targeted block(s)|
|/biomelist | worldedit.biomelist | Gets all biomes available|



### Brush
| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/brush |  | Brush commands|
|/brush cylinder | worldedit.brush.cylinder | Switch to the cylinder brush tool|
|/brush sphere | worldedit.brush.sphere | Switch to the sphere brush tool|
|/mask | worldedit.brush.options.mask | Set the brush mask|



### Clipboard
All the commands that have anything todo with a players clipboard.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//copy | worldedit.clipboard.copy | Copy the selection to the clipboard|
|//cut | worldedit.clipboard.cut | Cut the selection to the clipboard|
|//paste | worldedit.clipboard.paste | Pastes the clipboard's contents|
|//rotate | worldedit.clipboard.rotate | Rotates the contents of the clipboard|



### Entities
| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/butcher | worldedit.butcher | Kills nearby mobs based on the given radius, if no radius is given it uses the default in configuration|
|/remove | worldedit.remove | Removes all entities of a type|



### Generation
Commands that generates structures.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//cyl | worldedit.generation.cylinder | Generates a cylinder|
|//generate | worldedit.generation.shape | Generates a shape according to a formula|
|//hcyl | worldedit.selection.cylinder | Generates a hollow cylinder|
|//hpyramid | worldedit.generation.pyramid | Generate a hollow pyramid|
|//hsphere | worldedit.generation.hsphere | Generates a hollow sphere|
|//pyramid | worldedit.generation.pyramid | Generate a filled pyramid|
|//sphere | worldedit.generation.sphere | Generates a filled sphere|



### History
Commands that can undo/redo past WorldEdit actions.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//redo | worldedit.history.redo | Redoes the last action (from history)|
|//undo | worldedit.history.undo | Undoes the last action|



### Navigation
Commands that helps the player moving to locations.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/ascend | worldedit.navigation.ascend | Go up a floor|
|/ceil | worldedit.navigation.ceiling | Go to the celing|
|/descend | worldedit.navigation.descend | Go down a floor|
|/jumpto | worldedit.navigation.jumpto.command | Teleport to a location|
|/thru | worldedit.navigation.thru.command | Passthrough walls|
|/up | worldedit.navigation.up | Go upwards some distance|



### Region
Commands in this category will allow the player to edit the region he/she has selected using //pos[1/2] or using the wand item.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//addleaves | worldedit.region.addleaves | Adds leaves next to log blocks|
|//ellipsoid | worldedit.region.ellipsoid | Creates an ellipsoid in the selected region|
|//faces | worldedit.region.faces |  Build the walls, ceiling, and floor of a selection|
|//leafdecay | worldedit.region.leafdecay | Removes all the leaves in the selection that would decay|
|//mirror | worldedit.region.mirror | Mirrors the selection by the specified plane|
|//replace | worldedit.region.replace | Replace all the blocks in the selection with another|
|//set | worldedit.region.set | Set all the blocks inside the selection to a block|
|//stack | worldedit.region.stack | Repeat the contents of the selection|
|//vmirror | worldedit.region.vmirror | Mirrors the selection vertically|
|//walls | worldedit.region.walls | Build the four sides of the selection|



### Schematic
Commands that load or save schematic's

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//schematic formats | worldedit.schematic.list | List available schematic formats|
|//schematic list | worldedit.schematic.list | List available schematics|
|//schematic load | worldedit.schematic.load | Loads the given schematic file|
|//schematic save | worldedit.schematic.save | Saves the current clipboard to a file with the given filename|



### Scripting
| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/.s | worldedit.scripting.execute | Execute last CraftScript|
|/cs | worldedit.scripting.execute | Execute a CraftScript|



### Selection
Commands that give info/help setting the region you have selected.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//chunk | worldedit.selection.chunk | Select the chunk you are currently in|
|//contract | worldedit.selection.contract | Contract the selection area|
|//count | worldedit.selection.count | Count the number of blocks in the region|
|//deselect | worldedit.selection.deselect | Deselect the current selection|
|//distr | worldedit.selection.distr | Inspect the block distribution of the current selection|
|//expand | worldedit.selection.expand | Expand the selection area|
|//hpos1 | worldedit.selection.pos | Set position 1 to the position you are looking at|
|//hpos2 | worldedit.selection.pos | Set position 2 to the position you are looking at|
|//loadsel | worldedit.selection.loadselection | Loads a selection that was saved before|
|//pos1 | worldedit.selection.pos | Set position 1|
|//pos2 | worldedit.selection.pos | Set position 2|
|//savesel | worldedit.selection.saveselection | Saves the current selection so it can be used later|
|//shift | worldedit.selection.size | Move the selection area|
|//shrink | worldedit.selection.shrink | Shrink the current selection to exclude air-only layers of the selection|
|//size | worldedit.selection.size | Get the size of the selection|



### Special
Commands that don't realy fit in another category.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//help | worldedit.help | Sends all the available commands to the player|
|//wand | worldedit.wand | Get the wand object|
|/toggleeditwand | worldedit.wand.toggle | Toggle functionality of the edit wand|
|/we |  | WorldEdit command|
|/we cui |  | Complete CUI handshake|
|/we help | worldedit.help | Sends all the available commands to the player|
|/we version |  | Sends the plugin version to the player|



### Terraforming
Commands that help you Modifying the terrain.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|//drain | worldedit.drain | Drains all water around you in the given radius|
|//extinguish | worldedit.extinguish | Removes all the fires around you in the given radius|
|//fill | worldedit.fill | Fill a hole|
|//fillr | worldedit.fill.recursive | Fill a hole recursively|
|//green | worldedit.green |  Changes all the dirt to grass|
|//replacenear | worldedit.replacenear | Replace nearby blocks|
|//snow | worldedit.snow | Makes it look like it has snown|
|//thaw | worldedit.thaw | Removes all the snow around you in the given radius|
|/pumpkins | worldedit.generation.pumpkins | Generates pumpkins at the surface|
|/removeabove | worldedit.removeabove | Remove all the blocks above you|
|/removebelow | worldedit.removebelow | Remove all the blocks below you|



### Tool
Commands that activate a tool. If a tool is activated you can use it by right or left clicking with your mouse.

| Command | Permission | Description |
| ------- | ---------- | ----------- |
|// | worldedit.superpickaxe | Toggle the super pickaxe pickaxe function|
|/farwand | worldedit.tool.farwand | Use the wand from a distance|
|/none |  | Unbind a bound tool from your current item|
|/repl | worldedit.tool.replacer | Block replace tool|
|/tool |  | Select a tool to bind|
|/tool cylinder | worldedit.brush.cylinder | Switch to the cylinder brush tool|
|/tool farwand | worldedit.tool.farwand | Use the wand from a distance|
|/tool none |  | Unbind a bound tool from your current item|
|/tool repl | worldedit.tool.replacer | Block replace tool|
|/tool sphere | worldedit.brush.sphere | Switch to the sphere brush tool|
|/tool tree | worldedit.tool.tree | Tree generator tool|
|/tree | worldedit.tool.tree | Tree generator tool|



# Permissions
| Permissions | Description | Commands | Recommended groups |
| ----------- | ----------- | -------- | ------------------ |
| worldedit.biome.info |  | `/biomeinfo` |  |
| worldedit.biome.set |  | `//setbiome` |  |
| worldedit.biomelist |  | `/biomelist` |  |
| worldedit.brush.cylinder |  | `/brush cylinder`, `/tool cylinder` |  |
| worldedit.brush.options.mask |  | `/mask` |  |
| worldedit.brush.sphere |  | `/brush sphere`, `/tool sphere` |  |
| worldedit.butcher |  | `/butcher` |  |
| worldedit.clipboard.copy |  | `//copy` |  |
| worldedit.clipboard.cut |  | `//cut` |  |
| worldedit.clipboard.paste |  | `//paste` |  |
| worldedit.clipboard.rotate |  | `//rotate` |  |
| worldedit.drain |  | `//drain` |  |
| worldedit.extinguish |  | `//extinguish` |  |
| worldedit.fill |  | `//fill` |  |
| worldedit.fill.recursive |  | `//fillr` |  |
| worldedit.generation.cylinder |  | `//cyl` |  |
| worldedit.generation.hsphere |  | `//hsphere` |  |
| worldedit.generation.pumpkins |  | `/pumpkins` |  |
| worldedit.generation.pyramid |  | `//pyramid`, `//hpyramid` |  |
| worldedit.generation.shape |  | `//generate` |  |
| worldedit.generation.sphere |  | `//sphere` |  |
| worldedit.green |  | `//green` |  |
| worldedit.help |  | `/we help`, `//help` |  |
| worldedit.history.redo |  | `//redo` |  |
| worldedit.history.undo |  | `//undo` |  |
| worldedit.navigation.ascend |  | `/ascend` |  |
| worldedit.navigation.ceiling |  | `/ceil` |  |
| worldedit.navigation.descend |  | `/descend` |  |
| worldedit.navigation.jumpto.command |  | `/jumpto` |  |
| worldedit.navigation.thru.command |  | `/thru` |  |
| worldedit.navigation.up |  | `/up` |  |
| worldedit.region.addleaves |  | `//addleaves` |  |
| worldedit.region.ellipsoid |  | `//ellipsoid` |  |
| worldedit.region.faces |  | `//faces` |  |
| worldedit.region.leafdecay |  | `//leafdecay` |  |
| worldedit.region.mirror |  | `//mirror` |  |
| worldedit.region.replace |  | `//replace` |  |
| worldedit.region.set |  | `//set` |  |
| worldedit.region.stack |  | `//stack` |  |
| worldedit.region.vmirror |  | `//vmirror` |  |
| worldedit.region.walls |  | `//walls` |  |
| worldedit.remove |  | `/remove` |  |
| worldedit.removeabove |  | `/removeabove` |  |
| worldedit.removebelow |  | `/removebelow` |  |
| worldedit.replacenear |  | `//replacenear` |  |
| worldedit.schematic.list |  | `//schematic list`, `//schematic formats` |  |
| worldedit.schematic.load |  | `//schematic load` |  |
| worldedit.schematic.save |  | `//schematic save` |  |
| worldedit.scripting.execute |  | `/cs`, `/.s` |  |
| worldedit.selection.chunk |  | `//chunk` |  |
| worldedit.selection.contract |  | `//contract` |  |
| worldedit.selection.count |  | `//count` |  |
| worldedit.selection.cylinder |  | `//hcyl` |  |
| worldedit.selection.deselect |  | `//deselect` |  |
| worldedit.selection.distr |  | `//distr` |  |
| worldedit.selection.expand |  | `//expand` |  |
| worldedit.selection.loadselection |  | `//loadsel` |  |
| worldedit.selection.pos |  | `//hpos2`, `//pos2`, `//pos1`, `//hpos1` |  |
| worldedit.selection.saveselection |  | `//savesel` |  |
| worldedit.selection.shrink |  | `//shrink` |  |
| worldedit.selection.size |  | `//shift`, `//size` |  |
| worldedit.snow |  | `//snow` |  |
| worldedit.superpickaxe |  | `//` |  |
| worldedit.thaw |  | `//thaw` |  |
| worldedit.tool.farwand |  | `/farwand`, `/tool farwand` |  |
| worldedit.tool.replacer |  | `/repl`, `/tool repl` |  |
| worldedit.tool.tree |  | `/tree`, `/tool tree` |  |
| worldedit.wand |  | `//wand` |  |
| worldedit.wand.toggle |  | `/toggleeditwand` |  |
