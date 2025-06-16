# script to generate floor of the maze
extends TileMapLayer

const default_floor_atlas_coords = Vector2i(0, 0)
const left_border_atlas_coords = Vector2i(4, 5)
const right_border_atlas_coords = Vector2i(5, 5)
const enter_atlas_coords = Vector2i(2,2)
const SOURCE_ID = 3

func gen_floor(start_coord, exit_coord):
	for i in range(Globals.grid_size):
		for j in range(-1, Globals.grid_size + 1):
			set_cell(Vector2i(i,j), SOURCE_ID, default_floor_atlas_coords)
	# left and right borders
	for y in range(-1, Globals.grid_size + 1):
		set_cell(Vector2i(-1, y), SOURCE_ID, left_border_atlas_coords)
		set_cell(Vector2i(Globals.grid_size, y), SOURCE_ID, right_border_atlas_coords)
	# mark start end end tiles
	set_cell(Vector2i(start_coord["row"],start_coord["col"]), SOURCE_ID, enter_atlas_coords)
	set_cell(Vector2i(exit_coord["row"],exit_coord["col"]), SOURCE_ID, enter_atlas_coords)
