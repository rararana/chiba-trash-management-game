extends Node2D

@export var current_level: LevelData
@export var trash_scene: PackedScene
@export var min_scatter_radius: float = 100.0
@export var max_scatter_radius: float = 200.0
@export var min_y_boundary: float = 320.0

@onready var spawner = %SpawnerArea
@onready var category_bags = $CategoryBags

func _ready():
	if current_level:
		setup_bags()
		spawn_trash()

func setup_bags():
	for bag in category_bags.get_children():
		if bag.get("bag_category") in current_level.active_categories:
			bag.show()
			bag.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			bag.hide()
			bag.process_mode = Node.PROCESS_MODE_DISABLED

func spawn_trash():
	if current_level.trash_data_list.is_empty():
		return
		
	for data in current_level.trash_data_list:
		var new_trash = trash_scene.instantiate()
		new_trash.item_data = data
			
		var random_angle = randf_range(0, 2 * PI)
		var random_dist = randf_range(min_scatter_radius, max_scatter_radius)
		var random_offset = Vector2(cos(random_angle), sin(random_angle)) * random_dist
			
		var target_pos = spawner.global_position + random_offset
		target_pos.y = max(target_pos.y, min_y_boundary)
		
		new_trash.global_position = target_pos
		add_child(new_trash)
