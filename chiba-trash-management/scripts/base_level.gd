extends Node2D

@export var current_level: LevelData
@export var trash_scene: PackedScene
@export var min_scatter_radius: float = 180.0
@export var max_scatter_radius: float = 200.0
@export var min_y_boundary: float = 320.0
@export var level_duration: float = 300.0 

@onready var spawner = %SpawnerArea
@onready var category_bags = $CategoryBags

@onready var morning_sky: TextureRect = $BackgroundLayer/MorningSky
@onready var afternoon_sky: TextureRect = $BackgroundLayer/AfternoonSky
@onready var evening_sky: TextureRect = $BackgroundLayer/EveningSky
@onready var BGM = $BGM

var time_passed: float = 0.0
var is_level_ended: bool = false

func _ready():
	BGM.play()
	morning_sky.modulate.a = 1.0
	afternoon_sky.modulate.a = 0.0
	evening_sky.modulate.a = 0.0
	
	if current_level:
		setup_bags()
		spawn_trash()

func _process(delta: float):
	if is_level_ended:
		return 
		
	time_passed += delta
	if time_passed >= level_duration:
		time_passed = level_duration
		is_level_ended = true
		_on_level_ended()
		
	var progress = time_passed / level_duration

	if progress <= 0.5:
		var t = progress / 0.5
		morning_sky.modulate.a = 1.0 - t
		afternoon_sky.modulate.a = t
		evening_sky.modulate.a = 0.0
	else:
		var t = (progress - 0.5) / 0.5
		morning_sky.modulate.a = 0.0
		afternoon_sky.modulate.a = 1.0 - t
		evening_sky.modulate.a = t

func _on_level_ended():
	print("Waktu Habis! Level Selesai.")

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
