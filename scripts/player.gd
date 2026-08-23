extends CharacterBody2D

@export var speed: float = 300.0
@export var arena_width: float = 1024.0
@export var arena_height: float = 600.0

var projectile_scene = preload("res://scenes/projectile.tscn")
var frame_count := 0

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_vector * speed
	
	position += velocity * delta
	
	position.x = clamp(position.x, 0, arena_width)
	position.y = clamp(position.y, 0, arena_height)
	
	frame_count += 1
	if frame_count % 60 == 0:
		print("Player position: ", position, " | Input: ", input_vector)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var direction = (mouse_pos - global_position).normalized()
		fire_projectile_in_direction(direction)

func fire_projectile_in_direction(direction: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	get_parent().add_child(projectile)
	
	print("Fired projectile in direction: ", direction)
