extends Spatial

func play_sfx(sfx : AudioStream):
	$sfx/SFX.stream = sfx
	$sfx/SFX.play()

func stop_sfx():
	$sfx/SFX.stop()
