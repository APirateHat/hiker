extends Node

var audio_players = []
var audio_players_2d = []

func play_audio(audio_file:Resource, volume:float=0.0, random_pitch:bool=true, pitch:float=1.0):
	var asp = AudioStreamPlayer.new()
	asp.bus = &"SFX"
	audio_players.append(asp)
	add_child(asp)
	asp.stream = audio_file
	asp.volume_db = volume
	if random_pitch:
		asp.pitch_scale = randf_range(0.8, 1.3)
	else:
		asp.pitch_scale = pitch
	asp.play()
	clear_audio_streams()

func play_audio_2d(audio_file:Resource, audio_position:Vector2, volume:float=0.0, random_pitch:bool=true, pitch:float=1.0):
	var asp = AudioStreamPlayer2D.new()
	asp.bus = &"SFX"
	audio_players_2d.append(asp)
	add_child(asp)
	asp.position = audio_position
	asp.stream = audio_file
	asp.volume_db = volume
	if random_pitch:
		asp.pitch_scale = randf_range(0.8, 1.3)
	else:
		asp.pitch_scale = pitch
	asp.play()
	clear_audio_streams_2d()
	
func clear_audio_streams():
	if audio_players.size() > 4:
		audio_players[0].queue_free()
		audio_players.remove_at(0)

func clear_audio_streams_2d():
	if audio_players_2d.size() > 4:
		audio_players_2d[0].queue_free()
		audio_players_2d.remove_at(0)
