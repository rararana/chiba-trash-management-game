extends Resource
class_name TrashData

@export var family_name: String
@export var is_stackable: bool = false
@export var item_name: String
@export var item_texture: Texture2D
@export_enum("Paper", "Combustible", "Incombustible", "Glass", "Cans", "Pet") var category: String = "Paper"
@export_enum("none", "scissor", "sponge", "tie") var required_tool: String = "none"
@export var next_state: Resource
@export var is_tied: bool = false

func needs_tying() -> bool:
	return category == "Paper" and not is_tied

func try_to_tie(other_trash: TrashData) -> Resource:
	if needs_tying() and other_trash.family_name == self.family_name:
		if next_state:
			return next_state
	
	return null
