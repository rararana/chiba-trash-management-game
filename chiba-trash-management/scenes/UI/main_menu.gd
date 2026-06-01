extends Control

@onready var setting_menu = $SettingMenu
@onready var BGM = $BGM

func _ready() -> void:
	BGM.play()

func _on_btn_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/story.tscn")

func _on_btn_setting_pressed() -> void:
	setting_menu.show()

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
