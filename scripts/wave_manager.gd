extends Node

@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@export var enemy_fast_scene: PackedScene = preload("res://scenes/enemy_fast.tscn")
@export var enemy_ranged_scene: PackedScene = preload("res://scenes/enemy_ranged.tscn")
@export var spawn_delay: float = 0.8
@export var wave_delay: float = 3.0

var wave_number: int = 0
var enemies_spawned_this_wave: int = 0
var enemies_target_this_wave: int = 0
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var is_wave_active: bool = false
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent().get_node("Player")
	start_next_wave()

func _physics_process(delta: float) -> void:
	wave_timer += delta
	spawn_timer += delta
	
	# Check if wave is complete
	if is_wave_active and enemies_spawned_this_wave >= enemies_target_this_wave and wave_timer > wave_delay:
		if get_enemy_count() == 0:
			start_next_wave()
	
	# Spawn enemies during active wave
	if is_wave_active and enemies_spawned_this_wave < enemies_target_this_wave and spawn_timer >= spawn_delay:
		spawn_enemy()
		spawn_timer = 0.0

func start_next_wave() -> void:
	wave_number += 1
	enemies_spawned_this_wave = 0
	enemies_target_this_wave = 2 + wave_number  # 3 enemies in wave 1, 4 in wave 2, etc
	wave_timer = 0.0
	is_wave_active = true
	print("Wave ", wave_number, " started - target enemies: ", enemies_target_this_wave)

func spawn_enemy() -> void:
	# Pick random edge to spawn from
	var edge = randi() % 4  # 0=top, 1=right, 2=bottom, 3=left
	var spawn_pos: Vector2
	var offset = 50
	
	match edge:
		0:  # top
			spawn_pos = Vector2(randf_range(0, ArenaConfig.width), -offset)
		1:  # right
			spawn_pos = Vector2(ArenaConfig.width + offset, randf_range(0, ArenaConfig.height))
		2:  # bottom
			spawn_pos = Vector2(randf_range(0, ArenaConfig.width), ArenaConfig.height + offset)
		3:  # left
			spawn_pos = Vector2(-offset, randf_range(0, ArenaConfig.height))
	
	# Randomly choose enemy type (33% each)
	var enemy_type = randi() % 3
	var scene: PackedScene
	match enemy_type:
		0:
			scene = enemy_fast_scene
		1:
			scene = enemy_scene
		2:
			scene = enemy_ranged_scene

	var enemy = scene.instantiate()
	enemy.global_position = spawn_pos
	enemy.player = player
	get_parent().add_child(enemy)
	
	enemies_spawned_this_wave += 1
	print("Enemy spawned at ", spawn_pos, " (", enemies_spawned_this_wave, "/", enemies_target_this_wave, ")")

func get_enemy_count() -> int:
	var count = 0
	for child in get_parent().get_children():
		if child.is_in_group("enemy"):
			count += 1
	return count
