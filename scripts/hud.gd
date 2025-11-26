extends CanvasLayer

@onready var semester_label = $HUD/TopBar/SemesterLabel
@onready var time_label = $HUD/TopBar/TimeLabel
@onready var motivation_bar = $HUD/StatsBar/MotivationBar
@onready var stamina_bar = $HUD/StatsBar/StaminaBar
@onready var motivation_label = $HUD/StatsBar/MotivationLabel
@onready var stamina_label = $HUD/StatsBar/StaminaLabel
@onready var progress_label = $HUD/ProgressBar/ProgressLabel
@onready var progress_bar = $HUD/ProgressBar/ThesisProgressBar
@onready var advisor_label = $HUD/InfoBar/AdvisorLabel
@onready var topic_label = $HUD/InfoBar/TopicLabel

var game_manager: Node

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	
	# Connect signals
	game_manager.semester_changed.connect(_on_semester_changed)
	game_manager.stats_changed.connect(_on_stats_changed)
	game_manager.thesis_progress_changed.connect(_on_thesis_progress_changed)
	
	update_all_ui()

func _process(_delta: float) -> void:
	if game_manager:
		update_time_label()

func update_all_ui() -> void:
	_on_semester_changed(game_manager.current_semester)
	_on_stats_changed(game_manager.motivation, game_manager.stamina)
	_on_thesis_progress_changed(game_manager.thesis_progress)
	update_info_labels()

func update_time_label() -> void:
	var time_remaining = game_manager.get_semester_time_remaining()
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	time_label.text = "Time: %02d:%02d" % [minutes, seconds]

func _on_semester_changed(semester: int) -> void:
	semester_label.text = "Semester: " + str(semester)

func _on_stats_changed(motivation: float, stamina: float) -> void:
	motivation_bar.value = motivation
	stamina_bar.value = stamina
	motivation_label.text = "Motivasi: %d%%" % int(motivation)
	stamina_label.text = "Stamina: %d%%" % int(stamina)

func _on_thesis_progress_changed(progress: float) -> void:
	progress_bar.value = progress
	progress_label.text = "Progress Skripsi: %d%%" % int(progress)

func update_info_labels() -> void:
	if game_manager.has_chosen_advisor:
		advisor_label.text = "Dosen: " + game_manager.advisor_name
	else:
		advisor_label.text = "Dosen: Belum dipilih"
	
	if game_manager.has_chosen_topic:
		topic_label.text = "Topik: " + game_manager.thesis_topic
	else:
		topic_label.text = "Topik: Belum dipilih"
