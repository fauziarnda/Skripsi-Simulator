extends Area2D

@export var target_scene: String = ""  # Path to target scene, e.g., "res://scenes/library_indoor.tscn"
@export var spawn_point_name: String = "SpawnPoint"

var player_in_range: bool = false
var transition_label: Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Create label for prompt
	if not has_node("PromptLabel"):
		transition_label = Label.new()
		transition_label.name = "PromptLabel"
		transition_label.text = "Press Enter to enter"
		transition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		transition_label.position = Vector2(-50, -30)
		transition_label.size = Vector2(100, 20)
		transition_label.visible = false
		add_child(transition_label)
	else:
		transition_label = $PromptLabel

func _on_body_entered(body: Node2D) -> void:
	print("Door: Body entered - ", body.name)
	if body.is_in_group("player"):
		print("Door: Player detected in range")
		player_in_range = true
		if transition_label:
			transition_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if transition_label:
			transition_label.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		print("Door: Enter pressed, transitioning to: ", target_scene)
		transition_to_scene()

func transition_to_scene() -> void:
	if target_scene == "":
		print("Error: No target scene set for door transition")
		return
	
	# Save current state
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.current_location = target_scene
		game_manager.save_game()
	
	# Change scene
	get_tree().change_scene_to_file(target_scene)
