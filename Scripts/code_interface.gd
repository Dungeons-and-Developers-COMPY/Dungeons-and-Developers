extends Control

signal run_button_pressed

var code: String = ""
var question: String = ""
var console_text: String = ""

@onready var question_box = $QuestionText
@onready var console = $ConsoleText
@onready var run_button = $RunButton
@onready var code_edit = $CodeEdit


func _on_run_button_pressed() -> void:
	code = code_edit.text
	print("Run button pressed")
	emit_signal("run_button_pressed")
	
