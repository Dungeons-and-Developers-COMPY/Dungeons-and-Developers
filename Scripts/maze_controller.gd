# manages the floor and wall tile map layers of the maze and the generation of the tiles
extends Node2D

@onready var floor = $Floor
@onready var walls = $Walls
@onready var extras: TileMapLayer = $Extras

# % of variant floor tiles 
var variance: float = 20
var rng = RandomNumberGenerator.new()

var gold_source_id = 3
var gold_objs = [Vector2i(3,4), Vector2i(4,4),Vector2i(5,4)]

func _ready() -> void:
	walls.gold.connect(place_gold)

func set_maze(maze, start_coord, exit_coord):
	walls.set_maze(maze, start_coord, exit_coord)
	gen_floor()

func get_maze():
	return walls.gen_maze()

func get_start():
	return walls.start_coord

func get_exit():
	return walls.exit_coord

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
	
func gen_floor():
	floor.gen_floor(walls.start_coord, walls.exit_coord)

func place_gold(x: int, y: int):
	extras.set_cell(Vector2i(x, y), gold_source_id, get_gold_obj())

func get_gold_obj():
	return gold_objs[randi_range(0, len(gold_objs)- 1)]
