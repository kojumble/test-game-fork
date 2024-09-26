extends Node

var pauseMenuOpen = false
var fpsLimit = 165

func _ready():
	Engine.max_fps = fpsLimit

func captureMouse():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var mouseModeVar = 1
	print("Captured Mouse")

func releaseMouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var mouseModeVar = 0
	print("Released Mouse")
