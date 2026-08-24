extends CharacterBody2D

@export var speed: float = 300.0
@export var arena_width: float = 1024.0
@export var arena_height: float = 600.0
@export var max_health: float = 100.0
@export var damage_per_hit: float = 10.0
@export var invincibility_duration: float = 0.5

var projectile_scene = preload("res://scenes/projectile.tscn")
var frame_count := 0

var fire_cooldown := 0.0
var fire_rate := 5.0
var shots_fired := 0
var health: float
var pickup_count: int = 0
var invincibility_timer := 0.0
var is_invincible := false
var overlapping_enemies: Array = []

func _ready() -> void:
	health = max_health

	# Create enemy collision detector if it doesn't exist
	if not has_node("EnemyCollider"):
		var enemy_collider = Area2D.new()
		enemy_collider.name = "EnemyCollider"
		add_child(enemy_collider)

		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 20.0
		collision_shape.shape = circle_shape
		enemy_collider.add_child(collision_shape)

		enemy_collider.area_entered.connect(_on_enemy_area_entered)
		enemy_collider.area_exited.connect(_on_enemy_area_exited)

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vector * speed

	position += velocity * delta

	position.x = clamp(position.x, 0, arena_width)
	position.y = clamp(position.y, 0, arena_height)

	# Update fire cooldown
	fire_cooldown = max(0.0, fire_cooldown - delta)

	# Update invincibility frames
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			$Visual.modulate.a = 1.0
		else:
			# Flicker effect during invincibility
			var flicker = fmod(invincibility_timer * 10, 1.0) > 0.5
			$Visual.modulate.a = 0.5 if flicker else 1.0

	# Check for continuous damage from overlapping enemies
	for enemy in overlapping_enemies:
		if is_instance_valid(enemy) and enemy.damage_cooldown <= 0.0:
			take_damage(damage_per_hit)
			enemy.damage_cooldown = enemy.damage_interval

	# Hold-to-fire: check if fire button is held and cooldown is ready
	if Input.is_action_pressed("fire_weapon") and fire_cooldown <= 0.0:
		var direction = get_aim_direction()
		fire_projectile_in_direction(direction)
		fire_cooldown = 1.0 / fire_rate
		shots_fired += 1

	frame_count += 1
	if frame_count % 60 == 0:
		var aim = get_aim_direction()
		print("Player position: ", position, " | Input: ", input_vector, " | Aim: ", aim, " (length: ", aim.length(), ") | Fire rate: ", fire_rate, " shots/sec")
		# Auto-fire for testing
		fire_projectile_in_direction(aim)

func get_aim_direction() -> Vector2:
	var stick_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")

	if stick_dir.length() > 0.1:
		return stick_dir

	var mouse_pos = get_global_mouse_position()
	var mouse_dir = (mouse_pos - global_position).normalized()
	return mouse_dir if mouse_dir.length() > 0 else Vector2.RIGHT

func fire_projectile_in_direction(direction: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	get_parent().add_child(projectile)

	print("Fired projectile in direction: ", direction)

func _on_enemy_area_entered(area: Area2D) -> void:
	# Check if the area is from an enemy
	var parent = area.get_parent()
	while parent:
		if parent.is_in_group("enemy"):
			if not overlapping_enemies.has(parent):
				overlapping_enemies.append(parent)
			return
		parent = parent.get_parent()

func _on_enemy_area_exited(area: Area2D) -> void:
	# Remove enemy from overlapping list
	var parent = area.get_parent()
	while parent:
		if parent.is_in_group("enemy"):
			overlapping_enemies.erase(parent)
			return
		parent = parent.get_parent()

func take_damage(damage: float) -> void:
	if is_invincible:
		return

	health -= damage
	health = max(0.0, health)
	is_invincible = true
	invincibility_timer = invincibility_duration

	print("Player hit! Health: %.1f/%.1f (invincible for %.2fs)" % [health, max_health, invincibility_duration])

	if health <= 0:
		print("PLAYER DIED")
		var game_over = get_parent().get_node("GameOver")
		if game_over:
			game_over.show_game_over()
