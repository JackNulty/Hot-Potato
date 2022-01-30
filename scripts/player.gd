extends KinematicBody

signal died

export(float) var gravity = -30
export(float) var max_speed = 4
export(float) var acceleration = 12
export(float) var deceleration = 8
export(float) var jump_speed = 15
export(float) var mouse_sensitivity = 0.002  # radians/pixel
export(float) var max_health = 5.0
export(float) var damage_cooldown = 1.0

# preloads for audio effects
onready var playerwalk : AudioStream = preload("res://assets/audio/sfx/Walk1.wav")
onready var playerrun : AudioStream = preload("res://assets/audio/sfx/Run2.wav")
onready var playeritempickup : AudioStream = preload("res://assets/audio/sfx/ItemPickup1.wav")
onready var playeritemdrop : AudioStream = preload("res://assets/audio/sfx/ItemDrop1.wav")
onready var music : AudioStream = preload("res://assets/audio/music/MusicLoop.wav")

onready var _camera = get_node("RotationHelper/Camera")
onready var _rotation_helper = get_node("RotationHelper")
onready var _damage_cooldown_timer = get_node("DamageCooldown")

onready var _left_hand = get_node("CanvasLayer/LeftHand")
onready var _right_hand = get_node("CanvasLayer/RightHand")

onready var _health_bar = get_node("CanvasLayer/HealthBar")
onready var _health_bar_fill = get_node("CanvasLayer/HealthBar/Fill")

var _velocity = Vector3()
var _health
var _enemies_in_range = []

#-------------------------------------------------------------------------------
# Runs when this script loads in a scene.
func _ready():
	# Hides the player's shape, we only use it to see the player in the editor.
	$DebugVisual.hide()
	
	# Captures the mouse cursor.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_left_hand.parent = self
	_right_hand.parent = self
	
	_health = max_health
	AudioManager.music_player(music)
	

#-------------------------------------------------------------------------------
# Handles input as soon as it's available.
func _input(event):
	# Quits the game.
	if event.is_action_pressed("quit"):
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$CanvasLayer/PauseMenu.show()
	
	# If the cursor isn't captured, captures it and handles the input.
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().set_input_as_handled()
	
	# Throws the item in either hand if the throw button was pressed.
	if event.is_action_pressed("throw_left"):
		_left_hand.throw()
		AudioManager.player_itemdrop(playeritemdrop)
	if event.is_action_pressed("throw_right"):
		_right_hand.throw()
		AudioManager.player_itemdrop(playeritemdrop)
		
	if event.is_action_pressed("use_left"):
		_left_hand.use()
	if event.is_action_pressed("use_right"):
		_right_hand.use()


#-------------------------------------------------------------------------------
# If the input has not been handled (used up) elsewhere, handle it here.
func _unhandled_input(event):
	
	# If the event is mouse movement and the mouse is captured by the game.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		# Rotates the camera - kinda complex, ignore it if possible.
		_rotation_helper.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		_rotation_helper.rotation.x = clamp(_rotation_helper.rotation.x, -1.2, 1.2)


#-------------------------------------------------------------------------------
# Runs (usually) at a fixed 60 frames per second.
func _physics_process(delta):
	# Applies the gravity * time since last frame. This smooths out the movement
	# 		even if lag occurs.
	_velocity.y += gravity * delta
	
	# Gets the player input as a movement vector (method defined below). 
	var input = get_movement_input()
	
	if input.length_squared() != 0.0:
		AudioManager.player_run(playerrun)
	else:
		AudioManager.stop_player_run()
	
	# Works out the acceleration and deceleration/friction, a little complex.
	var acceleration_vector = input * acceleration * delta
	var deceleration_vector = (Vector3.ONE - Vector3(abs(input.x), 1.0, abs(input.z))) * deceleration * delta
	
	var horizontal_velocity = Vector3(_velocity.x, 0.0, _velocity.z)
	horizontal_velocity.x += acceleration_vector.x - (horizontal_velocity.normalized().x * deceleration_vector.x)
	horizontal_velocity.z += acceleration_vector.z - (horizontal_velocity.normalized().z * deceleration_vector.z)

	if horizontal_velocity.project(input).length() > max_speed:
		horizontal_velocity = horizontal_velocity.normalized() * max_speed
	
	_velocity.x = horizontal_velocity.x
	_velocity.z = horizontal_velocity.z
	_velocity = move_and_slide(_velocity, Vector3.UP, true)
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			_velocity.y = jump_speed

	if _velocity.y > 1:
		_velocity.y -= 1 * delta # 1 is air friction


#-------------------------------------------------------------------------------
func get_movement_input():
	var input_dir = Vector3.ZERO

	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += global_transform.basis.x
		
	input_dir = input_dir.normalized()
	return input_dir


#-------------------------------------------------------------------------------
func _on_PickupArea_body_entered(body):
	if body.is_in_group("holdable") and not body.locked: 
		
		# If not holding something in the right hand, equip the holdable there.
		if not _right_hand.holding:
			_right_hand.equip(body)
			AudioManager.player_itempickup(playeritempickup)
		
		# If not holding something in the left hand, equip the holdable there.
		elif not _left_hand.holding:
			_left_hand.equip(body)
			AudioManager.player_itempickup(playeritempickup)


#-------------------------------------------------------------------------------
func damage(amount):
	# If the damage cooldown has expired and there's still health left.
	if _damage_cooldown_timer.is_stopped() and _health > 0:
		_health -= amount
		
		# Starts the damage cooldown timer.
		_damage_cooldown_timer.start(damage_cooldown)
		
		# Checks if the character has died and prints it out if so.
		if _health <= 0:
			_health = 0
			emit_signal("died")
		
		var health_percent = _health / max_health
		
		if health_percent < 0.333:
			$CanvasLayer/LeftHand/Hand.frame = 2
			$CanvasLayer/RightHand/Hand.frame = 2
			
		elif health_percent < 0.666:
			$CanvasLayer/LeftHand/Hand.frame = 1
			$CanvasLayer/RightHand/Hand.frame = 1
			
		_health_bar_fill.rect_size.x = _health_bar.rect_size.x * health_percent


#-------------------------------------------------------------------------------
func damage_all_within_range(damage_amount):
	for enemy in _enemies_in_range:
		enemy.damage(damage_amount)


#-------------------------------------------------------------------------------
func _on_DamageArea_body_entered(body):
	if body.is_in_group("enemy"):
		_enemies_in_range.append(body)


#-------------------------------------------------------------------------------
func _on_DamageArea_body_exited(body):
	if body.is_in_group("enemy"):
		_enemies_in_range.erase(body)


#-------------------------------------------------------------------------------
func _on_win_item_picked_up():
	$CanvasLayer/WinText.show()


#-------------------------------------------------------------------------------
func _on_ResumeButton_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CanvasLayer/PauseMenu.hide()


#-------------------------------------------------------------------------------
func _on_ExitButton_pressed():
	get_tree().paused = false
	if get_tree().change_scene("res://scenes/main_menu.tscn") != OK:
		print("Error switching from Gameplay to Main Menu.")


#-------------------------------------------------------------------------------
