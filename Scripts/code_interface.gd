# handles code_interface scene code. This includes submitting code to defeat monsters
# and running code for movement. Also displays the questions and writes logs to the console

extends Control

#region signals
signal run_button_pressed
signal submit_button_pressed(next_step: String)
signal test(next_step: String)
signal new_question
#endregion

#region variables
var code: String = ""
var question: String = ""
var console_text: String = ""
var moving_code: String = ""
var on_monster: bool = false
var input: String = ""
var num_submissions: int = 0

# syntax highlighting variables
var keyword_col : Color = Color.from_rgba8(255, 112, 133)
var control_flow_keyword_col : Color = Color(1, 0.55, 0.8)
var type_keyword_col : Color = Color(0.26, 1, 0.76)
var string_col : Color = Color.from_rgba8(255, 237, 161)
var python_keywords = [
	"False", "None", "True", "and", "as", "assert", "async", "class", 
	"def", "del", "except", "finally", "from", "global", "import", 
	"in", "is","lambda", "nonlocal", "not", "or",  "raise", "try",  
	"with", "yield"
]
var python_control_flow_keywords = [
	"if", "elif", "else", "for", "while", "break", 
	"continue", "await", "return", "pass"
]
var python_type_keywords = [
	"int", "float", "complex", "bool", "str", "bytes", "bytearray", 
	"memoryview", "list", "tuple", "set", "frozenset", "dict", "type"
]
#endregion

#region node references
@onready var question_label = $QuestionLabel
@onready var question_box = $QuestionText
@onready var console = $ConsoleText
@onready var run_button = $RunButton
@onready var submit_button = $SubmitButton 
@onready var code_edit = $CodeEdit
@onready var input_panel = $InputPanel
@onready var input_edit = $InputPanel/TextEdit
@onready var confirm_button = $InputPanel/ConfirmButton
@onready var new_question_button = $NewQuestionButton
#endregion


func _ready() -> void:
	for word in python_keywords:
		code_edit.syntax_highlighter.add_keyword_color(word, keyword_col)
	for word in python_control_flow_keywords:
		code_edit.syntax_highlighter.add_keyword_color(word, control_flow_keyword_col)
	for word in python_type_keywords:
		code_edit.syntax_highlighter.add_keyword_color(word, type_keyword_col)
	code_edit.syntax_highlighter.add_color_region("#", "", Color(0.5, 0.5, 0.5), false)
	code_edit.syntax_highlighter.add_color_region("\"", "\"", string_col)
	code_edit.syntax_highlighter.add_color_region("'", "'", string_col)

func set_moving():
	run_button.tooltip_text = "Click here to execute your movement code"
	question_box.text = Globals.MOVING_TEXT
	code_edit.text = moving_code
	question_label.text = "Traverse The Maze!"
	submit_button.hide()
	new_question_button.hide()

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

# displays the given question in the question box and sets code edit to the default function
func show_question(title: String, promt: String, question_num: int, new_question: bool = false):
	num_submissions = 0
	disable_new_question()
	run_button.tooltip_text = "Click here to test your code"
	if not new_question:
		moving_code = code_edit.text
	question_label.text = "Question " + str(question_num) + ": " + title
	question_box.text = promt
	code_edit.text = Globals.code_format
	submit_button.show()
	new_question_button.show()
	
func hit_monster():
	on_monster = true
	
func defeated_monster():
	on_monster = false

func _on_submit_button_pressed() -> void:
	code = code_edit.text
	emit_signal("submit_button_pressed", "SUBMIT")
	output_to_console("Submitting code...")

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

func _on_new_question_button_pressed() -> void:
	emit_signal("new_question")

func set_code():
	code = code_edit.text

func update_code_text(text: String):
	code_edit.text = text
