extends Node2D

@onready var floor = $Floor
@onready var walls = $Walls

func _ready() -> void:
	walls.delete_cell_at(Vector2i(walls.start_coord["row"],walls.start_coord["col"]))
	walls.delete_cell_at(Vector2i(walls.exit_coord["row"],walls.exit_coord["col"]))
	
	floor.gen_floor(walls.start_coord, walls.exit_coord)
