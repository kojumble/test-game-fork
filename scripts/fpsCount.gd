extends Label

func _process(delta: float) -> void:
	# Sets the text box to a string followed by the current frames per second read from the engine
	set_text("FPS: %d" % Engine.get_frames_per_second())
pass
