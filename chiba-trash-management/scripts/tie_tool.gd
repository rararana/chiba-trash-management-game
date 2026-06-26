extends BaseTool

func _ready():
	super._ready()
	tool_id = "tie"

func apply_tool_effect(trash_item: Area2D):
	_return_to_start()
