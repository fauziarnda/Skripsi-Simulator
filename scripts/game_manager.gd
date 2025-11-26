extends Node

# Singleton untuk mengelola state game
signal semester_changed(new_semester)
signal thesis_progress_changed(progress)
signal stats_changed(motivation, stamina)
signal game_over(success: bool)

# Game state
var current_semester: int = 7
var semester_time_limit: float = 900.0  # 15 menit dalam detik
var current_time: float = 0.0
var is_paused: bool = false
var game_over_success: bool = false  # Track win/lose status

# Player stats
var motivation: float = 50.0  # 0-100
var stamina: float = 50.0  # 0-100

# Thesis progress
var has_chosen_advisor: bool = false
var advisor_name: String = ""
var has_chosen_topic: bool = false
var thesis_topic: String = ""  # "RPL", "AI", atau "Jaringan"
var thesis_progress: float = 0.0  # 0-100
var thesis_completed: bool = false

# Locations
var player_house_position: Vector2 = Vector2(88, 155)
var current_location: String = "house"

# Save data
var save_file_path: String = "user://skripsi_simulator_save.dat"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always process even when paused

func _process(delta: float) -> void:
	if is_paused or thesis_completed:
		return
	
	# Update semester timer
	current_time += delta
	
	# Check if semester time is up
	if current_time >= semester_time_limit:
		next_semester()

func next_semester() -> void:
	current_semester += 1
	current_time = 0.0
	
	emit_signal("semester_changed", current_semester)
	
	# Check game over condition
	if current_semester > 14 and not thesis_completed:
		# Game over - gagal
		print("GAME OVER - Semester limit exceeded!")
		game_over_success = false
		thesis_completed = true
		delete_save_file()  # Delete save when losing
		emit_signal("game_over", false)
		call_deferred("_change_to_game_over")

func work_on_thesis(delta: float) -> void:
	"""Player mengerjakan skripsi di perpustakaan"""
	if not has_chosen_topic or not has_chosen_advisor:
		if not has_chosen_advisor:
			print("Cannot work: Need to choose advisor first at College")
		elif not has_chosen_topic:
			print("Cannot work: Need to choose topic first at Library counter")
		return
	
	# Check if already completed
	if thesis_completed:
		return
	
	# Menambah progress skripsi
	var work_rate = 0.5  # Progress per detik
	thesis_progress += work_rate * delta
	
	# Cap progress at 100%
	if thesis_progress >= 100.0:
		thesis_progress = 100.0
		thesis_completed = true
		game_over_success = true
		print("THESIS COMPLETED! You win!")
		delete_save_file()  # Delete save when winning
		emit_signal("game_over", true)
		# Show game over screen
		call_deferred("_change_to_game_over")
		return
	
	print("Working on thesis - Progress: ", thesis_progress, "%")
	
	# Menambah stamina (belajar)
	stamina = min(100.0, stamina + 0.3 * delta)
	
	# Mengurangi motivasi (stress)
	motivation = max(0.0, motivation - 0.4 * delta)
	
	emit_signal("stats_changed", motivation, stamina)
	emit_signal("thesis_progress_changed", thesis_progress)

func visit_cafe(delta: float) -> void:
	"""Player mengunjungi kafe"""
	# Menambah motivasi
	motivation = min(100.0, motivation + 0.8 * delta)
	
	# Mengurangi stamina
	stamina = max(0.0, stamina - 0.5 * delta)
	
	emit_signal("stats_changed", motivation, stamina)

func meet_advisor() -> void:
	"""Player bimbingan dengan dosen"""
	if not has_chosen_advisor:
		return
	
	# Bimbingan menambah sedikit progress dan motivasi
	thesis_progress += 5.0
	motivation = min(100.0, motivation + 10.0)
	
	emit_signal("thesis_progress_changed", thesis_progress)
	emit_signal("stats_changed", motivation, stamina)

func set_advisor(name: String) -> void:
	advisor_name = name
	has_chosen_advisor = true
	print("Advisor chosen: ", advisor_name)

func set_thesis_topic(topic: String) -> void:
	thesis_topic = topic
	has_chosen_topic = true
	print("Topic chosen: ", thesis_topic)
	has_chosen_topic = true

func get_semester_time_remaining() -> float:
	return semester_time_limit - current_time

func get_semester_progress() -> float:
	return (current_time / semester_time_limit) * 100.0

# Save and Load functions
func save_game() -> void:
	var save_data = {
		"current_semester": current_semester,
		"current_time": current_time,
		"motivation": motivation,
		"stamina": stamina,
		"has_chosen_advisor": has_chosen_advisor,
		"advisor_name": advisor_name,
		"has_chosen_topic": has_chosen_topic,
		"thesis_topic": thesis_topic,
		"thesis_progress": thesis_progress,
		"thesis_completed": thesis_completed,
		"player_position": {
			"x": get_tree().get_first_node_in_group("player").position.x if get_tree().get_first_node_in_group("player") else 88,
			"y": get_tree().get_first_node_in_group("player").position.y if get_tree().get_first_node_in_group("player") else 155
		},
		"current_location": current_location
	}
	
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully")

func load_game() -> bool:
	if not FileAccess.file_exists(save_file_path):
		return false
	
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		current_semester = save_data.get("current_semester", 7)
		current_time = save_data.get("current_time", 0.0)
		motivation = save_data.get("motivation", 50.0)
		stamina = save_data.get("stamina", 50.0)
		has_chosen_advisor = save_data.get("has_chosen_advisor", false)
		advisor_name = save_data.get("advisor_name", "")
		has_chosen_topic = save_data.get("has_chosen_topic", false)
		thesis_topic = save_data.get("thesis_topic", "")
		thesis_progress = save_data.get("thesis_progress", 0.0)
		thesis_completed = save_data.get("thesis_completed", false)
		current_location = save_data.get("current_location", "house")
		
		var player_pos = save_data.get("player_position", {"x": 88, "y": 155})
		player_house_position = Vector2(player_pos.x, player_pos.y)
		
		print("Game loaded successfully")
		return true
	
	return false

func has_save_file() -> bool:
	return FileAccess.file_exists(save_file_path)

func delete_save_file() -> void:
	"""Hapus save file"""
	if FileAccess.file_exists(save_file_path):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("skripsi_simulator_save.dat")
			print("Save file deleted: ", save_file_path)
		else:
			print("Failed to open user directory")
	else:
		print("No save file to delete")

func new_game() -> void:
	"""Reset semua data untuk game baru"""
	current_semester = 7
	current_time = 0.0
	motivation = 50.0
	stamina = 50.0
	has_chosen_advisor = false
	advisor_name = ""
	has_chosen_topic = false
	thesis_topic = ""
	thesis_progress = 0.0
	thesis_completed = false
	game_over_success = false
	current_location = "house"
	player_house_position = Vector2(88, 155)
	is_paused = false

func _change_to_game_over() -> void:
	"""Change to game over scene safely"""
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
