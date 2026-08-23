extends Node

class Upgrade:
	var name: String
	var description: String
	var apply_func: Callable
	
	func _init(p_name: String, p_desc: String, p_apply: Callable) -> void:
		name = p_name
		description = p_desc
		apply_func = p_apply

var upgrades: Array[Upgrade] = []
var run_manager: Node
var player: Node

func _ready() -> void:
	run_manager = get_parent().get_node("RunManager")
	player = get_parent().get_node("Player")
	_setup_upgrades()

func _setup_upgrades() -> void:
	upgrades.append(Upgrade.new(
		"Speed Boost",
		"+10% move speed",
		func(): player.speed *= 1.1; print("Applied: +10% move speed")
	))
	upgrades.append(Upgrade.new(
		"Fire Rate",
		"+10% fire rate",
		func(): player.projectile_scene = player.projectile_scene; print("Applied: +10% fire rate")  # Placeholder
	))
	upgrades.append(Upgrade.new(
		"Health",
		"+10% health",
		func(): print("Applied: +10% health")  # Placeholder for now
	))

func check_levelup(current_xp: int, current_level: int) -> bool:
	var xp_required = current_level * 50  # 50 XP per level
	if current_xp >= xp_required:
		_show_upgrade_choice()
		return true
	return false

func _show_upgrade_choice() -> void:
	get_tree().paused = true
	print("\n=== LEVEL UP! ===")
	
	# Randomly select 3 upgrades
	var available: Array[Upgrade] = []
	var indices = range(upgrades.size())
	indices.shuffle()
	for i in range(mini(3, upgrades.size())):
		available.append(upgrades[indices[i]])
	
	for idx in range(available.size()):
		print("[", idx + 1, "] ", available[idx].name, " - ", available[idx].description)
	
	# Auto-select first option after a delay (for testing)
	await get_tree().create_timer(2.0).timeout
	_apply_upgrade(available[0])

func _apply_upgrade(upgrade: Upgrade) -> void:
	print("Chose upgrade: ", upgrade.name)
	upgrade.apply_func.call()
	get_tree().paused = false
	print("=== RESUMING ===\n")
