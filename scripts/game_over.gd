extends CanvasLayer

@onready var panel = $PanelContainer
@onready var vbox = $PanelContainer/MarginContainer/VBoxContainer

var run_manager: Node

func _ready() -> void:
	var main = get_parent()
	run_manager = main.get_node("RunManager")

	panel.visible = false
	process_mode = PROCESS_MODE_ALWAYS

func show_game_over() -> void:
	var hud = get_parent().get_node("HUD")
	if hud:
		hud.update_display()

	get_tree().paused = true
	panel.visible = true

	var time_minutes = int(run_manager.time_survived) / 60
	var time_seconds = int(run_manager.time_survived) % 60

	var title = Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 32)
	vbox.add_child(title)

	vbox.add_child(Label.new())  # Spacer

	var stats_vbox = VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 5)

	var time_label = Label.new()
	time_label.text = "Time: %d:%02d" % [time_minutes, time_seconds]
	stats_vbox.add_child(time_label)

	var level_label = Label.new()
	level_label.text = "Level: %d" % run_manager.level
	stats_vbox.add_child(level_label)

	var kills_label = Label.new()
	kills_label.text = "Enemies Killed: %d" % run_manager.enemies_killed
	stats_vbox.add_child(kills_label)

	vbox.add_child(stats_vbox)

	vbox.add_child(Label.new())  # Spacer

	var restart_btn = Button.new()
	restart_btn.text = "Restart"
	restart_btn.pressed.connect(_on_restart_pressed)
	restart_btn.focus_mode = Control.FOCUS_ALL
	vbox.add_child(restart_btn)

	restart_btn.grab_focus.call_deferred()

	print("Game Over - Time: %d:%02d, Level: %d, Kills: %d" % [time_minutes, time_seconds, run_manager.level, run_manager.enemies_killed])

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
