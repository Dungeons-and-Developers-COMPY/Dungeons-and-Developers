extends Node2D

@onready var output: RichTextLabel = $Panel/RichTextLabel

func add_output(list):
	output.clear()
	output.append_text("RANK\t\tUSERNAME\t\tTIME")
	var rank: int = 0
	for i in list:
		rank+= 1
		output.append_text(str(rank) + "\t\t" + i["username"] + "\t\t" + i["time_taken"])

func _on_button_pressed() -> void:
	hide()
