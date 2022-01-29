extends Node


var data = {
	type = "sword",
	image_path = "res://assets/images/sword_2d.png"
}


func get_data():
	return load(data.image_path)


func get_image():
	return load(data.image_path)


func use():
	pass
