extends Node2D


var holding = null
var parent = null

onready var HoldableScene = preload("res://scenes/holdable.tscn")
onready var _equipped_sprite = get_node("Holdable")


func equip(holdable):
	# Drops the item being held if there is one.
	if holding:
		throw()
	
	# Equips the new holdable.
	holding = holdable.data
	_equipped_sprite.texture = holdable.get_2d_image()
	holdable.queue_free()
	

func throw():
	if holding:
		var holdable = HoldableScene.instance()
		holdable.data = holding
		holdable.global_transform = parent.global_transform
		#holdable.translation + parent.global_transform.basis.z * 5
		get_tree().root.add_child(holdable)
		holdable.set_texture()
		holding = null
		_equipped_sprite.texture = null
		#holdable.add_force(parent.global_transform.basis.z * 100, holdable.translation)


func use():
	# Uses "holding"
	pass
