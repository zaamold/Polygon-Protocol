extends Node2D

# Implements "Hor+" aspect ratio approach:
# - Fixed vertical FOV (always 648 units of game world height)
# - Variable horizontal FOV (scales with display aspect ratio)
# - This ensures fair gameplay (vertical visibility) while using full screen

const BASE_HEIGHT := 648.0  # Fixed vertical FOV in game units

func _ready() -> void:
	update_camera()
	get_window().size_changed.connect(_on_window_resized)

func _on_window_resized() -> void:
	update_camera()

func update_camera() -> void:
	var viewport_size = get_window().size

	# Calculate zoom to show exactly BASE_HEIGHT units vertically
	var zoom_factor = viewport_size.y / BASE_HEIGHT

	# Calculate visible horizontal width based on actual viewport aspect ratio
	var visible_height = BASE_HEIGHT
	var viewport_aspect = float(viewport_size.x) / float(viewport_size.y)
	var visible_width = visible_height * viewport_aspect

	# Store for other systems
	ArenaConfig.width = visible_width
	ArenaConfig.height = visible_height

	# Camera center: show the full width (0 to visible_width) and full height (0 to visible_height)
	# So camera is at (visible_width/2, visible_height/2)
	var world_center = Vector2(visible_width / 2.0, visible_height / 2.0)
	var screen_center = viewport_size / 2.0

	# Canvas transform maps screen space to world space
	# We need: screen_center -> world_center after scaling
	var inv_zoom = 1.0 / zoom_factor
	var canvas_tr = Transform2D(
		Vector2(inv_zoom, 0),  # x-axis (scale.x)
		Vector2(0, inv_zoom),  # y-axis (scale.y)
		world_center - screen_center * inv_zoom  # origin/translation
	)

	get_viewport().canvas_transform = canvas_tr

func get_visible_width() -> float:
	return ArenaConfig.width

func get_visible_height() -> float:
	return ArenaConfig.height
