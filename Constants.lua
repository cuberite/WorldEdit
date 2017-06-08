
-- Constants.lua

-- Contains global variables that WorldEdit reguraly uses.





--- Some blocks won't render if the meta value is 0.
-- Here we keep a list of all of them with the first allowed meta value.
-- Please keep the list alphasorted.
g_DefaultMetas = {
	[E_BLOCK_CHEST]              = 2,
	[E_BLOCK_ENDER_CHEST]        = 2,
	[E_BLOCK_FURNACE]            = 2,
	[E_BLOCK_LADDER]             = 2,
	[E_BLOCK_LIT_FURNACE]        = 2,
	[E_BLOCK_TORCH]              = 1,
	[E_BLOCK_TRAPPED_CHEST]      = 2,
	[E_BLOCK_REDSTONE_TORCH_ON]  = 1,
	[E_BLOCK_REDSTONE_TORCH_OFF] = 1,
	[E_BLOCK_WALLSIGN]           = 2,
	[E_BLOCK_WALL_BANNER]        = 2
}





E_DIRECTION_NORTH1 = 0
E_DIRECTION_NORTH2 = 4
E_DIRECTION_EAST = 1
E_DIRECTION_SOUTH = 2
E_DIRECTION_WEST = 3
