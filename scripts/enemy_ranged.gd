extends CharacterBody2D

@export var speed: float = 200.0  # Slower than player (300), faster than regular enemy (150)
@export var lifetime: float = 15.0
@export var damage_interval: float = 1.0
@export var preferred_distance: float = 300.0
@export var fire_interval: float = 2.0
@export var max_health: float = 20.0

var player: CharacterBody2D
var elapsed: float = 0.0
var damage_cooldown: float = 0.0
var fire_cooldown: float = 0.0
var health: float
var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")
var enemy_projectile_scene: PackedScene = preload("res://scenes/enemy_projectile.tscn")
var health_bar: ProgressBar

func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	_create_health_bar()
	player = get_parent().get_node("Player")
	if player:
		print("RangedEnemy spawned at ", position, " (speed: ", speed, ", preferred distance: ", preferred_distance, ")")
	else:
		print("ERROR: RangedEnemy could not find Player node")

func _create_health_bar() -> void:
	health_bar = ProgressBar.new()
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.custom_minimum_size = Vector2(30, 4)
	health_bar.modulate = Color.RED
	add_child(health_bar)
	health_bar.position = Vector2(-15, -30)

func _physics_process(delta: float) -> void:
	elapsed += delta
	damage_cooldown = max(0.0, damage_cooldown - delta)
	fire_cooldown = max(0.0, fire_cooldown - delta)

	# Self-destruct after lifetime
	if elapsed > lifetime:
		die()
		return

	if not player:
		return

	var direction_to_player = (player.global_position - global_position).normalized()
	var distance_to_player = global_position.distance_to(player.global_position)

	# Maintain preferred distance
	if distance_to_player < preferred_distance - 50:
		# Too close, move away
		velocity = -direction_to_player * speed
	elif distance_to_player > preferred_distance + 50:
		# Too far, move closer
		velocity = direction_to_player * speed
	else:
		# At preferred distance, stop moving
		velocity = Vector2.ZERO

	position += velocity * delta

	# Clamp to arena bounds
	position.x = clamp(position.x, 0, 1024)
	position.y = clamp(position.y, 0, 600)

	# Fire projectiles at player
	if fire_cooldown <= 0.0:
		fire_at_player()
		fire_cooldown = fire_interval

func fire_at_player() -> void:
	if not player or not is_instance_valid(enemy_projectile_scene):
		return

	var projectile = enemy_projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(projectile)
	print("RangedEnemy fired at player from ", position)

func take_damage(damage: float) -> void:
	health -= damage
	if health_bar:
		health_bar.value = health
		# Flash effect - set to white briefly
		var tween = create_tween()
		health_bar.modulate = Color.WHITE
		await tween.tween_timer(0.1)
		health_bar.modulate = Color.RED

	if health <= 0:
		die()

func die() -> void:
	print("RangedEnemy died at ", position)
	var run_manager = get_parent().get_node("RunManager")
	if run_manager:
		run_manager.record_kill()
	drop_pickup()
	queue_free()

func drop_pickup() -> void:
	var pickup = pickup_scene.instantiate()
	pickup.global_position = global_position
	get_parent().call_deferred("add_child", pickup)
	print("RangedEnemy dropped pickup at ", pickup.global_position)
