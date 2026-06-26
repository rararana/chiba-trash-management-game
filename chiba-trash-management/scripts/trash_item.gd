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
	add_to_group("trash")
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
			var overlapping = get_overlapping_areas()
			for other in overlapping:
				if other.has_method("is_trash") and other.z_index > z_index:
					return
			
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
				if get_meta("is_storage_clone", false):
					var original = get_meta("original_node", null)
					if original and is_instance_valid(original):
						original.queue_free()
					queue_free()
				else:
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

func receive_tool(incoming_tool_id: String, drop_pos: Vector2 = global_position) -> bool:
	print("[TrashItem] receive_tool dipanggil dengan tool: ", incoming_tool_id)
	
	if not item_data:
		print("[TrashItem] GAGAL — item_data null")
		return false
	
	var req_tool = item_data.get("required_tool")
	print("[TrashItem] required_tool item ini: ", req_tool)
	
	if req_tool == "none" or req_tool == null:
		print("[TrashItem] GAGAL — item ini tidak butuh tool")
		return false
	
	if incoming_tool_id != req_tool:
		print("[TrashItem] GAGAL — tool tidak cocok (butuh: ", req_tool, ", dapat: ", incoming_tool_id, ")")
		return false
	
	if incoming_tool_id == "tie":
		var level = get_tree().get_first_node_in_group("level")
		if not level:
			print("[TrashItem] GAGAL — level tidak ditemukan")
			return false
		print("[TrashItem] Trigger tie di posisi tool: ", drop_pos)
		level.try_tie_at_position(drop_pos, 300.0)
		return true
	
	var next = item_data.get("next_state")
	if next:
		print("[TrashItem] Tool berhasil, transform ke next_state")
		item_data = next
		print("[TrashItem] next_state required_tool: ", item_data.get("required_tool"))
		print("[TrashItem] next_state is_stackable: ", item_data.get("is_stackable"))
		print("[TrashItem] next_state item_name: ", item_data.get("item_name"))
		sprite.texture = item_data.get("item_texture")
		_update_hitbox()
		# flash biru tanda berhasil di-sponge
		# TODO: adjust efek kalo kena
		modulate = Color(0.767, 0.882, 1.0, 1.0)
		var tween = create_tween()
		tween.tween_interval(0.5)
		tween.tween_property(self, "modulate", Color.WHITE, 0.3)
		return true
	
	print("[TrashItem] GAGAL — next_state null")
	return false
		
func is_trash() -> bool:
	return true
