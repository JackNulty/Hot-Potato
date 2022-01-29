extends Spatial

# startup volume control
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0) # change the 0 to adjust the sfx volume

#-----------------------------------------------------------------------
# player running controls
func player_run(run : AudioStream):
	if not $sfx/PlayerRun.is_playing():
		$sfx/PlayerRun.stream = run
		$sfx/PlayerRun.play()
		
func stop_player_run():
	$sfx/PlayerRun.stop()
	
func _process(_delta):
	var player = get_tree().get_nodes_in_group("player") [0]
	$sfx/PlayerRun.translation.x = player.translation.x
	$sfx/PlayerRun.translation.y = player.translation.y
	$sfx/PlayerRun.translation.z = player.translation.z
#-----------------------------------------------------------------------
