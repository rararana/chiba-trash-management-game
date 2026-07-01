extends Control

@onready var menu_audio = $SettingOverlay/MenuAudio
@onready var menu_language = $SettingOverlay/MenuLanguage
@onready var slider_music = $SettingOverlay/MenuAudio/HBoxMusic/TextureRect/HSlider
@onready var slider_sfx = $SettingOverlay/MenuAudio/HBoxSound/TextureRect/HSlider

var bgm_bus_index: int
var sfx_bus_index: int

func _ready():
	hide()
	menu_audio.show()
	menu_language.hide()
	
	bgm_bus_index = AudioServer.get_bus_index("BGM")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	# MUSIC (Skala 0 - 1) -> Nggak perlu diapa-apain
	var volume_sekarang_db = AudioServer.get_bus_volume_db(bgm_bus_index)
	slider_music.set_value_no_signal(db_to_linear(volume_sekarang_db))
	
	# SFX (Skala 0 - 100) -> WAJIB DIKALI 100 BIAR SLIDERNYA NGERTI
	if slider_sfx != null:
		var volume_sfx_db = AudioServer.get_bus_volume_db(sfx_bus_index)
		slider_sfx.set_value_no_signal(db_to_linear(volume_sfx_db) * 100.0)

func _on_h_slider_value_changed(value: float) -> void:
	var volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(bgm_bus_index, volume_db)
	
	if GameManager.has_method("save_audio"):
		GameManager.save_audio()

func _on_sfx_slider_value_changed(value: float) -> void:
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(sfx_bus_index, volume_db)
	
	if GameManager.has_method("save_audio"):
		GameManager.save_audio()

func _on_tombol_garis_3_pressed():
	menu_audio.hide()
	menu_language.show()

func _on_tombol_english_pressed():
	TranslationServer.set_locale("en") 
	menu_language.hide()
	menu_audio.show()

func _on_tombol_indonesia_pressed():
	TranslationServer.set_locale("id") 
	menu_language.hide()
	menu_audio.show()

func _on_setting_overlay_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hide()
