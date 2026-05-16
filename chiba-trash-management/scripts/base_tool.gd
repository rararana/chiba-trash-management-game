extends Area2D
class_name BaseTool

@export var tool_id: String
#@export var MAX_SIZE = 150.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_dragging: bool = false
var drop_tween: Tween
var start_position: Vector2

func _ready():
	start_position = global_position
	input_event.connect(_on_input_event)
	
	# Panggil fungsi resize pas pertama kali load
	if sprite.texture:
		_update_hitbox()

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
		else:
			is_dragging = false
			z_index = 0
			check_apply_tool()

func _process(delta: float):
	if is_dragging:
		global_position = get_global_mouse_position()

func check_apply_tool():
	var areas = get_overlapping_areas()
	var applied = false
	
	for area in areas:
		if area.has_method("receive_tool"): 
			var success = area.receive_tool(tool_id)
			if success:
				applied = true
				queue_free() 
				break
				
	if not applied:
		_return_to_start()

func _return_to_start():
	drop_tween = create_tween()
	drop_tween.tween_property(self, "global_position", start_position, 0.2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
