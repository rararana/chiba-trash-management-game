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

var current_amount: int = 0
var max_capacity: int = 20
var tween: Tween

@onready var default_bag_scale: Vector2 = sprite.scale
@onready var default_x: float = position.x
@onready var default_sprite_x: float = sprite.position.x

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_update_visual()

func _on_area_entered(area: Area2D):
	if is_instance_valid(area) and area.has_method("is_trash"):
		if area.get("is_dragging") == true:
			var calc_target_scale = default_bag_scale + Vector2(scale_increase, scale_increase)
			_animate(calc_target_scale, default_x + target_x_offset, default_sprite_x + extra_sprite_offset)

func _on_area_exited(area: Area2D):
	# cek is_instance_valid dulu biar nggak crash saat sampah dihapus
	if not is_instance_valid(area) or area.has_method("is_trash"):
		_animate(default_bag_scale, default_x, default_sprite_x)

func _animate(to_scale: Vector2, to_self_x: float, to_sprite_x: float):
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", to_scale, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:x", to_self_x, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:x", to_sprite_x, 0.15).set_trans(Tween.TRANS_SINE)

func receive_trash(incoming_category: String) -> bool:
	if incoming_category != bag_category:
		_animate(default_bag_scale, default_x, default_sprite_x)
		return false
		
	if current_amount >= max_capacity:
		_animate(default_bag_scale, default_x, default_sprite_x)
		return false
		
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
