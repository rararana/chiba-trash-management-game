extends BaseTool

func _ready():
	super._ready()
	tool_id = "tie"

func apply_tool_effect(trash_item: Area2D):
	# Behavior khusus tie
	var is_success = trash_item.receive_tool(tool_id)
	if is_success:
		queue_free()
