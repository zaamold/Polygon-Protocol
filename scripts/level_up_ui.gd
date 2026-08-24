extends CanvasLayer

@onready var overlay = $Overlay
@onready var option1_label = $Panel/VBoxContainer/Option1
@onready var option2_label = $Panel/VBoxContainer/Option2
@onready var option3_label = $Panel/VBoxContainer/Option3

var upgrade_manager: Node
var current_options: Array = []
var selected_index: int = 0
var is_level_up_active: bool = false

func _ready() -> void:
	hide_ui()
	upgrade_manager = get_parent().get_node("UpgradeManager")
	process_mode = PROCESS_MODE_ALWAYS

func show_upgrade_options(options: Array) -> void:
	current_options = options
	selected_index = 0
	is_level_up_active = true

	if options.size() >= 1:
		option1_label.text = "[1] " + options[0].name + " - " + options[0].description
	if options.size() >= 2:
		option2_label.text = "[2] " + options[1].name + " - " + options[1].description
	if options.size() >= 3:
		option3_label.text = "[3] " + options[2].name + " - " + options[2].description

	$Panel.show()
	overlay.show()
	_update_selection_display()

func hide_ui() -> void:
	$Panel.hide()
	overlay.hide()
	is_level_up_active = false
	current_options.clear()
	selected_index = 0

func _input(event: InputEvent) -> void:
	if not is_level_up_active:
		return

	# Keyboard input: 1, 2, 3 keys
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_select_option(0)
				get_tree().root.set_input_as_handled()
			KEY_2:
				_select_option(1)
				get_tree().root.set_input_as_handled()
			KEY_3:
				_select_option(2)
				get_tree().root.set_input_as_handled()

func _process(_delta: float) -> void:
	if not is_level_up_active or current_options.size() == 0:
		return

	# Controller input: D-Pad up/down for navigation
	if Input.is_action_just_pressed("ui_up"):
		selected_index = (selected_index - 1) % current_options.size()
		_update_selection_display()

	if Input.is_action_just_pressed("ui_down"):
		selected_index = (selected_index + 1) % current_options.size()
		_update_selection_display()

	# Confirm selection with A button or Enter
	if Input.is_action_just_pressed("ui_accept"):
		_select_option(selected_index)

func _select_option(index: int) -> void:
	if index >= 0 and index < current_options.size():
		if upgrade_manager:
			upgrade_manager._apply_upgrade(current_options[index])

func _update_selection_display() -> void:
	# Visual feedback: highlight the selected option
	var options = [option1_label, option2_label, option3_label]
	for i in range(options.size()):
		if i < current_options.size():
			if i == selected_index:
				options[i].modulate = Color.YELLOW
			else:
				options[i].modulate = Color.WHITE
		else:
			options[i].modulate = Color.WHITE
