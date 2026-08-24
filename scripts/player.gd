extends CharacterBody2D

@export var speed: float = 300.0
@export var arena_width: float = 1024.0
@export var arena_height: float = 600.0
@export var max_health: float = 100.0

var projectile_scene = preload("res://scenes/projectile.tscn")
var frame_count := 0

var fire_cooldown := 0.0
var fire_rate := 5.0
var shots_fired := 0
var health: float
var pickup_count: int = 0

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vector * speed

	position += velocity * delta

	position.x = clamp(position.x, 0, arena_width)
	position.y = clamp(position.y, 0, arena_height)

	# Update fire cooldown
	fire_cooldown = max(0.0, fire_cooldown - delta)

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
