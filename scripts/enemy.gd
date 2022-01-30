extends KinematicBody

signal died

export var target = Vector3.ZERO
export(float) var gravity = -30
export(float) var max_speed = 3
export(float) var acceleration = 20
export(float) var attack_damage = 1.0
export(float) var max_health = 1.0
export(float) var damage_cooldown = 1.0

onready var _damage_cooldown_timer = get_node("DamageCooldown")

var _velocity = Vector3.ZERO
var _player = null
var _player_within_damage_range = false
var _health


#-------------------------------------------------------------------------------
func _ready():
	_health = max_health
	
	
#-------------------------------------------------------------------------------
func _physics_process(delta):
	# Applies gravity.
	_velocity.y += gravity * delta
	
	# Gets the player's position if within range of the player.
	if _player:
		target = _player.transform.origin
	
	# Accelerates in the direction of the target.
	var direction = (target - global_transform.origin).normalized()
	_velocity += direction * acceleration * delta
	
	# Caps non vertical speed to a max speed.
	var horizontal_vel = Vector2(_velocity.x, _velocity.z)
	if horizontal_vel.length_squared() > max_speed * max_speed:
		horizontal_vel = horizontal_vel.normalized() * max_speed
		_velocity.x = horizontal_vel.x
		_velocity.z = horizontal_vel.y
	
	# Moves by the velocity.
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	# Damages the player if still within range.
	if _player_within_damage_range and _player:
		_player.damage(attack_damage)


#-------------------------------------------------------------------------------
func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("player"):
		_player = body


#-------------------------------------------------------------------------------
func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("player"):
		_player = null


#-------------------------------------------------------------------------------
func _on_PlayerDamager_body_entered(body):
	if body.is_in_group("player"):
		_player_within_damage_range = true
		_player.damage(attack_damage)


#-------------------------------------------------------------------------------
func _on_PlayerDamager_body_exited(body):
	if body.is_in_group("player"):
		_player_within_damage_range = false


#-------------------------------------------------------------------------------
func damage(amount):
	# If the damage cooldown has expired and there's still health left.
	if _damage_cooldown_timer.is_stopped() and _health > 0:
		_health -= amount
		
		# Starts the damage cooldown timer.
		_damage_cooldown_timer.start(damage_cooldown)
		$BloodParticles.emitting = true
		
		# Checks if the character has died and prints it out if so.
		if _health <= 0:
			_health = 0
			emit_signal("died")
			queue_free()
		
		
#-------------------------------------------------------------------------------
		
