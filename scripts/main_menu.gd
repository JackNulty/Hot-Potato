extends Control



func _on_PlayButton_pressed():
	if get_tree().change_scene("res://scenes/gameplay.tscn") != OK:
		print("Error switching from Main Menu to Gameplay.")


func _on_ExitButton_pressed():
	get_tree().quit()
