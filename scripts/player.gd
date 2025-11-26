extends CharacterBody2D


const SPEED = 100.0

var game_manager: Node
var current_interaction_area: String = ""
var in_library_work_area: bool = false
var in_cafe_area: bool = false

func _ready() -> void:
	add_to_group("player")
	game_manager = get_node("/root/GameManager")
	
	# Load saved position if continuing game
	if game_manager.has_chosen_advisor or game_manager.has_chosen_topic:
		position = game_manager.player_house_position

func _physics_process(delta: float) -> void:
	move_and_slide()

func _process(delta):
	# Don't process movement if game is paused
	if game_manager and game_manager.is_paused:
		return
	
	# Handle work/cafe activities
	if in_library_work_area:
		game_manager.work_on_thesis(delta)
	elif in_cafe_area:
		game_manager.visit_cafe(delta)
	
	var velocity_vec = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("right"):
		velocity_vec.x += 1
		$AnimatedSprite2D.animation = "walk_right"
	if Input.is_action_pressed("left"):
		velocity_vec.x -= 1
		$AnimatedSprite2D.animation = "walk_left"
	if Input.is_action_pressed("down"):
		velocity_vec.y += 1
		$AnimatedSprite2D.animation = "walk_down"
	if Input.is_action_pressed("up"):
		velocity_vec.y -= 1
		$AnimatedSprite2D.animation = "walk_up"

	if velocity_vec.length() > 0:
		velocity_vec = velocity_vec.normalized() * SPEED
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity_vec * delta
	
	# Save position for game saves
	if game_manager:
		game_manager.player_house_position = position

func set_in_library_work_area(value: bool) -> void:
	in_library_work_area = value

func set_in_cafe_area(value: bool) -> void:
	in_cafe_area = value
	
	
	
