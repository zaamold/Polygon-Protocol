extends Node

const CONFIG_PATH := "user://display_settings.cfg"
const RESOLUTION_PRESETS := [
	Vector2i(640, 360),
	Vector2i(960, 540),
	Vector2i(1152, 648),
	Vector2i(1440, 810),
	Vector2i(1920, 1080),
]

enum DisplayMode {
	WINDOWED,
	BORDERLESS_FULLSCREEN,
}

var current_mode: DisplayMode = DisplayMode.WINDOWED
var current_resolution: Vector2i = Vector2i(1152, 648)
var config := ConfigFile.new()

func _ready() -> void:
	load_settings()
	apply_settings()

func load_settings() -> void:
	if config.load(CONFIG_PATH) == OK:
		current_mode = config.get_value("display", "mode", DisplayMode.WINDOWED)
		var res_str = config.get_value("display", "resolution", "1152x648")
		var parts = res_str.split("x")
		if parts.size() == 2:
			current_resolution = Vector2i(int(parts[0]), int(parts[1]))
	else:
		# Defaults already set above
		pass

func save_settings() -> void:
	config.set_value("display", "mode", current_mode)
	config.set_value("display", "resolution", "%dx%d" % [current_resolution.x, current_resolution.y])
	config.save(CONFIG_PATH)

func apply_settings() -> void:
	print("[DisplaySettings] Applying settings - mode: %s, resolution: %s" % [current_mode, current_resolution])

	# Check if we can actually resize (not in editor play mode)
	var can_resize = not Engine.is_editor_hint()

	match current_mode:
		DisplayMode.WINDOWED:
			print("[DisplaySettings] Setting MODE_WINDOWED")
			get_window().mode = Window.MODE_WINDOWED
			print("[DisplaySettings] Window mode set to: ", get_window().mode)

			if can_resize:
				print("[DisplaySettings] Setting size to: ", current_resolution)
				get_window().size = current_resolution
				print("[DisplaySettings] Window size is now: ", get_window().size)
			else:
				print("[DisplaySettings] In editor mode - window size cannot be changed (will apply when running standalone)")

		DisplayMode.BORDERLESS_FULLSCREEN:
			print("[DisplaySettings] Setting MODE_FULLSCREEN")
			get_window().mode = Window.MODE_FULLSCREEN
			print("[DisplaySettings] Window mode set to: ", get_window().mode)
			# Fullscreen uses native resolution automatically

func set_display_mode(mode: DisplayMode) -> void:
	current_mode = mode
	apply_settings()
	save_settings()

func set_resolution(resolution: Vector2i) -> void:
	if resolution in RESOLUTION_PRESETS:
		current_resolution = resolution
		if current_mode == DisplayMode.WINDOWED:
			apply_settings()
		save_settings()

func get_resolution_presets() -> Array[Vector2i]:
	return RESOLUTION_PRESETS.duplicate()

func get_current_mode_name() -> String:
	match current_mode:
		DisplayMode.WINDOWED:
			return "Windowed"
		DisplayMode.BORDERLESS_FULLSCREEN:
			return "Borderless Fullscreen"
	return "Unknown"

func get_current_resolution_name() -> String:
	return "%dx%d" % [current_resolution.x, current_resolution.y]
