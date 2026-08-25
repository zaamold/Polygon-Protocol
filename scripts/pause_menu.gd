extends CanvasLayer

@onready var overlay = $PanelContainer
@onready var vbox = $PanelContainer/MarginContainer/VBoxContainer
@onready var actions_section = $PanelContainer/MarginContainer/VBoxContainer/ActionsSection
@onready var stats_section = $PanelContainer/MarginContainer/VBoxContainer/StatsSection

var is_paused := false
var is_in_options := false
var player: Node
var run_manager: Node
var level_up_ui: CanvasLayer
var options_panel: PanelContainer
var menu_buttons: Array[Button] = []
var current_focus_index := 0
var was_level_up_active_before_pause := false

func _ready() -> void:
	var main = get_parent()
	player = main.get_node("Player")
	run_manager = main.get_node("RunManager")
	level_up_ui = main.get_node("LevelUpUI")

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
	menu_buttons.append(resume_btn)

	var options_btn = Button.new()
	options_btn.text = "Options"
	options_btn.pressed.connect(_on_options_pressed)
	options_btn.focus_mode = Control.FOCUS_ALL
	actions_vbox.add_child(options_btn)
	menu_buttons.append(options_btn)

	var quit_btn = Button.new()
	quit_btn.text = "Quit"
	quit_btn.pressed.connect(_on_quit_pressed)
	quit_btn.focus_mode = Control.FOCUS_ALL
	actions_vbox.add_child(quit_btn)
	menu_buttons.append(quit_btn)

	actions_section.add_child(actions_vbox)

	current_focus_index = 0
	resume_btn.grab_focus.call_deferred()

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
		if level_up_ui.is_level_up_active:
			# Pause pressed while level-up is active: hide level-up, show pause menu
			# Don't toggle paused state—it's already true from level-up
			was_level_up_active_before_pause = true
			level_up_ui.hide_ui()
			is_paused = true
			overlay.visible = true
			_update_stats_display()
			print("Pause menu opened (level-up was hidden)")
		else:
			print("Pause input detected - current state: is_paused=%s" % is_paused)
			toggle_pause()

	if not is_paused:
		return

	# Menu navigation with ui_up/ui_down
	if Input.is_action_just_pressed("ui_up"):
		current_focus_index = (current_focus_index - 1) % menu_buttons.size()
		if menu_buttons.size() > 0:
			menu_buttons[current_focus_index].grab_focus.call_deferred()
			print("Menu nav: up to %s (index %d)" % [menu_buttons[current_focus_index].text, current_focus_index])

	if Input.is_action_just_pressed("ui_down"):
		current_focus_index = (current_focus_index + 1) % menu_buttons.size()
		if menu_buttons.size() > 0:
			menu_buttons[current_focus_index].grab_focus.call_deferred()
			print("Menu nav: down to %s (index %d)" % [menu_buttons[current_focus_index].text, current_focus_index])

	# Menu confirmation (A button)
	if Input.is_action_just_pressed("ui_accept"):
		if menu_buttons.size() > 0 and current_focus_index < menu_buttons.size():
			print("Menu confirm: %s" % menu_buttons[current_focus_index].text)
			menu_buttons[current_focus_index].pressed.emit()

	# Menu cancel/back (B button)
	if Input.is_action_just_pressed("ui_cancel"):
		if is_in_options:
			_on_back_from_options_pressed()
			print("Menu cancel: back to pause menu")
		else:
			toggle_pause()
			print("Menu cancel: unpause")

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
	if was_level_up_active_before_pause:
		was_level_up_active_before_pause = false
		# Restore level-up UI with the same options that were being presented
		level_up_ui.show_upgrade_options(level_up_ui.current_options)
		is_paused = false
		overlay.visible = false
		print("Resumed to level-up UI")
	else:
		toggle_pause()

func _on_options_pressed() -> void:
	is_in_options = true
	_show_options_panel()

