extends Control

signal run_button_pressed
signal submit_button_pressed(next_step: String)
signal test(next_step: String)

var code: String = ""
var question: String = ""
var console_text: String = ""
var moving_code: String = ""
var on_monster: bool = false
var input: String = ""
var num_submissions: int = 0

@onready var question_box = $QuestionText
@onready var console = $ConsoleText
@onready var run_button = $RunButton
@onready var submit_button = $SubmitButton 
@onready var code_edit = $CodeEdit
@onready var input_panel = $InputPanel
@onready var input_edit = $InputPanel/TextEdit
@onready var confirm_button = $InputPanel/ConfirmButton
@onready var new_question_button = $NewQuestionButton

func set_moving():
	question_box.text = Globals.MOVING_TEXT
	code_edit.text = moving_code
	submit_button.hide()

func _on_run_button_pressed() -> void:
	code = code_edit.text
	print("Run button pressed")
	if on_monster:
		show_input_panel()
		disable_code()
		#emit_signal("test")
		#output_to_console("Compiling code...")
	else:
		emit_signal("run_button_pressed")
	
func disable_code():
	code_edit.editable = false
	run_button.disabled = true
	submit_button.disabled = true
	
func enable_code():
	code_edit.editable = true
	run_button.disabled = false
	submit_button.disabled = false
	
func output_to_console(text: String):
	if console.text == "":
		console.text = text
	else:
		console.text = console.text + "\n" + text

func show_question(title: String, promt: String):
	num_submissions = 0
	disable_new_question()
	moving_code = code_edit.text
	question_box.text = promt
	code_edit.text = Globals.code_format
	submit_button.show()
	
func hit_monster():
	on_monster = true
	
func defeated_monster():
	on_monster = false

func _on_submit_button_pressed() -> void:
	code = code_edit.text
	emit_signal("submit_button_pressed", "SUBMIT")

func show_input_panel():
	input_panel.show()
	
func hide_input_panel():
	input_panel.hide()

func _on_confirm_button_pressed() -> void:
	input = input_edit.text
	emit_signal("test", "TEST")
	output_to_console("Compiling code...")
	hide_input_panel()
	enable_code()

func enable_new_question():
	new_question_button.disabled = false
	
func disable_new_question():
	new_question_button.disabled = true
