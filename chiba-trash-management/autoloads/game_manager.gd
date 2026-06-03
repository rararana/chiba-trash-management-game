extends Node

signal on_game_over 

var money: int = 100
var current_day_index: int = 0 
var days_list = ["Monday", "Tuesday"]

var schedule = {
	"Monday": ["Combustible"],
	"Tuesday": ["Used Paper"]
}

var saved_items: Array[Dictionary] = []

func add_money(amount: int):
	money += amount
	print("Uang nambah! Total: ¥", money)

func deduct_money(amount: int):
	money -= amount
	print("Kena denda! Total: ¥", money)
	
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
		add_money(5) # Nambah uang karena sesuai jadwal
		print("Berhasil buang ", bag_category, " di hari ", today)
	else:
		deduct_money(5) # Denda karena salah jadwal
		print("Salah hari! ", today, " bukan jadwal buat ", bag_category)
		is_correct_day = false
		
	if right_items_count > 0:
		var money_per_item = 5
		var total_money_received = right_items_count * money_per_item
		add_money(total_money_received)
		print(right_items_count, " barang benar! Tambahan uang: ¥", total_money_received)

	if wrong_items_count > 0:
		var penalty_per_item = 5 # Denda per 1 barang
		var total_item_penalty = wrong_items_count * penalty_per_item
		deduct_money(total_item_penalty)
		print("Ada ", wrong_items_count, " barang salah di dalam kresek ", bag_category, "! Denda tambahan: ¥", total_item_penalty)
	
	return is_correct_day

func next_day():
	current_day_index += 1
	if current_day_index > 6:
		current_day_index = 0
		
	var today = days_list[current_day_index]
	print("Hari berganti menjadi: ", today)
