extends Node2D

@export var trash_scene: PackedScene
@export var trash_data_list: Array[Resource]
@export var min_scatter_radius: float = 100.0
@export var max_scatter_radius: float = 200.0
@export var min_y_boundary: float = 320.0
@onready var spawner = %SpawnerArea

func _ready():
	spawn_trash()

func spawn_trash():
	if trash_data_list.is_empty():
		return
		
	for data in trash_data_list:
		var new_trash = trash_scene.instantiate()
		new_trash.item_data = data
			
		var random_angle = randf_range(0, 2 * PI)
		var random_dist = randf_range(min_scatter_radius, max_scatter_radius)
		var random_offset = Vector2(cos(random_angle), sin(random_angle)) * random_dist
			
		var target_pos = spawner.global_position + random_offset
		target_pos.y = max(target_pos.y, min_y_boundary) # Paksa Y tidak boleh lebih kecil dari 500
		
		new_trash.global_position = target_pos
		add_child(new_trash)
