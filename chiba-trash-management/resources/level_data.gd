extends Resource
class_name LevelData

@export var level_name: String = "Day 1: Monday"
@export_enum("Paper", "Combustible", "Incombustible", "Glass", "Cans", "Pet") var active_categories: Array[String] = ["Paper", "Combustible"]
@export var trash_data_list: Array[Resource]
