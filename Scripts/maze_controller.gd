extends Node2D

@onready var floor = $Floor
@onready var walls = $Walls

# % of variant floor tiles 
var variance: float = 20
var rng = RandomNumberGenerator.new()

#func _ready() -> void:
	#gen_maze()
	#walls.delete_cell_at(Vector2i(walls.start_coord["row"],walls.start_coord["col"]))
	#walls.delete_cell_at(Vector2i(walls.exit_coord["row"],walls.exit_coord["col"]))
	#floor.gen_floor(walls.start_coord, walls.exit_coord)
	#var num_diff_tiles: int = (Globals.grid_size * Globals.grid_size) * (variance/100)
	#var x: int
	#var y: int
	#for i in range(num_diff_tiles):
		#x = rng.randi_range(0, Globals.grid_size - 1)
		#y = rng.randi_range(0, Globals.grid_size - 1)
		#while walls.is_floor(x, y) == false:
			#x = rng.randi_range(0, Globals.grid_size - 1)
			#y = rng.randi_range(0, Globals.grid_size - 1)
		#floor.randomise_tile(x, y)
		
func gen_maze():
	walls.gen_maze()
	
	walls.delete_cell_at(Vector2i(walls.start_coord["row"],walls.start_coord["col"]))
	walls.delete_cell_at(Vector2i(walls.exit_coord["row"],walls.exit_coord["col"]))
	floor.gen_floor(walls.start_coord, walls.exit_coord)
	var num_diff_tiles: int = (Globals.grid_size * Globals.grid_size) * (variance/100)
	var x: int
	var y: int
	for i in range(num_diff_tiles):
		x = rng.randi_range(0, Globals.grid_size - 1)
		y = rng.randi_range(0, Globals.grid_size - 1)
		while walls.is_floor(x, y) == false:
			x = rng.randi_range(0, Globals.grid_size - 1)
			y = rng.randi_range(0, Globals.grid_size - 1)
		floor.randomise_tile(x, y)
	
