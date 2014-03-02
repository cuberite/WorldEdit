This plugin allows you to easily manage the world, edit the world, navigate around or get information. It bears similarity to the Bukkit's WorldEdit plugin and aims to have the same set of commands,however, it has no affiliation to that plugin. 	

# Commands

## General


### //schematic formats
List available schematic formats

Permission required: **worldedit.schematic.list**


### //schematic list
List available schematics

Permission required: **worldedit.schematic.list**


### //schematic load
Loads the given schematic file.

Permission required: **worldedit.schematic.load**


### //schematic save
Saves the current clipboard to a file with the given filename.

Permission required: **worldedit.schematic.save**


### /we help
Sends all the available commands to the player.

Permission required: ****


### /we reload
Reloads the WorldEdit plugin.

Permission required: ****


### /we version
Sends the plugin version to the player.

Permission required: ****




## Biome
Any biome specific commands.


### //setbiome
 Set the biome of the region.

Permission required: **worldedit.biome.set**


### /biomeinfo
 Get the biome of the targeted block(s).

Permission required: **worldedit.biome.info**


### /biomelist
 Gets all biomes available

Permission required: **worldedit.biomelist**




## Clipboard
All the commands that have anything todo with a players clipboard.


### //copy
 Copy the selection to the clipboard

Permission required: **worldedit.clipboard.copy**


### //cut
 Cut the selection to the clipboard

Permission required: **worldedit.clipboard.cut**


### //expand
 Expand the selection area

Permission required: **worldedit.selection.expand**


### //paste
 Pastes the clipboard's contents

Permission required: **worldedit.clipboard.paste**


### //rotate
 Rotates the contents of the clipboard

Permission required: **worldedit.clipboard.rotate**




## Entities


### /butcher
 Kills nearby mobs based on the given radius, if no radius is given it uses the default in configuration.

Permission required: **worldedit.butcher**


### /remove
 Removes all entities of a type

Permission required: **worldedit.remove**




## Generation
Commands that generates structures.


### //hsphere
 Generates a hollow sphere.

Permission required: **worldedit.generation.hsphere**


### //sphere
 Generates a filled sphere.

Permission required: **worldedit.generation.sphere**




## History
Commands that can undo/redo past WorldEdit actions.


### //redo
 redoes the last action (from history)

Permission required: **worldedit.history.redo**


### //undo
 Undoes the last action

Permission required: **worldedit.history.undo**




## Navigation
Commands that helps the player moving to locations.


### /ascend
 go down a floor

Permission required: **worldedit.navigation.ascend**


### /descend
go down a floor

Permission required: **worldedit.navigation.descend**


### /jumpto
 Teleport to a location

Permission required: **worldedit.navigation.jumpto.command**


### /thru
 Passthrough walls

Permission required: **worldedit.navigation.thru.command**


### /up
 go upwards some distance

Permission required: **worldedit.navigation.up**




## Region
Commands in this category will allow the player to edit the region he/she has selected using //pos[1/2] or using the wand item.


### //faces
 Build the walls, ceiling, and floor of a selection

Permission required: **worldedit.region.faces**


### //replace
 Replace all the blocks in the selection with another

Permission required: **worldedit.region.replace**


### //set
 Set all the blocks inside the selection to a block

Permission required: **worldedit.region.set**


### //walls
 Build the four sides of the selection

Permission required: **worldedit.region.walls**




## Selection
Commands that give info/help setting the region you have selected.


### //hpos1
 Set position 1 to the position you are looking at.

Permission required: **worldedit.selection.pos**


### //hpos2
 Set position 2 to the position you are looking at.

Permission required: **worldedit.selection.pos**


### //pos1
 Set position 1

Permission required: **worldedit.selection.pos**


### //pos2
 Set position 2

Permission required: **worldedit.selection.pos**


### //shift
 Move the selection area

Permission required: **worldedit.selection.size**


### //size
 Get the size of the selection

Permission required: **worldedit.selection.size**




## Special
Commands that don't realy fit in another category.


### //wand
 Get the wand object

Permission required: **worldedit.wand**


### /toggleeditwand
 Toggle functionality of the edit wand

Permission required: **worldedit.wand.toggle**


### /we
 World edit command

Permission required: ****




