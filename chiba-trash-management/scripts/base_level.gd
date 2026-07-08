extends Node2D

@export var current_level: LevelData
@export var trash_scene: PackedScene
@export var day_summary_scene: PackedScene
@export var min_scatter_radius: float = 180.0
@export var max_scatter_radius: float = 200.0
@export var min_y_boundary: float = 320.0
@export var level_duration: float = 300.0 
@export var STACK_SIZE: int = 3

@onready var spawner = %SpawnerArea
@onready var category_bags = $CategoryBags

@onready var morning_sky: TextureRect = $BackgroundLayer/MorningSky
@onready var afternoon_sky: TextureRect = $BackgroundLayer/AfternoonSky
@onready var evening_sky: TextureRect = $BackgroundLayer/EveningSky
@onready var BGM = $BGM
@onready var sfx_bag_drop: AudioStreamPlayer2D = $BagDrop
@onready var sfx_bag_to_bin: AudioStreamPlayer2D = $BagToBin
@onready var sfx_trash_to_bin: AudioStreamPlayer2D = $TrashToBin
@onready var tools: Node2D = $Tools

var time_passed: float = 0.0
var is_level_ended: bool = false
var is_game_started: bool = false
var tying_buffer: Array[Node] = []
var end_reason: String = ""
var inactive_timer: float = 0.0
var last_mouse_pos: Vector2 = Vector2.ZERO
const INACTIVE_THRESHOLD: float = 10.0
const MAIN_MENU_PATH = "res://scenes/UI/main_menu.tscn"

func _ready():
	add_to_group("level")
	#BGM.play()
	morning_sky.modulate.a = 1.0
	afternoon_sky.modulate.a = 0.0
	evening_sky.modulate.a = 0.0
	GameManager.start_day()
	GameManager.on_game_over.connect(_on_bankrupt)
	if current_level:
		setup_bags()
	
	var tutorial_node = get_node_or_null("CanvasLayer/Tutorial")
	
	if GameManager.tutorial_selesai == false and tutorial_node != null:
		tutorial_node.show()
		tutorial_node.tutorial_tamat.connect(_start_game)
	else:
		if tutorial_node != null:
			tutorial_node.queue_free()
		_start_game()
	
	if current_level.hide_tools:
		tools.hide()
	else:
		tools.show()

func _start_game():
	spawn_trash()
	BGM.play()
	is_game_started = true
	print("Tutorial selesai/di-skip, Timer mulai jalan!")

func _process(delta: float):
	if not is_game_started or is_level_ended: 
		return
	
	time_passed += delta
	if time_passed >= level_duration:
		time_passed = level_duration
		end_reason = "time_up"
		_on_level_ended()
		return
	
	if time_passed > 1.0 and _all_trash_cleared():
		end_reason = "trash_empty"
		_on_level_ended()
		return
	
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
		
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.distance_to(last_mouse_pos) > 5.0:
		inactive_timer = 0.0
		last_mouse_pos = mouse_pos
		#_stop_bag_hints()
	else:
		inactive_timer += delta
		if inactive_timer >= INACTIVE_THRESHOLD:
			_check_and_hint_bags()
			
func _check_and_hint_bags():
	if not get_tree().get_nodes_in_group("trash").is_empty():
		return
	for bag in category_bags.get_children():
		if bag.has_method("is_trash_bag") and bag.current_amount > 0:
			if bag.has_method("start_hint"):
				bag.start_hint()

func _all_trash_cleared() -> bool:
	if not get_tree().get_nodes_in_group("trash").is_empty():
		return false
	
	for bag in category_bags.get_children():
		if bag.has_method("is_trash_bag") and bag.current_amount > 0:
			return false
	
	return true

func _on_level_ended():
	is_level_ended = true
	is_game_started = false
	print("Level Selesai. Alasan: ", end_reason)
	for bag in category_bags.get_children():
		bag.process_mode = Node.PROCESS_MODE_DISABLED
	if end_reason == "bankrupt":
		await get_tree().create_timer(0.5).timeout
	else:
		await get_tree().create_timer(1.5).timeout
	var summary = day_summary_scene.instantiate()
	add_child(summary)
	summary.show_summary(current_level.level_name)
	summary.on_continue.connect(_on_summary_continued)

func _on_bankrupt():
	if is_level_ended:
		return
	end_reason = "bankrupt"
	_on_level_ended()
	
func _on_summary_continued():
	if GameManager.money < 0 or end_reason == "time_up":
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
	else:
		GameManager.next_day()
		if current_level.next_level_data:
			if current_level.next_level_data.hide_tools:
				tools.hide()
			else:
				tools.show()
			is_level_ended = false
			is_game_started = true
			end_reason = ""
			time_passed = 0.0
			current_level = current_level.next_level_data
			
			morning_sky.modulate.a = 1.0
			afternoon_sky.modulate.a = 0.0
			evening_sky.modulate.a = 0.0
			
			for trash in get_tree().get_nodes_in_group("trash"):
				trash.queue_free()
			
			setup_bags()
			spawn_trash()
			BGM.play()
		else:
			get_tree().change_scene_to_file(MAIN_MENU_PATH)

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

func try_tie_at_position(drop_pos: Vector2, radius: float = 80.0) -> void:
	var candidates: Array[Node] = []
	for child in get_children():
		if not child.has_method("is_trash"):
			continue
		var dist = child.global_position.distance_to(drop_pos)
		print("[TyingBuffer] ", child.name, " jarak: ", dist, " | can_be_tied: ", (child.item_data as TrashData).can_be_tied() if child.item_data else "null")
		if dist > radius:
			continue
		var data = child.item_data as TrashData
		if data and data.can_be_tied():
			candidates.append(child)
	
	print("[TyingBuffer] Kandidat di sekitar drop: ", candidates.size())
	
	if candidates.is_empty():
		return
	
	var groups: Dictionary = {}
	for node in candidates:
		var fname = (node.item_data as TrashData).family_name
		if not groups.has(fname):
			groups[fname] = []
		groups[fname].append(node)
	
	for fname in groups:
		var group: Array = groups[fname]
		print("[TyingBuffer] Family '", fname, "' punya ", group.size(), " item")
		if group.size() >= STACK_SIZE:
			var result_data = (group[0].item_data as TrashData).next_state
			print("[TyingBuffer] Berhasil tie! Transform ke: ", result_data.item_name)
			group[0].item_data = result_data
			group[0].sprite.texture = result_data.item_texture
			group[0]._update_hitbox()
			group[0].modulate = Color.WHITE
			for i in range(1, group.size()):
				group[i]._shrink_and_free()
		else:
			print("[TyingBuffer] GAGAL — kurang item, butuh ", STACK_SIZE, " punya ", group.size())

func play_sfx_bag_drop():
	sfx_bag_drop.play(0.1)
	get_tree().create_timer(0.15).timeout.connect(func(): sfx_bag_drop.stop())

func play_sfx_bag_to_bin():
	sfx_bag_to_bin.play()
	get_tree().create_timer(0.3).timeout.connect(func(): sfx_bag_to_bin.stop())

func play_sfx_trash_to_bin():
	sfx_trash_to_bin.play(0.002)
	get_tree().create_timer(0.3).timeout.connect(func(): sfx_trash_to_bin.stop())
