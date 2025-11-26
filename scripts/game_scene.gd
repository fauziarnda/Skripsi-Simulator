extends Node2D

var game_manager: Node
var game_over_scene = preload("res://scenes/game_over.tscn")

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	
	# Connect game over signal
	game_manager.game_over.connect(_on_game_over)

func _on_game_over(success: bool) -> void:
	# Show game over screen
	var game_over = game_over_scene.instantiate()
	add_child(game_over)
	game_over.show_game_over(success)
