extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 5.0
@export var arena_width: float = 1024.0
@export var arena_height: float = 600.0

var direction: Vector2 = Vector2.RIGHT
var elapsed: float = 0.0
var has_hit: bool = false
var _queued_for_deletion: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	print("Projectile spawned at ", position, " direction: ", direction)

func _physics_process(delta: float) -> void:
	if _queued_for_deletion:
		return

	position += direction * speed * delta
	elapsed += delta

	# Destroy if out of bounds (defensive measure)
	if position.x < -50 or position.x > arena_width + 50 or position.y < -50 or position.y > arena_height + 50:
		_queued_for_deletion = true
		print("Projectile destroyed (out of bounds) at ", position)
		queue_free()
		return

	if elapsed > lifetime:
		_queued_for_deletion = true
		print("Projectile destroyed (lifetime expired)")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Prevent multiple hits (defensive measure)
	if has_hit:
		return

	# Check if we hit an enemy by verifying parent has die() method
	var enemy = area.get_parent()
	if not enemy or not enemy.has_method("die"):
		return

	# Hit confirmed - kill the enemy and destroy the projectile
	has_hit = true
	_queued_for_deletion = true
	print("Projectile hit enemy: ", enemy.name, " at ", enemy.position)
	enemy.die()
	queue_free()
