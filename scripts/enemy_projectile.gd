extends Area2D

@export var speed: float = 150.0
@export var lifetime: float = 8.0
@export var arena_width: float = 1024.0
@export var arena_height: float = 600.0

var direction: Vector2 = Vector2.RIGHT
var elapsed: float = 0.0
var _queued_for_deletion: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_update_rotation()
	print("Enemy projectile spawned at ", position, " direction: ", direction)

func _update_rotation() -> void:
	var visual = $Visual
	if visual:
		rotation = direction.angle()

func _physics_process(delta: float) -> void:
	if _queued_for_deletion:
		return

	position += direction * speed * delta
	elapsed += delta

	# Destroy if out of bounds
	if position.x < -50 or position.x > arena_width + 50 or position.y < -50 or position.y > arena_height + 50:
		_queued_for_deletion = true
		print("Enemy projectile destroyed (out of bounds) at ", position)
		queue_free()
		return

	if elapsed > lifetime:
		_queued_for_deletion = true
		print("Enemy projectile destroyed (lifetime expired)")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Check if we hit the player
	var parent = area.get_parent()
	if parent and parent.name == "Player" and parent.has_method("take_damage"):
		print("Enemy projectile hit player at ", position)
		# Deal damage but DO NOT delete the projectile - it passes through
		parent.take_damage(10.0)
		# Just let it continue until out of bounds
