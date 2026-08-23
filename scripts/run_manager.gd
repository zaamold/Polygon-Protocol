extends Node

var xp: int = 0
var level: int = 1
var upgrade_manager: Node

func _ready() -> void:
	upgrade_manager = get_parent().get_node("UpgradeManager")
	print("Run started - XP: 0, Level: 1")

func add_xp(amount: int) -> void:
	xp += amount
	print("XP gained: +", amount, " | Total XP: ", xp)
	_check_levelup()

func _check_levelup() -> void:
	var xp_required = level * 50  # 50 XP per level
	if xp >= xp_required:
		level += 1
		xp = 0  # Reset XP for next level
		print("LEVEL UP! Now level ", level)
		if upgrade_manager:
			upgrade_manager._show_upgrade_choice()
