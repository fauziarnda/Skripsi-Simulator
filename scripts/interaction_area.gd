extends Area2D

signal interacted

@export var location_name: String = ""
@export var interaction_type: String = ""  # "college", "library", "cafe"

var player_in_range: bool = false
var dialog_system: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	print("InteractionArea: Body entered - ", body.name, " at ", location_name)
	if body.is_in_group("player"):
		print("InteractionArea: Player detected at ", location_name)
		player_in_range = true
		show_interaction_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("InteractionArea: Player exited from ", location_name)
		player_in_range = false
		hide_interaction_prompt()

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		print("InteractionArea: Enter pressed at ", location_name)
		interact()

func interact() -> void:
	emit_signal("interacted")
	
	var game_manager = get_node("/root/GameManager")
	
	match interaction_type:
		"college":
			handle_college_interaction()
		"library":
			handle_library_interaction()
		"cafe":
			handle_cafe_interaction()

func handle_college_interaction() -> void:
	var game_manager = get_node("/root/GameManager")
	
	if not game_manager.has_chosen_advisor:
		# Show advisor selection dialog
		if not dialog_system:
			dialog_system = get_tree().get_first_node_in_group("dialog_system")
		
		if dialog_system:
			var dialog = [
				{"name": "Staff", "text": "Selamat datang di gedung perkuliahan. Anda perlu memilih dosen pembimbing untuk skripsi Anda."}
			]
			dialog_system.show_dialog(dialog)
			await dialog_system.dialog_finished
			
			# Show advisor choices
			dialog_system.show_choices([
				"Dr. Ahmad (Rekayasa Perangkat Lunak)",
				"Dr. Budi (Artificial Intelligence)",
				"Dr. Citra (Jaringan Komputer)"
			])
			
			var choice = await dialog_system.choice_made
			
			match choice:
				0:
					game_manager.set_advisor("Dr. Ahmad")
				1:
					game_manager.set_advisor("Dr. Budi")
				2:
					game_manager.set_advisor("Dr. Citra")
			
			# Show confirmation
			dialog = [
				{"name": game_manager.advisor_name, "text": "Baik, saya akan menjadi pembimbing Anda. Selamat mengerjakan skripsi!"}
			]
			dialog_system.show_dialog(dialog)
			await dialog_system.dialog_finished
	else:
		# Bimbingan dengan dosen
		if not dialog_system:
			dialog_system = get_tree().get_first_node_in_group("dialog_system")
		
		if dialog_system:
			var dialog = [
				{"name": game_manager.advisor_name, "text": "Bagaimana progress skripsi Anda? Sudah sampai mana?"},
				{"name": "Player", "text": "Progress saya sudah " + str(int(game_manager.thesis_progress)) + "%, Pak."},
				{"name": game_manager.advisor_name, "text": "Bagus! Terus semangat ya. Jangan lupa istirahat juga."}
			]
			dialog_system.show_dialog(dialog)
			await dialog_system.dialog_finished
			
			game_manager.meet_advisor()

func handle_library_interaction() -> void:
	var game_manager = get_node("/root/GameManager")
	
	if not dialog_system:
		dialog_system = get_tree().get_first_node_in_group("dialog_system")
	
	if not game_manager.has_chosen_topic:
		# Pilih topik skripsi
		if dialog_system:
			var dialog = [
				{"name": "Pustakawan", "text": "Selamat datang di perpustakaan. Silakan pilih topik skripsi Anda."}
			]
			dialog_system.show_dialog(dialog)
			await dialog_system.dialog_finished
			
			dialog_system.show_choices([
				"Rekayasa Perangkat Lunak",
				"Artificial Intelligence",
				"Jaringan Komputer"
			])
			
			var choice = await dialog_system.choice_made
			
			match choice:
				0:
					game_manager.set_thesis_topic("Rekayasa Perangkat Lunak")
				1:
					game_manager.set_thesis_topic("Artificial Intelligence")
				2:
					game_manager.set_thesis_topic("Jaringan Komputer")
	else:
		# Kerjakan skripsi
		if dialog_system:
			var dialog = [
				{"name": "System", "text": "Anda mulai mengerjakan skripsi. Tetap di area ini untuk menambah progress."}
			]
			dialog_system.show_dialog(dialog)
			await dialog_system.dialog_finished

func handle_cafe_interaction() -> void:
	var game_manager = get_node("/root/GameManager")
	
	if not dialog_system:
		dialog_system = get_tree().get_first_node_in_group("dialog_system")
	
	if dialog_system:
		var dialog = [
			{"name": "Barista", "text": "Selamat datang di kafe! Santai sebentar untuk mengembalikan motivasi Anda."}
		]
		dialog_system.show_dialog(dialog)
		await dialog_system.dialog_finished

func show_interaction_prompt() -> void:
	if has_node("Label"):
		$Label.visible = true

func hide_interaction_prompt() -> void:
	if has_node("Label"):
		$Label.visible = false
