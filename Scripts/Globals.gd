extends Node 
class_name Globals

static var grid_size = 9
static var step_delay = 0
static var allow_loops = false
static var letters_to_show = []
static var show_labels = false

static var player_offset = 4
static var stun_time = 3
static var boss_offset = 8

static var maze_scale = 3
static var pixels = 16
static var offset: Vector2 = Vector2(0, 0)

static var num_monsters = 2
static var monster_positions = []
static var monsters = [preload("res://Scenes/skeleton.tscn"), preload("res://Scenes/orc.tscn"), preload("res://Scenes/slime.tscn")]
static var monster_scales = [2, 2, 1.25]
static var monster_types = []
static var bosses = [preload("res://Scenes/golem.tscn"), preload("res://Scenes/dragon_lord.tscn")]
static var bosses_scales = [1.5, 1.5]
static var boss = bosses[0]

static var questions = []

static var MOVING_TEXT = "Move around using: move_left(int steps), move_right(int steps), move_up(int steps), move_down(int steps)\nReach the exit before your opponent!"
static var code_format = "def func(n):\n\t# Code here\n\treturn n"
static var break_string = "----------------------------------"

static var local_ip = "127.0.0.1"
static var server_ip = ""
static var server_port = 0
static var ports_1v1 = [12345, 12346]
static var ports_2v2 = [12347, 12348]
static var MAX_PLAYERS_1v1 = 2

static var timeout = 2.0
static var connection_result = false
static var connection_done = false

static var is_2v2 = false

static var role: int = 0 # 0 for nav, 1 for driver
static var team: int = 0
static var NAV: int = 0
static var DRIVER: int = 1

signal fringe_changed
