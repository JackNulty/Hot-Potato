extends Node2D

signal win_item_picked_up

var holding = null
var parent = null

onready var HoldableScene = preload("res://scenes/holdable.tscn")
onready var _equipped_sprite = get_node("Holdable")


#-------------------------------------------------------------------------------
func equip(holdable):
	# Drops the item being held if there is one.
	if holding:
		throw()
	
	# Equips the new holdable.
	holding = holdable.data
	_equipped_sprite.texture = holdable.get_2d_image()
	holdable.queue_free()
	
	if holding.type == "win_item":
		emit_signal("win_item_picked_up")
	

#-------------------------------------------------------------------------------
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


#-------------------------------------------------------------------------------
func use():
	if holding:
		match holding.type:
			"sword":
				parent.damage_all_within_range(holding.damage)
				
			"key":
				pass
	

#-------------------------------------------------------------------------------
