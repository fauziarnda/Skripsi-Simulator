extends Control

@onready var message_label = $Panel/MessageLabel
@onready var details_label = $Panel/DetailsLabel
@onready var main_menu_button = $Panel/MainMenuButton
@onready var exit_button = $Panel/ExitButton

var game_manager: Node

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Auto show game over based on GameManager state
	show_game_over(game_manager.game_over_success)

func show_game_over(success: bool) -> void:
	if success:
		message_label.text = "SELAMAT!"
		details_label.text = "Anda berhasil menyelesaikan skripsi!\n\nSemester: %d\nProgress: 100%%" % game_manager.current_semester
	else:
		message_label.text = "GAME OVER"
		details_label.text = "Anda gagal menyelesaikan skripsi dalam waktu yang ditentukan.\n\nBatas maksimal adalah Semester 14."

func _on_main_menu_pressed() -> void:
	# Reset game manager state
	game_manager.new_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
