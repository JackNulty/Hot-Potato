extends KinematicBody

export var target = Vector3.ZERO
export(float) var gravity = -30
export(float) var max_speed = 3
export(float) var acceleration = 20
export(float) var damage = 1.0


var _velocity = Vector3.ZERO
var _player = null
var _player_within_damage_range = false


#-------------------------------------------------------------------------------
func _physics_process(delta):
	_velocity.y += gravity * delta
	
	if _player:
		target = _player.transform.origin
	
	var direction = (target - global_transform.origin).normalized()
	_velocity += direction * acceleration * delta
	
	var horizontal_vel = Vector2(_velocity.x, _velocity.z)
	if horizontal_vel.length_squared() > max_speed * max_speed:
		horizontal_vel = horizontal_vel.normalized() * max_speed
		_velocity.x = horizontal_vel.x
		_velocity.z = horizontal_vel.y
		
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	if _player_within_damage_range and _player:
		_player.damage(damage)


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
		_player.damage(damage)


#-------------------------------------------------------------------------------
func _on_PlayerDamager_body_exited(body):
	if body.is_in_group("player"):
		_player_within_damage_range = false


#-------------------------------------------------------------------------------
