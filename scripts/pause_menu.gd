extends CanvasLayer

@onready var overlay = $PanelContainer
@onready var vbox = $PanelContainer/MarginContainer/VBoxContainer
@onready var actions_section = $PanelContainer/MarginContainer/VBoxContainer/ActionsSection
@onready var stats_section = $PanelContainer/MarginContainer/VBoxContainer/StatsSection

var is_paused := false
var is_in_options := false
var player: Node
var run_manager: Node
var options_panel: PanelContainer

func _ready() -> void:
	var main = get_parent()
	player = main.get_node("Player")
	run_manager = main.get_node("RunManager")

	overlay.visible = false
	process_mode = PROCESS_MODE_ALWAYS

	_setup_ui()

func _setup_ui() -> void:
	var actions_vbox = VBoxContainer.new()
	actions_vbox.add_theme_constant_override("separation", 10)

	var resume_btn = Button.new()
	resume_btn.text = "Resume"
	resume_btn.pressed.connect(_on_resume_pressed)
	resume_btn.focus_mode = Control.FOCUS_ALL
	actions_vbox.add_child(resume_btn)

	var options_btn = Button.new()
	options_btn.text = "Options"
	options_btn.pressed.connect(_on_options_pressed)
	options_btn.focus_mode = Control.FOCUS_ALL
	actions_vbox.add_child(options_btn)

	var quit_btn = Button.new()
	quit_btn.text = "Quit"
	quit_btn.pressed.connect(_on_quit_pressed)
	quit_btn.focus_mode = Control.FOCUS_ALL
	actions_vbox.add_child(quit_btn)

	resume_btn.grab_focus()

	actions_section.add_child(actions_vbox)

	var stats_vbox = VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 5)

	var level_label = Label.new()
	level_label.text = "Level: -"
	level_label.name = "LevelLabel"
	stats_vbox.add_child(level_label)

	var fire_rate_label = Label.new()
	fire_rate_label.text = "Fire Rate: -"
	fire_rate_label.name = "FireRateLabel"
	stats_vbox.add_child(fire_rate_label)

	var speed_label = Label.new()
	speed_label.text = "Move Speed: -"
	speed_label.name = "SpeedLabel"
	stats_vbox.add_child(speed_label)

	stats_section.add_child(stats_vbox)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		print("Pause input detected - current state: is_paused=%s" % is_paused)
		toggle_pause()

func toggle_pause() -> void:
	is_paused = !is_paused

	if is_paused:
		get_tree().paused = true
		overlay.visible = true
		_update_stats_display()
		print("PAUSED - Game frozen")
	else:
		get_tree().paused = false
		overlay.visible = false
		print("RESUMED - Game running")

func _update_stats_display() -> void:
	var level_label = stats_section.get_child(0).get_node("LevelLabel")
	var fire_rate_label = stats_section.get_child(0).get_node("FireRateLabel")
	var speed_label = stats_section.get_child(0).get_node("SpeedLabel")

	if run_manager:
		level_label.text = "Level: %d" % run_manager.level
	if player:
		fire_rate_label.text = "Fire Rate: %.1f shots/sec" % player.fire_rate
		speed_label.text = "Move Speed: %.0f" % player.speed

	print("Pause Menu Stats - Level: ", run_manager.level if run_manager else "N/A", " | Fire Rate: ", player.fire_rate if player else "N/A", " | Speed: ", player.speed if player else "N/A")

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_options_pressed() -> void:
	is_in_options = true
	_show_options_panel()

func _show_options_panel() -> void:
	actions_section.visible = false
	stats_section.visible = false

	if not options_panel:
		options_panel = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_theme_constant_override("margin_top", 20)
		margin.add_theme_constant_override("margin_bottom", 20)

		var vbox_options = VBoxContainer.new()
		var title = Label.new()
		title.text = "Options (Placeholder)"
		vbox_options.add_child(title)

		vbox_options.add_child(Label.new())  # Spacer

		var back_btn = Button.new()
		back_btn.text = "Back"
		back_btn.pressed.connect(_on_back_from_options_pressed)
		back_btn.focus_mode = Control.FOCUS_ALL
		vbox_options.add_child(back_btn)

		margin.add_child(vbox_options)
		options_panel.add_child(margin)
		vbox.add_child(options_panel)

	options_panel.visible = true
	var back_btn = options_panel.get_child(0).get_child(2)  # MarginContainer -> VBoxContainer -> Back button
	if back_btn:
		back_btn.grab_focus()
	print("Options menu opened (paused=%s)" % get_tree().paused)

func _on_back_from_options_pressed() -> void:
	is_in_options = false
	options_panel.visible = false
	actions_section.visible = true
	stats_section.visible = true
	var options_btn = actions_section.get_child(0).get_child(1)  # VBoxContainer -> Options button
	if options_btn:
		options_btn.grab_focus()
	print("Returned to pause menu (paused=%s)" % get_tree().paused)

func _on_quit_pressed() -> void:
	get_tree().quit()
