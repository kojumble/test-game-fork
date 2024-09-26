extends CharacterBody3D

var speedMax: float = 10.0
var speedAccel: float = 7.0
var speedDecel: float = 14.0
var speedDecelAir: float = 3.0
var jumpVelocity: float = 4.5

var mouseSens: float = 0.002
var sensMod: float = 1.0
var zoomIncrament: float = 1.0

@onready var cameraRotation = $guyCamRot
@onready var camera = $guyCamRot/guyCam
@onready var plr = $"."

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	globalVar.captureMouse()
pass

func _input(event):
	if Input.is_key_pressed(KEY_Z):
		camera.position.z = 0
		
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if camera.position.z <= 7 and camera.position.z >= 1:
			if Input.is_action_just_released("scrollDown"):
				camera.translate(Vector3(0, 0, +zoomIncrament))
			if Input.is_action_just_released("scrollUp"):
				camera.translate(Vector3(0, 0, -zoomIncrament))
		else: if camera.position.z < 1:
			if Input.is_action_just_released("scrollDown"):
				camera.translate(Vector3(0, 0, +zoomIncrament))
		else: if camera.position.z > 7:
			if Input.is_action_just_released("scrollUp"):
				camera.translate(Vector3(0, 0, -zoomIncrament))
				# camera.position.z = lerp(camera.position.z - zoomIncrament, 0.0, 0.0)
			
		if event is InputEventMouseMotion:
			plr.rotate_y(-event.relative.x * mouseSens * sensMod)
			cameraRotation.rotate_x(-event.relative.y * mouseSens * sensMod)
			cameraRotation.rotation.x = clamp(cameraRotation.rotation.x, deg_to_rad(-85), deg_to_rad(89))
			
pass

func _physics_process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handles jumping
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jumpVelocity

		# Get the input direction and handle the movement
		var inputDir = Input.get_vector("left", "right", "forward", "back")
		var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speedMax, speedAccel * delta)
			velocity.z = lerp(velocity.z, direction.z * speedMax, speedAccel * delta)
		else: if not is_on_floor():
			velocity.x = lerpf(velocity.x, 0, speedDecelAir * delta)
			velocity.z = lerpf(velocity.z, 0, speedDecelAir * delta)
		else:
			velocity.x = lerpf(velocity.x, 0, speedDecel * delta)
			velocity.z = lerpf(velocity.z, 0, speedDecel * delta)
			
		move_and_slide()
	pass
