extends BaseTool

@export var bubble_texture: Texture2D
@onready var sfx = $AudioStreamPlayer2D

func _ready():
	super._ready()
	tool_id = "sponge"

func apply_tool_effect(trash_item: Area2D):
	z_index = 20
	input_pickable = false
	if sfx:
		sfx.play()
	
	_spawn_bubbles(3)
	
	await get_tree().create_timer(0.7).timeout
	if not is_instance_valid(self):
		return
	
	z_index = 0
	input_pickable = true
	if sfx:
		sfx.stop()	
	_return_to_start()

func _spawn_bubbles(count: int):
	for i in range(count):
		var bubble = Sprite2D.new()
		bubble.texture = bubble_texture
		bubble.scale = Vector2(0.25, 0.25)
		bubble.modulate.a = 0.0
		
		var offset = Vector2(30, 10)
		bubble.position = offset
		bubble.z_index = 5
		
		add_child(bubble)
		
		var tween = bubble.create_tween()
		# Fade in
		tween.tween_property(bubble, "modulate:a", 1.0, 0.2) \
			.set_trans(Tween.TRANS_LINEAR)
		# Fade out
		tween.tween_property(bubble, "modulate:a", 0.0, 0.3) \
			.set_trans(Tween.TRANS_LINEAR)
		tween.chain().tween_callback(bubble.queue_free)
