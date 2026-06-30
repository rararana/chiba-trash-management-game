extends Control

signal tutorial_tamat

@export_group("Indonesian Textures")
@export var tex_tutor1_id: Texture2D
@export var tex_tutor2_id: Texture2D
@export var tex_tutor3_id: Texture2D
@export var tex_tutor4_id: Texture2D
@export var tex_tutor5_id: Texture2D
@export var tex_tutor6_id: Texture2D
@export var tex_tutor7_id: Texture2D

@onready var bg = $ColorRect
@onready var daftar_tutor = [
	$Tutor1,
	$Tutor2,
	$Tutor3,
	$Tutor4,
	$Tutor5,
	$Tutor6,
	$Tutor7
]
@onready var jempol = $Tutor7/ThumbsUp

var layar_x = 1920.0
var layar_y = 1080.0
var daftar_bolongan = [
	{"pos": Vector2(0, 350), "radius": 0.0, "aspect": Vector2(1.0, 1.0)}, # Tutor 1
	{"pos": Vector2(150, 430), "radius": 250.0, "aspect": Vector2(1.0, 1.0)},   # Tutor 2
	{"pos": Vector2(490, 870), "radius": 250.0, "aspect": Vector2(1.0, 1.0)}, # Tutor 3
	{"pos": Vector2(400, 50), "radius": 100.0, "aspect": Vector2(3.0, 1.0)},   # Tutor 4
	{"pos": Vector2(1200, 1000), "radius": 170.0, "aspect": Vector2(3.0, 1.0)}, # Tutor 5
	{"pos": Vector2(1785, 100), "radius": 90.0, "aspect": Vector2(1.5, 1.0)},# Tutor 6
	{"pos": Vector2(750, 40), "radius": 80.0, "aspect": Vector2(1.5, 1.0)}    # Tutor 7
]
var step_sekarang = 0

func _ready():
	_apply_language()

	var material = bg.material as ShaderMaterial
	material.set_shader_parameter("screen_size", Vector2(layar_x, layar_y))
	
	for tutor in daftar_tutor:
		tutor.hide()
	
	if daftar_tutor.size() > 0:
		daftar_tutor[0].show()
		update_bolongan(0)

func _apply_language() -> void:
	if TranslationServer.get_locale() != "id":
		return
	
	var id_textures = [
		tex_tutor1_id, tex_tutor2_id, tex_tutor3_id,
		tex_tutor4_id, tex_tutor5_id, tex_tutor6_id, tex_tutor7_id
	]
	for i in daftar_tutor.size():
		if id_textures[i]:
			daftar_tutor[i].texture = id_textures[i]

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		lanjutkan_tutorial()

func lanjutkan_tutorial():
	daftar_tutor[step_sekarang].hide()
	
	if step_sekarang < daftar_tutor.size() - 1:
		step_sekarang += 1
		daftar_tutor[step_sekarang].show()
		update_bolongan(step_sekarang)
		
		if step_sekarang == 6: 
			animasi_pop_jempol()
			
	else:
		GameManager.tutorial_selesai = true
		GameManager.save_data()
		
		tutorial_tamat.emit() 
		
		queue_free()

func update_bolongan(index: int):
	var data = daftar_bolongan[index]
	var material = bg.material as ShaderMaterial
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(material, "shader_parameter/center", data["pos"], 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/radius", data["radius"], 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(material, "shader_parameter/aspect", data["aspect"], 0.4).set_trans(Tween.TRANS_SINE)

func animasi_pop_jempol():
	jempol.scale = Vector2(0, 0)
	
	var tween = create_tween()
	tween.tween_property(jempol, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
