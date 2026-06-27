extends BaseTool

@export var texture_closed: Texture2D
@export var texture_open: Texture2D

@onready var sfx = $AudioStreamPlayer2D 

func _ready():
	super._ready()
	tool_id = "scissor"

func apply_tool_effect(trash_item: Area2D):
	z_index = 20
	input_pickable = false
	if sfx:
		sfx.play()
	
	var flips = 4
	for i in range(flips):
		if texture_open and texture_closed:
			sprite.texture = (texture_open if i % 2 == 0 else texture_closed)
		await get_tree().create_timer(0.15).timeout
		if not is_instance_valid(self):
			return
	
	if texture_closed:
		sprite.texture = texture_closed
	z_index = 0
	input_pickable = true

	if sfx:
		sfx.stop()
	_return_to_start()
