extends Area2D
class_name TrashCan

@export var money_per_item: int = 5
@onready var sprite: Sprite2D = $Sprite2D
@onready var default_scale: Vector2 = sprite.scale
var bounce_tween: Tween

func receive_dropped_object(obj: Area2D) -> bool:
	var total_money_change: int = 0
	
	if obj.has_method("is_trash_bag"):
		if obj.get("current_amount") == 0:
			return false
			
		var bag_cat = obj.get("bag_category")
		var items_inside = obj.get("stored_items")
		
		for item in items_inside:
			var item_cat = item.get("category")
			var needs_processing = item.get("next_state") != null
			print("[TrashCan] item: ", item.get("item_name"), " | cat: ", item_cat, " | bag_cat: ", bag_cat, " | needs_processing: ", needs_processing)
			
			var is_wrong: bool = false
			
			if item_cat != bag_cat:
				is_wrong = true
			elif needs_processing:
				is_wrong = true
				
			if is_wrong:
				total_money_change -= money_per_item
			else:
				total_money_change += money_per_item
		
		if total_money_change >= 0:
			GameManager.add_money(total_money_change)
		else:
			GameManager.deduct_money(-total_money_change)
		_bounce()
		
		var level = get_tree().get_first_node_in_group("level")
		if level and level.has_method("play_sfx_bag_to_bin"):
			level.play_sfx_bag_to_bin()
		
		return true
		
	elif obj.has_method("is_trash"):
		var item = obj.item_data
		var item_cat = item.get("category")
		var needs_processing = item.get("next_state") != null
		
		var is_wrong: bool = false
		
		if item_cat != "Paper":
			is_wrong = true
		elif needs_processing:
			is_wrong = true
		
		if is_wrong:
			total_money_change -= money_per_item
		else:
			total_money_change += money_per_item
		
		if total_money_change >= 0:
			GameManager.add_money(total_money_change)
		else:
			GameManager.deduct_money(-total_money_change)
		_bounce()
		
		var level = get_tree().get_first_node_in_group("level")
		if level and level.has_method("play_sfx_trash_to_bin"):
			level.play_sfx_trash_to_bin()
		
		return true
		
	return false

func _bounce():
	if bounce_tween and bounce_tween.is_valid():
		bounce_tween.kill()
		
	bounce_tween = create_tween()
	bounce_tween.tween_property(sprite, "scale", default_scale * 1.2, 0.1).set_trans(Tween.TRANS_SINE)
	bounce_tween.tween_property(sprite, "scale", default_scale, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
