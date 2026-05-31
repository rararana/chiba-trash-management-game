extends Control

@onready var menu_audio = $SettingOverlay/MenuAudio
@onready var menu_language = $SettingOverlay/MenuLanguage

func _ready():
	hide()
	menu_audio.show()
	menu_language.hide()

func _on_tombol_garis_3_pressed():
	menu_audio.hide()
	menu_language.show()

func _on_tombol_english_pressed():
	print("Bahasa berubah jadi English")
	menu_language.hide()
	menu_audio.show()

func _on_tombol_indonesia_pressed():
	print("Bahasa berubah jadi Indonesia")
	menu_language.hide()
	menu_audio.show()

func _on_setting_overlay_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hide()
