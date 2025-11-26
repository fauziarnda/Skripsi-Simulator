extends CanvasLayer

@onready var pause_panel = $PausePanel
@onready var resume_button = $PausePanel/MenuContainer/ResumeButton
@onready var save_button = $PausePanel/MenuContainer/SaveButton
@onready var main_menu_button = $PausePanel/MenuContainer/MainMenuButton
@onready var exit_button = $PausePanel/MenuContainer/ExitButton

var game_manager: Node

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	pause_panel.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect buttons
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func toggle_pause() -> void:
	game_manager.is_paused = not game_manager.is_paused
	pause_panel.visible = game_manager.is_paused
	get_tree().paused = game_manager.is_paused

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_save_pressed() -> void:
	game_manager.save_game()
	# Show save confirmation (optional)

func _on_main_menu_pressed() -> void:
	game_manager.is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
