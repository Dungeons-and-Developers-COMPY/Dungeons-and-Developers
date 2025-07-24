extends Node 
class_name Globals

static var grid_size = 9
static var step_delay = 0
static var allow_loops = false
static var letters_to_show = []
static var show_labels = false

static var maze_scale = 3
static var pixels = 16
static var offset: Vector2 = Vector2(0, 0)

static var num_monsters = 3
static var monster_positions = []
static var monsters = [preload("res://Scenes/skeleton.tscn")]
static var monster_scales = [2]
static var monster_types = []

signal fringe_changed
