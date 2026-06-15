extends Node

signal on_game_over
signal uang_berubah
signal hari_berubah

func next_day():
	current_day_index += 1
	if current_day_index >= days_list.size():
		current_day_index = 0
	emit_signal("hari_berubah")

var money: int = 100
var current_day_index: int = 0
var days_list = ["MON", "TUE"]
var schedule = {
	"MON": ["Combustible"],
	"TUE": ["Used Paper"]
}
var saved_items: Array[Dictionary] = []

var money_at_day_start: int = 100
var salary_earned: int = 0
var fines_incurred: int = 0

func start_day():
	money_at_day_start = money
	salary_earned = 0
	fines_incurred = 0

func add_money(amount: int):
	money += amount
	salary_earned += amount
	print("Uang nambah! Total: ¥", money)
	emit_signal("uang_berubah")

func deduct_money(amount: int):
	money -= amount
	fines_incurred += amount
	print("Kena denda! Total: ¥", money)
	emit_signal("uang_berubah")
	if money < 0:
		trigger_game_over()

func trigger_game_over():
	print("Game Over")
	emit_signal("on_game_over")

func try_throw_bag(bag_category: String, wrong_items_count: int = 0, right_items_count: int = 0) -> bool:
	var today = days_list[current_day_index]
	var allowed_categories = schedule[today]
	var is_correct_day = true
	
	if bag_category in allowed_categories:
		add_money(5)
		print("Berhasil buang ", bag_category, " di hari ", today)
	else:
		deduct_money(5)
		print("Salah hari! ", today, " bukan jadwal buat ", bag_category)
		is_correct_day = false
		
	if right_items_count > 0:
		var total = right_items_count * 5
		add_money(total)
	if wrong_items_count > 0:
		var total = wrong_items_count * 5
		deduct_money(total)
	
	return is_correct_day
