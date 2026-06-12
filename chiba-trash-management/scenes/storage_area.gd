extends Area2D
class_name StorageArea

@export var open_y_offset: float = -100.0 
@onready var items_container: Node2D = $Mover/ItemsContainer
@onready var main_ui = $"../MainUI"
@onready var default_y: float = position.y 
var tween: Tween
var is_mouse_inside: bool = false

func _ready():
	main_ui.show()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	is_mouse_inside = true
	_update_tray_state()

func _on_mouse_exited():
	is_mouse_inside = false
	_update_tray_state()

func _update_tray_state():
	var target_y = default_y + open_y_offset if is_mouse_inside else default_y
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position:y", target_y, 0.2).set_trans(Tween.TRANS_SINE)

func store_object(obj: Area2D) -> bool:
	if obj.has_method("is_trash_bag"):
		var bag_data = {
			"type": "bag",
			"category": obj.get("bag_category"),
			"contents": obj.get("stored_items").duplicate()
		}
		GameManager.saved_items.append(bag_data)
		
		var bag_scene = load(obj.scene_file_path)
		var item_to_store = bag_scene.instantiate()
		
		items_container.add_child(item_to_store)
		
		item_to_store.is_stored_clone = true
		item_to_store.current_amount = obj.current_amount
		item_to_store.stored_items = obj.stored_items.duplicate()
		
		if item_to_store.has_node("BarSprite"):
			item_to_store.get_node("BarSprite").queue_free()
			
		item_to_store._update_visual()
		item_to_store.position = Vector2(0, 0)
		item_to_store.scale = Vector2(2.0, 2.0)
		item_to_store.z_index = 5
		
		return true
	
	if obj.has_method("is_trash"):
		var item_data = obj.item_data as TrashData
		if item_data == null:
			return false
		
		if not item_data.get("is_tied"):
			return false
		
		var tied_data = {
			"type": "tied_paper",
			"family": item_data.family_name,
			"item_name": item_data.item_name
		}
		GameManager.saved_items.append(tied_data)
		
		var item_visual = Sprite2D.new()
		item_visual.texture = item_data.item_texture
		item_visual.scale = Vector2(0.5, 0.5)
		item_visual.position = Vector2(0, 0)
		items_container.add_child(item_visual)
		
		return true
	
	return false
