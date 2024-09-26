extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$pauseMenu.visible = false
	$"FPS counter".visible = false
	print("pause menu script loaded")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Opens pause menu
	if Input.is_action_just_pressed("quit") and globalVar.pauseMenuOpen == false:
		print("pause menu opened successfully")
		globalVar.pauseMenuOpen = true
		$pauseMenu.visible = true
		$pauseMenu/menuAnims.play("pauseguiSlideIn")
		globalVar.releaseMouse()
		
	else: if Input.is_action_just_pressed("quit") and globalVar.pauseMenuOpen == true:
		print("pause menu closed successfully")
		globalVar.pauseMenuOpen = false
		$pauseMenu.visible = false
		$pauseMenu/menuAnims.stop()
		$pauseMenu/confirmQuitAnims.stop()
		globalVar.captureMouse()
	pass
