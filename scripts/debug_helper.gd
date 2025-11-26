extends Node

# Debug helper untuk testing game
# Attach ke game scene atau enable via autoload

var debug_enabled: bool = true
var game_manager: Node

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	
	if debug_enabled:
		print("=== DEBUG MODE ENABLED ===")
		print("Shortcuts:")
		print("  F1: +10% Thesis Progress")
		print("  F2: +5 Minutes Time")
		print("  F3: Complete Thesis Instantly")
		print("  F4: Toggle Thesis Requirements")
		print("  F5: Reset to Semester 7")
		print("  F6: Jump to Semester 14")
		print("  F7: Max Motivation")
		print("  F8: Max Stamina")
		print("  F9: Print Current Stats")
		print("  F10: Delete Save File")

func _input(event: InputEvent) -> void:
	if not debug_enabled or not game_manager:
		return
	
	# F1: Add thesis progress
	if event.is_action_pressed("ui_text_indent"):  # F1
		game_manager.thesis_progress = min(100.0, game_manager.thesis_progress + 10.0)
		print("Thesis progress: %.1f%%" % game_manager.thesis_progress)
	
	# F2: Fast forward time
	elif event.is_action_pressed("ui_text_dedent"):  # F2
		game_manager.current_time += 300  # +5 minutes
		print("Time forwarded: %.0f seconds" % game_manager.current_time)
	
	# F3: Complete thesis
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		game_manager.thesis_progress = 100.0
		game_manager.has_chosen_advisor = true
		game_manager.has_chosen_topic = true
		game_manager.advisor_name = "Dr. Debug"
		game_manager.thesis_topic = "Debug Mode"
		print("Thesis completed!")
	
	# F4: Toggle thesis requirements
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F4:
		game_manager.has_chosen_advisor = not game_manager.has_chosen_advisor
		game_manager.has_chosen_topic = not game_manager.has_chosen_topic
		if game_manager.has_chosen_advisor:
			game_manager.advisor_name = "Dr. Debug"
		if game_manager.has_chosen_topic:
			game_manager.thesis_topic = "Debug Topic"
		print("Requirements toggled: Advisor=%s, Topic=%s" % [game_manager.has_chosen_advisor, game_manager.has_chosen_topic])
	
	# F5: Reset to semester 7
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F5:
		game_manager.current_semester = 7
		game_manager.current_time = 0.0
		print("Reset to Semester 7")
	
	# F6: Jump to semester 14
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F6:
		game_manager.current_semester = 14
		game_manager.current_time = 0.0
		print("Jumped to Semester 14")
	
	# F7: Max motivation
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F7:
		game_manager.motivation = 100.0
		print("Motivation maxed!")
	
	# F8: Max stamina
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F8:
		game_manager.stamina = 100.0
		print("Stamina maxed!")
	
	# F9: Print stats
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F9:
		print_stats()
	
	# F10: Delete save
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F10:
		delete_save_file()

func print_stats() -> void:
	print("\n=== CURRENT GAME STATE ===")
	print("Semester: %d / 14" % game_manager.current_semester)
	print("Time: %.0f / %.0f seconds" % [game_manager.current_time, game_manager.semester_time_limit])
	print("Time Remaining: %.0f seconds (%.1f minutes)" % [game_manager.get_semester_time_remaining(), game_manager.get_semester_time_remaining() / 60.0])
	print("Motivation: %.1f%%" % game_manager.motivation)
	print("Stamina: %.1f%%" % game_manager.stamina)
	print("Thesis Progress: %.1f%%" % game_manager.thesis_progress)
	print("Has Advisor: %s (%s)" % [game_manager.has_chosen_advisor, game_manager.advisor_name])
	print("Has Topic: %s (%s)" % [game_manager.has_chosen_topic, game_manager.thesis_topic])
	print("Thesis Completed: %s" % game_manager.thesis_completed)
	print("Is Paused: %s" % game_manager.is_paused)
	print("========================\n")

func delete_save_file() -> void:
	var save_path = game_manager.save_file_path
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		print("Save file deleted: %s" % save_path)
	else:
		print("No save file found")

# Quick spawn functions for testing
func spawn_at_library() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.position = Vector2(500, 150)
		print("Player spawned at library")

func spawn_at_college() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.position = Vector2(300, 150)
		print("Player spawned at college")

func spawn_at_cafe() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.position = Vector2(700, 150)
		print("Player spawned at cafe")
