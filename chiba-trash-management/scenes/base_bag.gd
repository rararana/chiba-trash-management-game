extends Area2D
class_name BaseBag

@export_enum("Paper", "Combustible", "Incombustible", "Glass", "Cans", "Pet") var bag_category: String = "Paper"
@export var texture_normal: Texture2D
@export var texture_sedang: Texture2D
@export var texture_full: Texture2D

@export var scale_increase: float = 2.0
@export var target_x_offset: float = 100.0
@export var extra_sprite_offset: float = 30.0

@onready var sprite: Sprite2D = $BagSprite
@onready var bar_sprite: Sprite2D = $BarSprite

var current_amount: int = 0
var max_capacity: int = 20
var tween: Tween

@onready var default_bag_scale: Vector2 = sprite.scale
@onready var initial_scale: Vector2 = sprite.scale
@onready var default_x: float = position.x
@onready var default_sprite_x: float = sprite.position.x

var is_dragging: bool = false
@onready var start_global_pos: Vector2 = global_position
@onready var default_bar_pos: Vector2 = bar_sprite.position
var current_ratio: Vector2 = Vector2(1.0, 1.0)
var stored_items: Array[Resource] = []
var is_stored_clone: bool = false

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	input_event.connect(_on_input_event)
	_update_visual()

func _on_area_entered(area: Area2D):
	if is_stored_clone:
		return
	if is_instance_valid(area) and area.has_method("is_trash") and not is_dragging:
		if area.get("is_dragging") == true:
			var calc_target_scale = default_bag_scale + (Vector2(scale_increase, scale_increase) * current_ratio)
			_animate(calc_target_scale, default_x + target_x_offset, default_sprite_x + extra_sprite_offset)

func _on_area_exited(area: Area2D):
	if is_stored_clone:
		return
	if (not is_instance_valid(area) or area.has_method("is_trash")) and not is_dragging:
		_animate(default_bag_scale, default_x, default_sprite_x)

func _animate(to_scale: Vector2, to_self_x: float, to_sprite_x: float):
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", to_scale, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", to_self_x, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:x", to_sprite_x, 0.15).set_trans(Tween.TRANS_SINE)

func receive_trash(incoming_data: Resource) -> bool:
	if is_stored_clone: 
		return false
		
	if current_amount >= max_capacity:
		_animate(default_bag_scale, default_x, default_sprite_x)
		return false
		
	stored_items.append(incoming_data)
	current_amount += 1
	_update_visual()
	_animate(default_bag_scale, default_x, default_sprite_x)
	return true

func _update_visual():
	if current_amount >= 15:
		sprite.texture = texture_full
	elif current_amount >= 5:
		sprite.texture = texture_sedang
	else:
		sprite.texture = texture_normal
		
	if sprite.texture and texture_normal:
		current_ratio = texture_normal.get_size() / sprite.texture.get_size()
		default_bag_scale = initial_scale * current_ratio
		sprite.scale = default_bag_scale

func is_trash_bag() -> bool:
	return true

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if current_amount > 0 or is_stored_clone:
				start_global_pos = global_position
				is_dragging = true
				z_index = 10
				get_viewport().set_input_as_handled()
				
				if not is_stored_clone:
					var drag_scale = default_bag_scale + (Vector2(scale_increase, scale_increase) * current_ratio)
					if tween and tween.is_valid():
						tween.kill()
					tween = create_tween()
					tween.tween_property(sprite, "scale", drag_scale, 0.15).set_trans(Tween.TRANS_SINE)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false
			z_index = 0
			check_bag_drop_zone()
			
			if not is_stored_clone:
				if tween and tween.is_valid():
					tween.kill()
				tween = create_tween()
				tween.tween_property(sprite, "scale", default_bag_scale, 0.15).set_trans(Tween.TRANS_SINE)

func _process(delta: float):
	if is_dragging:
		global_position = get_global_mouse_position()
		if is_instance_valid(bar_sprite):
			bar_sprite.global_position = start_global_pos

func check_bag_drop_zone():
	var overlapping_areas = get_overlapping_areas()
	var dropped_successfully = false
	
	for area in overlapping_areas:
		if area.has_method("receive_dropped_object"):
			if area.receive_dropped_object(self):
				dropped_successfully = true
				if is_stored_clone:
					queue_free()
				else:
					current_amount = 0
					stored_items.clear()
					_update_visual()
					global_position = start_global_pos
					if is_instance_valid(bar_sprite):
						bar_sprite.position = default_bar_pos
				break
				
		elif area.has_method("store_object") and not is_stored_clone:
			if area.store_object(self):
				dropped_successfully = true
				current_amount = 0
				stored_items.clear()
				_update_visual()
				global_position = start_global_pos
				if is_instance_valid(bar_sprite):
					bar_sprite.position = default_bar_pos
				break
				
	if not dropped_successfully:
		global_position = start_global_pos
		if is_instance_valid(bar_sprite):
			bar_sprite.position = default_bar_pos
