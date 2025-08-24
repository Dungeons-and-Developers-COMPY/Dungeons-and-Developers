# this script attaches to music streams and ensures the music loops on completion
extends AudioStreamPlayer

func _ready():
	connect("finished", Callable(self, "_on_finished"))
	
func _on_finished():
	play()            
