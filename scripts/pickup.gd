extends Area2D

@export var xp_value: int = 10

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	print("Pickup spawned at ", position, " worth ", xp_value, " XP")

func _on_area_entered(area: Area2D) -> void:
	# Check if player collected this pickup
	if area.get_parent().name == "Player":
		var run_manager = get_parent().get_node("RunManager")
		if run_manager:
			run_manager.add_xp(xp_value)
		print("Player collected pickup: +", xp_value, " XP")
		queue_free()
