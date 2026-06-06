extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var anim_player = $AnimationPlayer

func _ready():
	color_rect.modulate.a = 0 

func transition_to(jalur_scene_tujuan: String):
	anim_player.play_backwards("fade_to_black")
	
	await anim_player.animation_finished
	
	get_tree().change_scene_to_file(jalur_scene_tujuan)
	
	anim_player.play("fade_to_black")
