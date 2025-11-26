extends Node2D

# Scene controller untuk indoor locations
var game_manager: Node
var player: Node

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	
	# Find player in scene
	player = get_tree().get_first_node_in_group("player")
	
	# Position player at spawn point if coming from another scene
	position_player_at_spawn()

func position_player_at_spawn() -> void:
	if not player:
		return
	
	var spawn_point = get_node_or_null("SpawnPoint")
	if spawn_point:
		player.position = spawn_point.position
		print("Player spawned at: ", spawn_point.position)
