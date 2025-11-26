extends CanvasLayer

signal dialog_finished
signal choice_made(choice_index: int)

@onready var dialog_box = $DialogBox
@onready var name_label = $DialogBox/NameLabel
@onready var text_label = $DialogBox/TextLabel
@onready var continue_indicator = $DialogBox/ContinueIndicator
@onready var choice_container = $DialogBox/ChoiceContainer

var current_dialog: Array = []
var current_index: int = 0
var is_showing: bool = false
var is_typing: bool = false
var text_speed: float = 0.05
var current_text: String = ""
var char_index: int = 0

var choices: Array = []

func _ready() -> void:
	add_to_group("dialog_system")
	process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_box.visible = false
	choice_container.visible = false
	continue_indicator.visible = false

func _process(_delta: float) -> void:
	if not is_showing:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_typing:
			# Skip typing animation
			text_label.text = current_text
			is_typing = false
			continue_indicator.visible = true
		elif choices.size() == 0:
			# Next dialog
			next_dialog()

func show_dialog(dialog_data: Array) -> void:
	"""
	dialog_data format:
	[
		{"name": "Dosen", "text": "Halo mahasiswa..."},
		{"name": "Player", "text": "Selamat pagi pak"},
	]
	"""
	current_dialog = dialog_data
	current_index = 0
	is_showing = true
	dialog_box.visible = true
	
	get_tree().paused = true
	display_current_dialog()

func display_current_dialog() -> void:
	if current_index >= current_dialog.size():
		hide_dialog()
		return
	
	var dialog = current_dialog[current_index]
	name_label.text = dialog.get("name", "")
	current_text = dialog.get("text", "")
	
	# Start typing animation
	text_label.text = ""
	char_index = 0
	is_typing = true
	continue_indicator.visible = false
	
	start_typing()

func start_typing() -> void:
	while char_index < current_text.length() and is_typing:
		text_label.text += current_text[char_index]
		char_index += 1
		await get_tree().create_timer(text_speed).timeout
	
	if is_typing:
		is_typing = false
		continue_indicator.visible = true

func next_dialog() -> void:
	current_index += 1
	display_current_dialog()

func show_choices(choice_list: Array) -> void:
	"""
	choice_list format: ["Pilihan 1", "Pilihan 2", "Pilihan 3"]
	"""
	choices = choice_list
	choice_container.visible = true
	continue_indicator.visible = false
	
	# Clear existing choices
	for child in choice_container.get_children():
		child.queue_free()
	
	# Create choice buttons
	for i in range(choice_list.size()):
		var button = Button.new()
		button.text = choice_list[i]
		button.pressed.connect(_on_choice_selected.bind(i))
		choice_container.add_child(button)

func _on_choice_selected(index: int) -> void:
	emit_signal("choice_made", index)
	choices = []
	choice_container.visible = false
	hide_dialog()

func hide_dialog() -> void:
	is_showing = false
	dialog_box.visible = false
	choice_container.visible = false
	get_tree().paused = false
	emit_signal("dialog_finished")
