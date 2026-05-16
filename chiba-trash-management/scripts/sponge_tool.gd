extends BaseTool

func _ready():
	super._ready()
	tool_id = "sponge"

func apply_tool_effect(trash_item: Area2D):
	# Behavior khusus sponge
	var is_success = trash_item.receive_tool(tool_id)
	if is_success:
		queue_free()
