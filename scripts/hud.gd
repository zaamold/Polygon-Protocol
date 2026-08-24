extends CanvasLayer

@onready var health_bar = $HBoxContainer/VBoxContainer/HealthBar
@onready var xp_bar = $HBoxContainer/VBoxContainer/XPBar
@onready var level_label = $HBoxContainer/VBoxContainer/LevelLabel
@onready var money_label = $HBoxContainer/VBoxContainer/MoneyLabel

var player: Node
var run_manager: Node

func _ready() -> void:
	var main = get_parent()
	player = main.get_node("Player")
	run_manager = main.get_node("RunManager")

	health_bar.max_value = player.max_health
	health_bar.value = player.health

func _process(_delta: float) -> void:
	if not player or not run_manager:
		return

	# Hide HUD when paused
	$HBoxContainer.visible = not get_tree().paused

	update_display()

func update_display() -> void:
	if not player or not run_manager:
		return

	health_bar.value = player.health
	health_bar.tooltip_text = "Health: %.0f/%.0f" % [player.health, player.max_health]

	var xp_required = run_manager.level * 50
	xp_bar.max_value = xp_required
	xp_bar.value = run_manager.xp
	xp_bar.tooltip_text = "XP: %d/%d" % [run_manager.xp, xp_required]

	level_label.text = "Level: %d" % run_manager.level
	money_label.text = "Pickups: %d" % player.pickup_count
