extends CanvasLayer

@export var cover_tex: Texture2D
@export var book1_tex: Texture2D
@export var book2_tex: Texture2D

var pages = []
var current_page = 0

func _ready():
	update_day_ui()
	update_money_ui()
	
	pages = [cover_tex, book1_tex, book2_tex]
	$HelpOverlay.hide()

func _process(delta):
	update_day_ui()
	update_money_ui()

func update_day_ui():
	var day_index = GameManager.current_day_index
	var current_day_name = GameManager.days_list[day_index]
	$DayBox/DayLabel.text = "Day 1 : " + current_day_name

func update_money_ui():
	var current_money = GameManager.money
	$WalletIcon/MoneyLabel.text = "¥" + str(current_money)

func update_book_visuals():
	var tex = pages[current_page]
	$HelpOverlay/BookDisplay.texture = tex
	
	$HelpOverlay/BookDisplay.custom_minimum_size = Vector2.ZERO
	$HelpOverlay/BookDisplay.size = tex.get_size()
	
	$HelpOverlay/BookDisplay.scale = Vector2(0.1823, 0.1823)
	$HelpOverlay/BookDisplay.pivot_offset = Vector2.ZERO
	
	var pos_x = 188 
	var pos_y = 84
	
	$HelpOverlay/BookDisplay.position = Vector2(pos_x, pos_y)
	
	$HelpOverlay/BtnPrev.visible = (current_page > 0)
	$HelpOverlay/BtnNext.visible = (current_page < pages.size() - 1)

func _on_help_button_pressed():
	current_page = 0
	update_book_visuals()
	$HelpOverlay.show()

func _on_bg_close_button_pressed():
	$HelpOverlay.hide()

func _on_btn_next_pressed():
	if current_page < pages.size() - 1:
		current_page += 1
		update_book_visuals()

func _on_btn_prev_pressed():
	if current_page > 0:
		current_page -= 1
		update_book_visuals()
