extends Area2D

@export var item_data: Resource
@export var MAX_SIZE = 150.0
@export var min_y_boundary: float = 320.0
@onready var sprite: Sprite2D = %Sprite2D
@onready var collision: CollisionShape2D = %CollisionShape2D
@onready var start_global_pos: Vector2 = global_position
var is_dragging: bool = false
var drop_tween: Tween

func _ready() -> void:
	input_event.connect(_on_input_event)
	if item_data:
		sprite.texture = item_data.item_texture 
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
			start_global_pos = global_position
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
			check_drop_zone()
			
func _animate_drop():
	drop_tween = create_tween()
	var target_pos = global_position + Vector2(0, 10)
	drop_tween.tween_property(self, "global_position", target_pos, 0.1) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
func check_drop_zone():
	var overlapping_areas = get_overlapping_areas()
	var success = false
	var rejected_by_tray = false
	
	for area in overlapping_areas:
		if area.has_method("receive_dropped_object"):
			if area.receive_dropped_object(self):
				success = true
				_shrink_and_free()
				break
				
		elif area.has_method("receive_trash"):
			if area.receive_trash(item_data): 
				success = true
				_shrink_and_free()
				break
				
		elif area.has_method("store_object"):
			if area.store_object(self):
				success = true
				break
			else:
				rejected_by_tray = true
				break
				
	if not success:
		if rejected_by_tray:
			if drop_tween and drop_tween.is_valid():
				drop_tween.kill()
			global_position = start_global_pos
		else:
			_animate_drop()

func _shrink_and_free():
	input_pickable = false 
	if drop_tween and drop_tween.is_valid():
		drop_tween.kill()
		
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.125).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

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
		return false
	
	var req_tool = item_data.get("required_tool")
	
	if req_tool == "none" or req_tool == null:
		return false
		
	if incoming_tool_id == req_tool:
		var next = item_data.get("next_state")
		if next:
			item_data = next
			sprite.texture = item_data.get("item_texture")
			_update_hitbox()
			return true
		else:
			return false
	else:
		return false
		
func is_trash() -> bool:
	return true
