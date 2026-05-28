extends Control

var next_scene_path: String = "res://BaseLevel.tscn" 

func _on_btn_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/base_level.tscn")


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
