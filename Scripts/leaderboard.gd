extends Node2D

@onready var tree: Tree = $Panel/Tree
@onready var time_label: Label = $Panel/TimeLabel
@onready var rank_label: Label = $Panel/RankLabel

func add_output(list):
	set_player_stat("N/A", "N/A")
	tree.clear()
	var root = tree.create_item()
	tree.set_column_titles_visible(true)
	tree.set_column_title(0, "Rank")
	tree.set_column_title(1, "Username")
	tree.set_column_title(2, "Time")
	
	var rank: int = 0
	for i in list:
		print(i)
		rank += 1
		if str(i["username"]) == Globals.username:
			set_player_stat(rank, str(i["time_taken"]))
		var row = tree.create_item(root)
		row.set_text(0, str(rank))
		row.set_text(1, str(i["username"]))
		row.set_text(2, str(i["time_taken"]))
		row.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
		row.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
		row.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)

func _on_button_pressed() -> void:
	hide()

func set_player_stat(rank, time):
	rank_label.text = "Your Rank: " + str(rank)
	time_label.text = "Best Time: " + time
