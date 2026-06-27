extends Button

var posisi_awal_y: float

func _ready() -> void:
	posisi_awal_y = position.y

func _on_mouse_entered() -> void:
	if not is_pressed():
		position.y = posisi_awal_y + 10

func _on_mouse_exited() -> void:
	if not is_pressed():
		position.y = posisi_awal_y

func _on_button_down() -> void:
	position.y = posisi_awal_y + 25

func _on_button_up() -> void:
	if is_hovered():
		position.y = posisi_awal_y + 10
	else:
		position.y = posisi_awal_y
