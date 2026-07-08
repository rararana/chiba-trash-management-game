extends Control

signal tutorial2_tamat

@export_group("Indonesian Textures")
@export var tex_tutor1_id: Texture2D
@export var tex_tutor2_id: Texture2D
@export var tex_tutor3_id: Texture2D
@export var tex_tutor4_id: Texture2D
@export var tex_tutor5_id: Texture2D
@export var tex_tutor6_id: Texture2D

@onready var bg = $ColorRect
@onready var daftar_tutor = [
	$Tutor1,
	$Tutor2,
	$Tutor3,
	$Tutor4,
	$Tutor5,
	$Tutor6
]

var layar_x = 1920.0
var layar_y = 1080.0

var daftar_bolongan = [
	{"pos": Vector2(960, 540), "radius": 0.0, "aspect": Vector2(1.0, 1.0)},
	{"pos": Vector2(940, 670), "radius": 0.0, "aspect": Vector2(1.0, 1.0)},
	{"pos": Vector2(940, 690), "radius": 150.0, "aspect": Vector2(1.0, 1.5)},
	{"pos": Vector2(990, 680), "radius": 200.0, "aspect": Vector2(1.5, 1.0)},
	{"pos": Vector2(990, 660), "radius": 200.0, "aspect": Vector2(1.5, 1.0)},
	{"pos": Vector2(490, 850), "radius": 230.0, "aspect": Vector2(1.5, 1.0)}
]

var step_sekarang = 0
var tekstur_asli_en = []

func _ready():
	hide()
	
	for node in daftar_tutor:
		if node.get_class() == "TextureRect":
			tekstur_asli_en.append(node.texture)
		elif node.has_node("TextureRect"):
			tekstur_asli_en.append(node.get_node("TextureRect").texture)
		else:
			tekstur_asli_en.append(null)

	_apply_language()

	var material = bg.material as ShaderMaterial
	if material != null:
		material.set_shader_parameter("screen_size", Vector2(layar_x, layar_y))
	
	for tutor in daftar_tutor:
		tutor.hide()
	
	if daftar_tutor.size() > 0:
		daftar_tutor[0].show()
		update_bolongan(0)

func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_apply_language()

func _apply_language() -> void:
	if daftar_tutor == null:
		return
		
	var id_textures = [
		tex_tutor1_id, tex_tutor2_id, tex_tutor3_id,
		tex_tutor4_id, tex_tutor5_id, tex_tutor6_id
	]
	
	var is_indo = (TranslationServer.get_locale() == "id")
	
	for i in daftar_tutor.size():
		var node_tutor = daftar_tutor[i]
		var tekstur_terpilih = id_textures[i] if is_indo else tekstur_asli_en[i]
		
		if tekstur_terpilih != null:
			if node_tutor.get_class() == "TextureRect":
				node_tutor.texture = tekstur_terpilih
			elif node_tutor.has_node("TextureRect"):
				node_tutor.get_node("TextureRect").texture = tekstur_terpilih

func _input(event):
	if not visible:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		lanjutkan_tutorial()

func lanjutkan_tutorial():
	daftar_tutor[step_sekarang].hide()
	
	if step_sekarang < daftar_tutor.size() - 1:
		step_sekarang += 1
		daftar_tutor[step_sekarang].show()
		update_bolongan(step_sekarang)
			
	else:
		GameManager.tutorial2_selesai = true
		if GameManager.has_method("save_data2"):
			GameManager.save_data2()
		
		tutorial2_tamat.emit() 
		queue_free()

func update_bolongan(index: int):
	var data = daftar_bolongan[index]
	var material = bg.material as ShaderMaterial
	
	if material != null:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(material, "shader_parameter/center", data["pos"], 0.4).set_trans(Tween.TRANS_SINE)
		tween.tween_property(material, "shader_parameter/radius", data["radius"], 0.4).set_trans(Tween.TRANS_SINE)
		tween.tween_property(material, "shader_parameter/aspect", data["aspect"], 0.4).set_trans(Tween.TRANS_SINE)
