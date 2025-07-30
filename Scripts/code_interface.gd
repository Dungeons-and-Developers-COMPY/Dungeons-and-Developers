extends Control

signal run_button_pressed
signal submit

var code: String = ""
var question: String = ""
var console_text: String = ""
var moving_code: String = ""
var on_monster: bool = false

@onready var question_box = $QuestionText
@onready var console = $ConsoleText
@onready var run_button = $RunButton
@onready var code_edit = $CodeEdit

func set_moving():
	question_box.text = Globals.MOVING_TEXT
	code_edit.text = moving_code

func _on_run_button_pressed() -> void:
	code = code_edit.text
	print("Run button pressed")
	if on_monster:
		emit_signal("submit")
	else:
		emit_signal("run_button_pressed")
	
func disable_code():
	code_edit.editable = false
	run_button.disabled = true
	
func enable_code():
	code_edit.editable = true
	run_button.disabled = false
	
func output_to_console(text: String):
	if console.text == "":
		console.text = text
	else:
		console.text = console.text + "\n" + text

func show_question(title: String, promt: String):
	moving_code = code_edit.text
	question_box.text = promt
	
func hit_monster():
	on_monster = true
	
func defeated_monster():
	on_monster = false
