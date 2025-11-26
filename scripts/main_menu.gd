extends Control

@onready var new_game_button = $MenuContainer/NewGameButton
@onready var continue_button = $MenuContainer/ContinueButton
@onready var exit_button = $MenuContainer/ExitButton

var game_manager: Node

func _ready() -> void:
	# Get or create GameManager
	if not get_tree().root.has_node("GameManager"):
		var gm = load("res://scripts/game_manager.gd").new()
		gm.name = "GameManager"
		get_tree().root.add_child(gm)
	
	game_manager = get_node("/root/GameManager")
	
	# Check if save file exists
	if game_manager.has_save_file():
		continue_button.disabled = false
	else:
		continue_button.disabled = true
	
	# Connect buttons
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_new_game_pressed() -> void:
	game_manager.new_game()
	get_tree().change_scene_to_file("res://game.tscn")

func _on_continue_pressed() -> void:
	if game_manager.load_game():
		get_tree().change_scene_to_file("res://game.tscn")
	else:
		print("Failed to load save file")

func _on_exit_pressed() -> void:
	get_tree().quit()
