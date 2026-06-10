extends Control

@onready var menu_audio = $SettingOverlay/MenuAudio
@onready var menu_language = $SettingOverlay/MenuLanguage

var master_bus_index: int

func _ready():
	hide()
	menu_audio.show()
	menu_language.hide()
	
	master_bus_index = AudioServer.get_bus_index("Master")
	
func _on_h_slider_value_changed(value: float) -> void:
	var volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus_index, volume_db)

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
