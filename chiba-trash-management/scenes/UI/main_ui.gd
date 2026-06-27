extends CanvasLayer

@export var cover_tex: Texture2D
@export var book1_tex: Texture2D
@export var book2_tex: Texture2D

var pages = []
var current_page = 0
var is_animating = false

func _ready():
	GameManager.hari_berubah.connect(update_day_ui)
	GameManager.uang_berubah.connect(update_money_ui)
	
	update_day_ui()
	update_money_ui()
	
	pages = [cover_tex, book1_tex, book2_tex]
	$HelpOverlay.hide()

func update_day_ui():
	var day_index = GameManager.current_day_index
	var current_day_key = GameManager.days_list[day_index]
	$DayBox/DayLabel.text = tr("DAY") + " " + str(day_index + 1) + " : " + tr(current_day_key)

func update_money_ui():
	var current_money = GameManager.money
	$WalletIcon/MoneyLabel.text = "¥" + str(current_money)

func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		update_day_ui()

func update_book_visuals():
	var tex = pages[current_page]
	$HelpOverlay/BookDisplay.texture = tex
	
	$HelpOverlay/BookDisplay.custom_minimum_size = Vector2.ZERO
	$HelpOverlay/BookDisplay.size = tex.get_size()
	
	var pivot = tex.get_size() / 2.0
	$HelpOverlay/BookDisplay.pivot_offset = pivot
	
	$HelpOverlay/BookDisplay.scale = Vector2(0.1823, 0.1823)
	
	var pos_x = 188.0
	var pos_y = 84.0
	
	var posisi_asli = Vector2(pos_x, pos_y)
	$HelpOverlay/BookDisplay.position = posisi_asli - pivot + (pivot * 0.1823)
	
	$HelpOverlay/BtnPrev.visible = (current_page > 0)
	$HelpOverlay/BtnNext.visible = (current_page < pages.size() - 1)

func _on_help_button_pressed():
	if is_animating: return 
	is_animating = true
	
	current_page = 0
	update_book_visuals()
	
	$HelpOverlay.modulate.a = 1.0 
	$HelpOverlay.show()
	
	var book = $HelpOverlay/BookDisplay
	book.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(book, "scale", Vector2(0.1823, 0.1823), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	is_animating = false

func _on_bg_close_button_pressed():
	if is_animating: return
	is_animating = true
	
	var book = $HelpOverlay/BookDisplay
	
	var tween = create_tween()
	tween.tween_property(book, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	await tween.finished
	$HelpOverlay.hide()
	is_animating = false

func animate_page_turn(new_page: int):
	if is_animating: return
	is_animating = true
	
	var book = $HelpOverlay/BookDisplay
	
	var tween_out = create_tween()
	tween_out.tween_property(book, "modulate", Color(0.4, 0.4, 0.4, 1.0), 0.05)
	await tween_out.finished
	
	current_page = new_page
	update_book_visuals()
	
	var tween_in = create_tween()
	tween_in.tween_property(book, "modulate", Color.WHITE, 0.05)
	await tween_in.finished
	
	is_animating = false

func _on_btn_next_pressed():
	if current_page < pages.size() - 1:
		animate_page_turn(current_page + 1)

func _on_btn_prev_pressed():
	if current_page > 0:
		animate_page_turn(current_page - 1)
