extends Area2D

# Area untuk trigger otomatis (tanpa perlu press Enter)
# Digunakan untuk library work zone dan cafe relaxation zone

@export var area_type: String = "work"  # "work" atau "relax"

var player_in_area: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		print("AutoTrigger: Player entered ", area_type, " area")
		
		if area_type == "work":
			body.set_in_library_work_area(true)
		elif area_type == "relax":
			body.set_in_cafe_area(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		print("AutoTrigger: Player exited ", area_type, " area")
		
		if area_type == "work":
			body.set_in_library_work_area(false)
		elif area_type == "relax":
			body.set_in_cafe_area(false)
