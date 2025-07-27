extends Node 
class_name Globals

static var grid_size = 9
static var step_delay = 0
static var allow_loops = false
static var letters_to_show = []
static var show_labels = false
static var stun_time = 3

static var maze_scale = 3
static var pixels = 16
static var offset: Vector2 = Vector2(0, 0)

static var num_monsters = 2
static var monster_positions = []
static var monsters = [preload("res://Scenes/skeleton.tscn")]
static var monster_scales = [2]
static var monster_types = []

static var MOVING_TEXT = "Move around using: move_left(int steps), move_right(int steps), move_up(int steps), move_down(int steps)\nReach the exit before your opponent!"

signal fringe_changed
