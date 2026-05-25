extends Area2D

@export var item_data: Resource
@export var MAX_SIZE = 150.0
@export var min_y_boundary: float = 320.0
@onready var sprite: Sprite2D = %Sprite2D
@onready var collision: CollisionShape2D = %CollisionShape2D
var is_dragging: bool = false
var drop_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_event.connect(_on_input_event)
	if item_data:
		sprite.texture = item_data.item_texture # ini ntar buat dulu 
		_resize_item()
		_update_hitbox()
		
func _resize_item():
	var tex_size = sprite.texture.get_size()
	var max_side = max(tex_size.x, tex_size.y)
	if max_side > MAX_SIZE:
		var scale_factor = MAX_SIZE / max_side
		sprite.scale = Vector2(scale_factor, scale_factor)

func _update_hitbox():
	var new_shape = RectangleShape2D.new()
	new_shape.size = sprite.texture.get_size() * sprite.scale
	collision.shape = new_shape

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			z_index = 10
			get_viewport().set_input_as_handled()
			
			if drop_tween and drop_tween.is_valid():
				drop_tween.kill()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false
			z_index = 0
			_animate_drop()
			check_drop_zone()
			
func _animate_drop():
	drop_tween = create_tween()
	var target_pos = global_position + Vector2(0, 10)
	drop_tween.tween_property(self, "global_position", target_pos, 0.1) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
func check_drop_zone():
	pass		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		if mouse_pos.y < min_y_boundary: 
			mouse_pos.y = min_y_boundary
		global_position = mouse_pos
		
func apply_tool():
	if item_data.next_state:
		item_data = item_data.next_state
		sprite.texture = item_data.item_texture
		_update_hitbox()

func receive_tool(incoming_tool_id: String) -> bool:
	if not item_data:
		print("Debug: item_data kosong!")
		return false
	
	var req_tool = item_data.get("required_tool")
	
	if req_tool == "none" or req_tool == null:
		print("Debug: Item ini tidak membutuhkan tool.")
		return false
		
	if incoming_tool_id == req_tool:
		var next = item_data.get("next_state")
		if next:
			item_data = next
			sprite.texture = item_data.get("item_texture")
			_update_hitbox()
			print("Debug: [SUKSES] Berhasil menggunakan ", incoming_tool_id, ".")
			return true
		else:
			print("Debug: [WARNING] Tool benar, tapi next_state kosong.")
			return false
	else:
		print("Debug: [SALAH ALAT] Item ini butuh '", req_tool, "', bukan '", incoming_tool_id, "'.")
		return false
		
func is_trash() -> bool:
	return true
