extends CharacterBody2D

@export var speed: float = 250.0  # Faster than base enemy (150)
@export var lifetime: float = 15.0

var player: CharacterBody2D
var elapsed: float = 0.0
var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")

func _ready() -> void:
	add_to_group("enemy")
	player = get_parent().get_node("Player")
	if player:
		print("FastEnemy spawned at ", position, " (speed: ", speed, ")")
	else:
		print("ERROR: FastEnemy could not find Player node")

func _physics_process(delta: float) -> void:
	elapsed += delta
	
	# Self-destruct after lifetime (for testing/wave progression)
	if elapsed > lifetime:
		die()
		return
	
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	position += velocity * delta
	
	# Clamp to arena bounds
	position.x = clamp(position.x, 0, 1024)
	position.y = clamp(position.y, 0, 600)

func die() -> void:
	print("FastEnemy died at ", position)
	drop_pickup()
	queue_free()

func drop_pickup() -> void:
	var pickup = pickup_scene.instantiate()
	pickup.global_position = global_position
	get_parent().call_deferred("add_child", pickup)
	print("FastEnemy dropped pickup at ", pickup.global_position)
