extends Node

var xp: int = 0
var level: int = 1

func _ready() -> void:
	print("Run started - XP: 0, Level: 1")

func add_xp(amount: int) -> void:
	xp += amount
	print("XP gained: +", amount, " | Total XP: ", xp)
