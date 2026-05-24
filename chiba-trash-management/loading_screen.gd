extends Control

var progress_speed: float = 13.0
var current_value: float = 0.0

var next_scene_path: String = "res://BaseLevel.tscn" 

func _ready():
	current_value = 12.0
	$TextureProgressBar.value = current_value
	
	set_process(true) 

func _process(delta):
	current_value += progress_speed * delta
	
	$TextureProgressBar.value = current_value
	
	if current_value >= 100.0:
		current_value = 100.0
		$TextureProgressBar.value = current_value
		
		set_process(false) 
		print("LOADING SELESAI")
		#await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/base_level.tscn")
