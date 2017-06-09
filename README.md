This plugin allows you to easily manage the world, edit the world, navigate around or get information. It bears similarity to the Bukkit's WorldEdit plugin and aims to have the same set of commands,however, it has no affiliation to that plugin.

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
| worldedit.brush.cylinder |  | `/tool cylinder`, `/brush cylinder` |  |
| worldedit.brush.options.mask |  | `/mask` |  |
| worldedit.brush.sphere |  | `/tool sphere`, `/brush sphere` |  |
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
| worldedit.help |  | `//help`, `/we help` |  |
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
| worldedit.schematic.list |  | `//schematic formats`, `//schematic list` |  |
| worldedit.schematic.load |  | `//schematic load` |  |
| worldedit.schematic.save |  | `//schematic save` |  |
| worldedit.scripting.execute |  | `/.s`, `/cs` |  |
| worldedit.selection.chunk |  | `//chunk` |  |
| worldedit.selection.contract |  | `//contract` |  |
| worldedit.selection.count |  | `//count` |  |
| worldedit.selection.cylinder |  | `//hcyl` |  |
| worldedit.selection.deselect |  | `//deselect` |  |
| worldedit.selection.distr |  | `//distr` |  |
| worldedit.selection.expand |  | `//expand` |  |
| worldedit.selection.loadselection |  | `//loadsel` |  |
| worldedit.selection.pos |  | `//hpos1`, `//hpos2`, `//pos1`, `//pos2` |  |
| worldedit.selection.saveselection |  | `//savesel` |  |
| worldedit.selection.shrink |  | `//shrink` |  |
| worldedit.selection.size |  | `//size`, `//shift` |  |
| worldedit.snow |  | `//snow` |  |
| worldedit.superpickaxe |  | `//` |  |
| worldedit.thaw |  | `//thaw` |  |
| worldedit.tool.farwand |  | `/tool farwand`, `/farwand` |  |
| worldedit.tool.replacer |  | `/tool repl`, `/repl` |  |
| worldedit.tool.tree |  | `/tool tree`, `/tree` |  |
| worldedit.wand |  | `//wand` |  |
| worldedit.wand.toggle |  | `/toggleeditwand` |  |
