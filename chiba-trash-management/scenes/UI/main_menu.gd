extends Control

@onready var setting_menu = $SettingMenu

func _on_btn_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/story_sequence.tscn")

func _on_btn_setting_pressed() -> void:
	setting_menu.show()

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
