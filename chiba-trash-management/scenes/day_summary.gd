extends CanvasLayer
class_name DaySummary

signal on_continue

@export var envelope_closed_texture: Texture2D
@export var envelope_open_texture: Texture2D

@onready var control: Control = $Control
@onready var envelope_root: Control = $Control/EnvelopeRoot
@onready var envelope_back: TextureRect = $Control/EnvelopeRoot/EnvelopeBack
@onready var envelope_front: TextureRect = $Control/EnvelopeRoot/EnvelopeFront
@onready var letter: Control = $Control/EnvelopeRoot/Letter

@onready var day_label: Label = $Control/EnvelopeRoot/Letter/ContentVBox/DayLabel
@onready var savings_value: Label = $Control/EnvelopeRoot/Letter/ContentVBox/Rows/SavingsValue
@onready var salary_value: Label = $Control/EnvelopeRoot/Letter/ContentVBox/Rows/SalaryValue
@onready var fined_value: Label = $Control/EnvelopeRoot/Letter/ContentVBox/Rows/FinedValue
@onready var total_value: Label = $Control/EnvelopeRoot/Letter/ContentVBox/TotalRows/TotalValue

var is_ready_to_continue: bool = false

# Seberapa jauh letter muncul di atas envelope (dalam pixel, relatif ke EnvelopeRoot)
const LETTER_HIDDEN_OFFSET_Y: float = 80.0   # posisi awal: tersembunyi di dalam envelope
const LETTER_SHOWN_OFFSET_Y: float = -150.0  # posisi akhir: muncul keluar ke atas

func _ready():
	if envelope_closed_texture:
		envelope_front.texture = envelope_closed_texture
	
	envelope_back.modulate.a = 0.0
	letter.position.y = LETTER_HIDDEN_OFFSET_Y
	letter.modulate.a = 0.0
	
	control.mouse_filter = Control.MOUSE_FILTER_STOP

func show_summary(day_name: String):
	var savings = GameManager.money_at_day_start
	var salary  = GameManager.salary_earned
	var fined   = GameManager.fines_incurred
	var total   = GameManager.money

	day_label.text      = tr("DAY") + " " + day_name
	savings_value.text  = "¥%d" % savings
	salary_value.text   = "¥%d" % salary
	fined_value.text    = "-¥%d" % fined
	total_value.text    = "¥%d" % total

	_play_open_animation()

func _play_open_animation():
	await get_tree().create_timer(1.5).timeout

	if envelope_open_texture:
		var tween_open = create_tween()
		tween_open.tween_property(envelope_front, "modulate:a", 0.0, 0.25)
		await tween_open.finished
		
		envelope_front.texture = envelope_open_texture
		var tween_fadein = create_tween()
		tween_fadein.parallel().tween_property(envelope_front, "modulate:a", 1.0, 0.25)
		tween_fadein.parallel().tween_property(envelope_back, "modulate:a", 1.0, 0.25)
		await tween_fadein.finished

	await get_tree().create_timer(0.15).timeout
	
	letter.modulate.a = 1.0
	var tween_letter = create_tween()
	tween_letter.tween_property(letter, "position:y", LETTER_SHOWN_OFFSET_Y, 0.6)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween_letter.finished
	is_ready_to_continue = true

func _input(event: InputEvent):
	if not is_ready_to_continue:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_ready_to_continue = false
		emit_signal("on_continue")
		queue_free()
