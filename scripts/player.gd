extends KinematicBody

export(float) var gravity = -30
export(float) var max_speed = 4
export(float) var acceleration = 12
export(float) var deceleration = 8
export(float) var jump_speed = 15
export(float) var mouse_sensitivity = 0.002  # radians/pixel

# preloads for audio effects
onready var playerwalk : AudioStream = preload("res://assets/audio/sfx/Walk1.wav")
onready var playerrun : AudioStream = preload("res://assets/audio/sfx/Run2.wav")

onready var camera = get_node("RotationHelper/Camera")
onready var rotation_helper = get_node("RotationHelper")

var velocity = Vector3()

#-------------------------------------------------------------------------------
# Runs when this script loads in a scene.
func _ready():
	# Hides the player's shape, we only use it to see the player in the editor.
	$DebugVisual.hide()
	
	# Captures the mouse cursor.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#-------------------------------------------------------------------------------
# Handles input as soon as it's available.
func _input(event):
	# Quits the game.
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	# If the cursor isn't captured, captures it and handles the input.
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()


#-------------------------------------------------------------------------------
# If the input has not been handled (used up) elsewhere, handle it here.
func _unhandled_input(event):
	
	# If the event is mouse movement and the mouse is captured by the game.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		# Rotates the camera - kinda complex, ignore it if possible.
		rotation_helper.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_helper.rotation.x = clamp(rotation_helper.rotation.x, -1.2, 1.2)


#-------------------------------------------------------------------------------
# Runs (usually) at a fixed 60 frames per second.
func _physics_process(delta):
	# Applies the gravity * time since last frame. This smooths out the movement
	# 		even if lag occurs.
	velocity.y += gravity * delta
	
	# Gets the player input as a movement vector (method defined below). 
	var input = get_movement_input()
	
	if input.length_squared() != 0.0:
		AudioManager.player_run(playerrun)
	else:
		AudioManager.stop_player_run()
	
	# Works out the acceleration and deceleration/friction, a little complex.
	var acceleration_vector = input * acceleration * delta
	var deceleration_vector = (Vector3.ONE - Vector3(abs(input.x), 1.0, abs(input.z))) * deceleration * delta
	
	var horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	horizontal_velocity.x += acceleration_vector.x - (horizontal_velocity.normalized().x * deceleration_vector.x)
	horizontal_velocity.z += acceleration_vector.z - (horizontal_velocity.normalized().z * deceleration_vector.z)

	if horizontal_velocity.project(input).length() > max_speed:
		horizontal_velocity = horizontal_velocity.normalized() * max_speed
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed

	if velocity.y > 1:
		velocity.y -= 1 * delta # 1 is air friction


#-------------------------------------------------------------------------------
func get_movement_input():
	var input_dir = Vector3.ZERO

	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -camera.global_transform.basis.z
		#print(translation)
		
	if Input.is_action_pressed("move_backwards"):
		input_dir += camera.global_transform.basis.z
		
	if Input.is_action_pressed("strafe_left"):
		input_dir += -camera.global_transform.basis.x
				
	if Input.is_action_pressed("strafe_right"):
		input_dir += camera.global_transform.basis.x
		
	input_dir = input_dir.normalized()
	return input_dir


#-------------------------------------------------------------------------------
