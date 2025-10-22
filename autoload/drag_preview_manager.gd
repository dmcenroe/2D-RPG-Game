# DragPreview.gd (Autoload)
extends CanvasLayer

var preview: TextureRect = null

func _ready():
	layer = 10000  # Ensure it's always on top

func show_preview(texture: Texture2D, size: Vector2 = Vector2(64, 64)) -> void:
	if preview:
		preview.queue_free()
	
	preview = TextureRect.new()
	preview.texture = texture
	preview.custom_minimum_size = size
	preview.size = size
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(preview)
	preview.show()

func hide_preview() -> void:
	if preview:
		preview.queue_free()
		preview = null

func is_showing() -> bool:
	return preview != null

func _process(_delta: float) -> void:
	if preview:
		preview.global_position = get_viewport().get_mouse_position() - preview.size / 2
