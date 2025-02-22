extends Node

@export var music_tracks : Dictionary
#@export var asp : AudioStreamPlayer
var audio_players = []

func play_music(track:AudioStreamSynchronized, fade_in: float):
	var asp = AudioStreamPlayer.new()
	asp.bus = &"Music"
	asp.stream = track
	asp.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_players.append(asp)
	add_child(asp)
	if audio_players.size() > 1:
		fade_out(2)
	fade_in(fade_in)
	asp.volume_db = -80
	asp.stream.set_sync_stream_volume(1, -60)
	asp.play()

func crossfade_sync_streams(from:int=0, to:int=1, duration:float=0.2):
	if audio_players[0].stream.get_stream_count() > 1:
		var tween = get_tree().create_tween().parallel()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(audio_players[0].stream, "stream_"+str(from)+"/volume", -80, duration)
		tween.tween_property(audio_players[0].stream, "stream_"+str(to)+"/volume", 0, duration)

func change_volume(volume:float):
	var tween = get_tree().create_tween()
	tween.tween_property(audio_players[0], "volume_db", volume, 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(tween.kill)

func eq_music(value:bool):
	var index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_effect_enabled(index, 0, value)

func stop_music():
	for asp in audio_players:
		asp.stop()

func fade_out(duration:float):
	var tween = get_tree().create_tween()
	tween.tween_property(audio_players[0], "volume_db", -80, duration).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(audio_players[0].stop)
	tween.tween_callback(delete_player)

func fade_in(duration:float):
	var index = 0
	if audio_players.size() > 1:
		index = 1
	else:
		index = 0
	var tween = get_tree().create_tween()
	tween.tween_property(audio_players[index], "volume_db", 0.0, duration).set_trans(Tween.TRANS_CUBIC)

func delete_player():
	audio_players[0].queue_free()
	audio_players.remove_at(0)
