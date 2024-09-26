extends Button

func _ready():
	$"/root/3dgamescene/gameUI/pauseMenu/pauseTab/fpsInput".set_value(globalVar.fpsLimit)
func _pressed():
	# Gets the fps limit through a direct root path
	globalVar.fpsLimit = $"/root/3dgamescene/gameUI/pauseMenu/pauseTab/fpsInput".get_value()
	
	# Makes another variable to store the fps limit locally in the script as godot does not
	# like when you use a global as an engine definition for some reason
	# like what the fuck man
	var fpsInput = globalVar.fpsLimit
	
	#Sets the global FPS limit variable to the input variable and prints it
	Engine.max_fps = fpsInput
	print("fps set to: " +str(globalVar.fpsLimit))
