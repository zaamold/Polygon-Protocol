extends CanvasLayer

@onready var overlay = $Overlay
@onready var option1_label = $Panel/VBoxContainer/Option1
@onready var option2_label = $Panel/VBoxContainer/Option2
@onready var option3_label = $Panel/VBoxContainer/Option3

func _ready() -> void:
	hide_ui()

func show_upgrade_options(options: Array) -> void:
	if options.size() >= 1:
		option1_label.text = "[1] " + options[0].name + " - " + options[0].description
	if options.size() >= 2:
		option2_label.text = "[2] " + options[1].name + " - " + options[1].description
	if options.size() >= 3:
		option3_label.text = "[3] " + options[2].name + " - " + options[2].description

	$Panel.show()
	overlay.show()

func hide_ui() -> void:
	$Panel.hide()
	overlay.hide()
