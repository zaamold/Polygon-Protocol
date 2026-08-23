extends CharacterBody2D

@export var speed: float = 150.0

var player: CharacterBody2D

func _ready() -> void:
	player = get_parent().get_node("Player")
	if player:
		print("Enemy spawned at ", position, " targeting player at ", player.position)
	else:
		print("ERROR: Enemy could not find Player node")

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	position += velocity * delta
	
	# Clamp to arena bounds
	position.x = clamp(position.x, 0, 1024)
	position.y = clamp(position.y, 0, 600)
