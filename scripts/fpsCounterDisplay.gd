extends CheckButton

func _toggled(toggled_on):
	if toggled_on:
		$"/root/3dgamescene/gameUI/FPS counter".visible = true
	else:
		$"/root/3dgamescene/gameUI/FPS counter".visible = false
