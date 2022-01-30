extends RigidBody

var locked = true
export var data = {
	type = "sword",
	image_2d_path = "res://assets/images/sword_2d.png",
	image_3d_path = "res://assets/images/sword.png",
}

onready var _sprite = get_node("Sprite3D")

#-------------------------------------------------------------------------------
func _ready():
	set_texture()
	
	
#-------------------------------------------------------------------------------
func get_data():
	return load(data.image_path)


#-------------------------------------------------------------------------------
func get_2d_image():
	return load(data.image_2d_path)
	

#-------------------------------------------------------------------------------
func get_3d_image():
	return load(data.image_3d_path)


#-------------------------------------------------------------------------------
func set_texture():
	_sprite.texture = get_3d_image()


#-------------------------------------------------------------------------------
func _on_Timer_timeout():
	locked = false


#-------------------------------------------------------------------------------
