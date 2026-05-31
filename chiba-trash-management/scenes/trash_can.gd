extends Area2D
class_name TrashCan

@onready var sprite: Sprite2D = $Sprite2D
@onready var default_scale: Vector2 = sprite.scale
var bounce_tween: Tween

func receive_dropped_object(obj: Area2D) -> bool:
	var total_denda: int = 0
	
	if obj.has_method("is_trash_bag"):
		if obj.get("current_amount") == 0:
			return false
			
		var bag_cat = obj.get("bag_category")
		var items_inside = obj.get("stored_items")
		
		for item in items_inside:
			var item_cat = item.get("category")
			var needs_processing = item.get("next_state") != null
			
			if item_cat == "Paper":
				total_denda += 1
			elif item_cat != bag_cat:
				total_denda += 1
			
			if needs_processing:
				total_denda += 1
				
		print("KANTONG MASUK! Total denda dari kantong ini: ", total_denda)
		_bounce()
		return true
		
	elif obj.has_method("is_trash"):
		var item = obj.item_data
		var item_cat = item.get("category")
		var needs_processing = item.get("next_state") != null
		
		if item_cat != "Paper":
			total_denda += 1
			
		if needs_processing:
			total_denda += 1
			
		print("SAMPAH LANGSUNG MASUK! Total denda: ", total_denda)
		_bounce()
		return true 
		
	return false

func _bounce():
	if bounce_tween and bounce_tween.is_valid():
		bounce_tween.kill()
		
	bounce_tween = create_tween()
	bounce_tween.tween_property(sprite, "scale", default_scale * 1.2, 0.1).set_trans(Tween.TRANS_SINE)
	bounce_tween.tween_property(sprite, "scale", default_scale, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