## Terraforming
Commands that help you Modifying the terrain.


### //drain
 Drains all water around you in the given radius.

Permission required: **worldedit.drain**


### //extinguish
 Removes all the fires around you in the given radius.

Permission required: **worldedit.extinguish**


### //green
 Changes all the dirt to grass.

Permission required: **worldedit.green**


### /pumpkins
 Generates pumpkins at the surface.

Permission required: **worldedit.generation.pumpkins**


### /removeabove
 Remove all the blocks above you.

Permission required: **worldedit.removeabove**


### /removebelow
 Remove all the blocks below you.

Permission required: **worldedit.removebelow**


### /snow
 Makes it look like it has snown.

Permission required: **worldedit.snow**


### /thaw
 Removes all the snow around you in the given radius.

Permission required: **worldedit.thaw**




## Tool
Commands that activate a tool. If a tool is activated you can use it by right or left clicking with your mouse.


### //
 Toggle the super pickaxe pickaxe function

Permission required: **worldedit.superpickaxe**


### /none
 Unbind a bound tool from your current item


### /repl
 Block replace tool

Permission required: **worldedit.tool.replacer**


### /tree
 Tree generator tool

Permission required: **worldedit.tool.tree**




# Permissions
### worldedit.biome.info


Commands affected:
  - `/biomeinfo`

### worldedit.biome.set


Commands affected:
  - `//setbiome`

### worldedit.biomelist


Commands affected:
  - `/biomelist`

### worldedit.butcher


Commands affected:
  - `/butcher`

### worldedit.clipboard.copy


Commands affected:
  - `//copy`

### worldedit.clipboard.cut


Commands affected:
  - `//cut`

### worldedit.clipboard.paste


Commands affected:
  - `//paste`

### worldedit.clipboard.rotate


Commands affected:
  - `//rotate`

### worldedit.drain


Commands affected:
  - `//drain`

### worldedit.extinguish


Commands affected:
  - `//extinguish`

### worldedit.generation.hsphere


Commands affected:
  - `//hsphere`

### worldedit.generation.pumpkins


Commands affected:
  - `/pumpkins`

### worldedit.generation.sphere


Commands affected:
  - `//sphere`

### worldedit.green


Commands affected:
  - `//green`

### worldedit.history.redo


Commands affected:
  - `//redo`

### worldedit.history.undo


Commands affected:
  - `//undo`

### worldedit.navigation.ascend


Commands affected:
  - `/ascend`

### worldedit.navigation.descend


Commands affected:
  - `/descend`

### worldedit.navigation.jumpto.command


Commands affected:
  - `/jumpto`

### worldedit.navigation.thru.command


Commands affected:
  - `/thru`

### worldedit.navigation.up


Commands affected:
  - `/up`

### worldedit.region.faces


Commands affected:
  - `//faces`

### worldedit.region.replace


Commands affected:
  - `//replace`

### worldedit.region.set


Commands affected:
  - `//set`

### worldedit.region.walls


Commands affected:
  - `//walls`

### worldedit.remove


Commands affected:
  - `/remove`

### worldedit.removeabove


Commands affected:
  - `/removeabove`

### worldedit.removebelow


Commands affected:
  - `/removebelow`

### worldedit.schematic.list


Commands affected:
  - `//schematic formats`
  - `//schematic list`

### worldedit.schematic.load


Commands affected:
  - `//schematic load`

### worldedit.schematic.save


Commands affected:
  - `//schematic save`

### worldedit.selection.expand


Commands affected:
  - `//expand`

### worldedit.selection.pos


Commands affected:
  - `//hpos2`
  - `//hpos1`
  - `//pos2`
  - `//pos1`

### worldedit.selection.size


Commands affected:
  - `//size`
  - `//shift`

### worldedit.snow


Commands affected:
  - `/snow`

### worldedit.superpickaxe


Commands affected:
  - `//`

### worldedit.thaw


Commands affected:
  - `/thaw`

### worldedit.tool.replacer


Commands affected:
  - `/repl`

### worldedit.tool.tree


Commands affected:
  - `/tree`

### worldedit.wand


Commands affected:
  - `//wand`

### worldedit.wand.toggle


Commands affected:
  - `/toggleeditwand`

