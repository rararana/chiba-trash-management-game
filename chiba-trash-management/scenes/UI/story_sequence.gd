extends VideoStreamPlayer

var save_path = "user://save_data.cfg" 

func _ready():
	var config = ConfigFile.new()
	var file_ditemukan = config.load(save_path)
	
	if file_ditemukan == OK and config.get_value("Story", "udah_nonton_intro", false) == true:
		get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")
	else:
		pass

func _on_finished():
	var config = ConfigFile.new()
	config.set_value("Story", "udah_nonton_intro", true)
	config.save(save_path)
	
	get_tree().change_scene_to_file("res://scenes/UI/loading_screen.tscn")
