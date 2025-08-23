extends Node2D

signal start1v1
signal start2v2

func _on_v_1_pressed() -> void:
	if Globals.is_2v2:
		emit_signal("start2v2")
	else:
		emit_signal("start1v1")


func _on_v_2_pressed() -> void:
	pass
