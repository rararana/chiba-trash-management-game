extends Resource
class_name TrashData

@export var item_name: String
@export var item_texture: Texture2D
@export var category: String = "Paper"
@export_enum("none", "scissor", "sponge", "tie") var required_tool: String = "none"
@export var next_state: Resource
