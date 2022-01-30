extends Spatial

#-----------------------------------------------------------------------
# startup volume control
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0) # change the number value to adjust the sfx volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -12) # change the number value to adjust the music volume
#-----------------------------------------------------------------------
# makes player sfx and music follow player
func _process(_delta):
	var player = get_tree().get_nodes_in_group("player") [0]
	$sfx/PlayerSFX.translation.x = player.translation.x
	$sfx/PlayerSFX.translation.y = player.translation.y
	$sfx/PlayerSFX.translation.z = player.translation.z
	$music/Music.translation.x = player.translation.x
	$music/Music.translation.y = player.translation.y
	$music/Music.translation.z = player.translation.z
#-----------------------------------------------------------------------
# player running audio
func player_run(playerrun : AudioStream):
	if not $sfx/PlayerSFX.is_playing():
		$sfx/PlayerSFX.stream = playerrun
		$sfx/PlayerSFX.play()
		
func stop_player_run():
	$sfx/PlayerSFX.stop()	
#-----------------------------------------------------------------------
# player item pickup audio
func player_itempickup(itempickup : AudioStream):
	$sfx/PlayerSFX.stream = itempickup
	$sfx/PlayerSFX.play()
#-----------------------------------------------------------------------
# player item drop audio
func player_itemdrop(itemdrop : AudioStream):
	$sfx/PlayerSFX.stream = itemdrop
	$sfx/PlayerSFX.play()
#-----------------------------------------------------------------------
# music player
func music_player(music : AudioStream):
	$music/Music.stream = music
	$music/Music.play()
