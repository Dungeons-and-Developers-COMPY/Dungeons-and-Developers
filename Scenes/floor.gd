# script to generate floor of the maze
extends TileMapLayer

const default_floor_atlas_coords = Vector2i(0, 0)
const enter_atlas_coords = Vector2i(2,2)
const SOURCE_ID = 3

func gen_floor(start_coord, exit_coord):
	for i in range(Globals.grid_size):
		for j in range(Globals.grid_size):
			set_cell(Vector2i(i,j), SOURCE_ID, default_floor_atlas_coords)
			
	set_cell(Vector2i(start_coord["row"],start_coord["col"]), SOURCE_ID, enter_atlas_coords)
	set_cell(Vector2i(exit_coord["row"],exit_coord["col"]), SOURCE_ID, enter_atlas_coords)
