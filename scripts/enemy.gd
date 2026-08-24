extends CharacterBody2D

@export var speed: float = 150.0
@export var lifetime: float = 15.0
@export var damage_interval: float = 1.0
@export var max_health: float = 20.0

var player: CharacterBody2D
var elapsed: float = 0.0
var damage_cooldown: float = 0.0
var health: float
var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")
var health_bar: ProgressBar

func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	_create_health_bar()
	player = get_parent().get_node("Player")
	if player:
		print("Enemy spawned at ", position, " targeting player at ", player.position)
	else:
		print("ERROR: Enemy could not find Player node")

func _create_health_bar() -> void:
	health_bar = ProgressBar.new()
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.custom_minimum_size = Vector2(30, 4)
	health_bar.modulate = Color.RED
	health_bar.show_percentage = false

	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.RED
	health_bar.add_theme_stylebox_override("fill", style_box)

	var empty_style = StyleBoxFlat.new()
	empty_style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	health_bar.add_theme_stylebox_override("background", empty_style)

	add_child(health_bar)
	health_bar.position = Vector2(-15, -30)

func _physics_process(delta: float) -> void:
	elapsed += delta
	damage_cooldown = max(0.0, damage_cooldown - delta)

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

func take_damage(damage: float) -> void:
	health -= damage
	if health_bar:
		health_bar.value = health
		# Flash effect - set to white briefly
		health_bar.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			health_bar.modulate = Color.RED

	if health <= 0:
		die()

func die() -> void:
	print("Enemy died at ", position)
	var run_manager = get_parent().get_node("RunManager")
	if run_manager:
		run_manager.record_kill()
	drop_pickup()
	queue_free()

func drop_pickup() -> void:
	var pickup = pickup_scene.instantiate()
	pickup.global_position = global_position
	get_parent().call_deferred("add_child", pickup)
	print("Enemy dropped pickup at ", pickup.global_position)
