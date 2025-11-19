extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	move_and_slide()

func _ready() -> void:
	pass

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("right"):
		velocity.x += 1
		$AnimatedSprite2D.animation = "walk_right"
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		$AnimatedSprite2D.animation = "walk_left"
	if Input.is_action_pressed("down"):
		velocity.y += 1
		$AnimatedSprite2D.animation = "walk_down"
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		$AnimatedSprite2D.animation = "walk_up"

	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	
	
	
