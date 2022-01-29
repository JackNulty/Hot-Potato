extends Node2D


var holding = null

onready var _equipped_sprite = get_node("Holdable")


func equip(holdable):
	# Drops the item being held if there is one.
	if holding:
		throw()
	
	# Equips the new holdable.
	holding = holdable.data
	_equipped_sprite.texture = holdable.get_image()
	holdable.queue_free()
	

func throw():
	# Throws "holding"
	pass


func use():
	# Uses "holding"
	pass
