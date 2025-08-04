extends Node2D

signal start1v1
signal start2v2

func _on_v_1_pressed() -> void:
	emit_signal("start1v1")


func _on_v_2_pressed() -> void:
	emit_signal("start2v2")
