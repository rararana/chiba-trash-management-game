extends Area2D
class_name TrashCan

@onready var sprite: Sprite2D = $Sprite2D
@onready var default_scale: Vector2 = sprite.scale
var bounce_tween: Tween

func receive_dropped_object(obj: Area2D) -> bool:
	if obj.has_method("is_trash_bag"):
		if obj.get("current_amount") > 0:
			print("BENAR: Kantong berhasil dibuang!")
			_bounce()
			return true
		else:
			return false
			
	elif obj.has_method("is_trash"):
		var category = obj.item_data.get("category")
		if category == "Paper":
			print("BENAR: Kertas dibuang aman.")
			_bounce()
			return true
		else:
			print("DENDA: Kategori ", category, " harus dibungkus plastik!")
			_bounce()
			return true 
			
	return false

func _bounce():
	if bounce_tween and bounce_tween.is_valid():
		bounce_tween.kill()
		
	bounce_tween = create_tween()
	bounce_tween.tween_property(sprite, "scale", default_scale * 1.2, 0.1).set_trans(Tween.TRANS_SINE)
	bounce_tween.tween_property(sprite, "scale", default_scale, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