func _show_options_panel() -> void:
	actions_section.visible = false
	stats_section.visible = false

	if not options_panel:
		print("[PauseMenu] Creating options panel...")
		options_panel = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 20)
		margin.add_theme_constant_override("margin_right", 20)
		margin.add_theme_constant_override("margin_top", 20)
		margin.add_theme_constant_override("margin_bottom", 20)

		var vbox_options = VBoxContainer.new()
		vbox_options.add_theme_constant_override("separation", 15)

		var title = Label.new()
		title.text = "Display Settings"
		vbox_options.add_child(title)

		vbox_options.add_child(Label.new())  # Spacer

		# Display Mode section
		var display_mode_label = Label.new()
		display_mode_label.text = "Display Mode:"
		vbox_options.add_child(display_mode_label)

		var display_mode_hbox = HBoxContainer.new()
		display_mode_hbox.add_theme_constant_override("separation", 10)

		var windowed_btn = Button.new()
		windowed_btn.text = "Windowed"
		windowed_btn.name = "WindowedButton"
		windowed_btn.pressed.connect(_on_windowed_pressed)
		windowed_btn.focus_mode = Control.FOCUS_ALL
		display_mode_hbox.add_child(windowed_btn)
		print("[PauseMenu] Created Windowed button")

		var fullscreen_btn = Button.new()
		fullscreen_btn.text = "Borderless FS"
		fullscreen_btn.name = "FullscreenButton"
		fullscreen_btn.pressed.connect(_on_fullscreen_pressed)
		fullscreen_btn.focus_mode = Control.FOCUS_ALL
		display_mode_hbox.add_child(fullscreen_btn)
		print("[PauseMenu] Created Fullscreen button")

		vbox_options.add_child(display_mode_hbox)

		vbox_options.add_child(Label.new())  # Spacer

		# Resolution section
		var resolution_label = Label.new()
		resolution_label.text = "Resolution (Windowed):"
		resolution_label.name = "ResolutionLabel"
		vbox_options.add_child(resolution_label)

		var resolution_hbox = HBoxContainer.new()
		resolution_hbox.add_theme_constant_override("separation", 5)
		resolution_hbox.name = "ResolutionBox"

		for res in DisplaySettings.get_resolution_presets():
			var res_btn = Button.new()
			res_btn.text = "%dx%d" % [res.x, res.y]
			res_btn.pressed.connect(func(): _on_resolution_pressed(res))
			res_btn.focus_mode = Control.FOCUS_ALL
			resolution_hbox.add_child(res_btn)
		print("[PauseMenu] Created %d resolution buttons" % DisplaySettings.get_resolution_presets().size())

		vbox_options.add_child(resolution_hbox)

		vbox_options.add_child(Label.new())  # Spacer

		var back_btn = Button.new()
		back_btn.text = "Back"
		back_btn.name = "BackButton"
		back_btn.pressed.connect(_on_back_from_options_pressed)
		back_btn.focus_mode = Control.FOCUS_ALL
		vbox_options.add_child(back_btn)

		margin.add_child(vbox_options)
		options_panel.add_child(margin)
		vbox.add_child(options_panel)

	options_panel.visible = true
	_populate_options_buttons()
	print("Options menu opened (paused=%s)" % get_tree().paused)

func _populate_options_buttons() -> void:
	menu_buttons.clear()
	var margin = options_panel.get_child(0)
	var options_vbox = margin.get_child(0)

	# Collect all buttons from the options panel
	for child in options_vbox.get_children():
		if child is Button:
			menu_buttons.append(child)
		elif child is HBoxContainer:
			for btn in child.get_children():
				if btn is Button:
					menu_buttons.append(btn)

	if menu_buttons.size() > 0:
		current_focus_index = 0
		menu_buttons[0].grab_focus.call_deferred()

func _on_windowed_pressed() -> void:
	print("\n>>> [PauseMenu.BUTTON] WINDOWED BUTTON PRESSED <<<")
	print("    Current mode: ", DisplaySettings.current_mode, " -> Setting to WINDOWED")
	DisplaySettings.set_display_mode(DisplaySettings.DisplayMode.WINDOWED)
	print("    Mode is now: ", DisplaySettings.current_mode)
	print("    Window size: ", get_window().size)
	print()

func _on_fullscreen_pressed() -> void:
	print("\n>>> [PauseMenu.BUTTON] FULLSCREEN BUTTON PRESSED <<<")
	print("    Current mode: ", DisplaySettings.current_mode, " -> Setting to BORDERLESS_FULLSCREEN")
	DisplaySettings.set_display_mode(DisplaySettings.DisplayMode.BORDERLESS_FULLSCREEN)
	print("    Mode is now: ", DisplaySettings.current_mode)
	print()

func _on_resolution_pressed(resolution: Vector2i) -> void:
	print("\n>>> [PauseMenu.BUTTON] RESOLUTION BUTTON PRESSED: %s <<<" % resolution)
	print("    Current resolution: ", DisplaySettings.current_resolution, " -> Setting to ", resolution)
	DisplaySettings.set_resolution(resolution)
	print("    Resolution is now: ", DisplaySettings.current_resolution)
	print("    Window size: ", get_window().size)
	print()

func _on_back_from_options_pressed() -> void:
	is_in_options = false
	options_panel.visible = false
	actions_section.visible = true
	stats_section.visible = true

	# Restore root pause menu buttons
	menu_buttons.clear()
	var actions_vbox = actions_section.get_child(0)
	for i in range(actions_vbox.get_child_count()):
		var child = actions_vbox.get_child(i)
		if child is Button:
			menu_buttons.append(child)

	current_focus_index = 1  # Focus on Options button
	var options_btn = actions_section.get_child(0).get_child(1)  # VBoxContainer -> Options button
	if options_btn:
		options_btn.grab_focus.call_deferred()
	print("Returned to pause menu (paused=%s)" % get_tree().paused)

func _on_quit_pressed() -> void:
	get_tree().quit()
