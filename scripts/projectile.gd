extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.RIGHT
var elapsed: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	print("Projectile spawned at ", position, " direction: ", direction)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	elapsed += delta
	
	if elapsed > lifetime:
		queue_free()
		print("Projectile destroyed (lifetime expired)")

func _on_area_entered(area: Area2D) -> void:
	# Check if we hit an enemy
	var enemy = area.get_parent()
	if enemy and (enemy.name.begins_with("Enemy") or enemy.name.begins_with("FastEnemy")):
		if enemy.has_method("die"):
			print("Projectile hit enemy: ", enemy.name, " at ", enemy.position)
			enemy.die()
			queue_free()
