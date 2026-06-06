extends CanvasLayer
@export var setting_menu: PackedScene

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused == false:
			get_tree().paused = true
			show()
		else:
			get_tree().paused = false
			hide()

func _on_resume_btn_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_setting_btn_pressed() -> void:
	if setting_menu:
		var wadah_canvas = CanvasLayer.new()
		wadah_canvas.layer = 100
		wadah_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
		get_parent().add_child(wadah_canvas)
		
		var setting_muncul = setting_menu.instantiate()
		wadah_canvas.add_child(setting_muncul)
		
		setting_muncul.show()
		
		setting_muncul.hidden.connect(func():
			show()
			wadah_canvas.queue_free()
		)
		
		hide()

func _on_quit_btn_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
