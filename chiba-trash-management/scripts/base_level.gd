extends Node2D

@export var trash_scene: PackedScene
@export var trash_data_list: Array[Resource]
@export var scatter_radius: float = 150.0
@onready var spawner = %SpawnerArea

func _ready():
	spawn_trash()

func spawn_trash():
	if trash_data_list.is_empty():
		return
		
	for data in trash_data_list:
		var new_trash = trash_scene.instantiate()
		new_trash.item_data = data
			
		var random_x = randf_range(-scatter_radius, scatter_radius)
		var random_y = randf_range(-scatter_radius, scatter_radius)
		var random_offset = Vector2(random_x, random_y)
			
		new_trash.global_position = spawner.global_position + random_offset
		add_child(new_trash)
