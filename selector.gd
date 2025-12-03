extends Node2D

signal tile_selected(grid_pos)

const TILE_SIZE = 16 # Keeping in sync with main.gd. Ideally this should be shared.
const SELECTOR_COLOR = Color(1.0, 1.0, 0.0, 0.5) # Semi-transparent yellow

func _process(_delta):
	var mouse_pos = get_global_mouse_position()

	# Snap to grid
	var grid_x = floor(mouse_pos.x / TILE_SIZE) * TILE_SIZE
	var grid_y = floor(mouse_pos.y / TILE_SIZE) * TILE_SIZE

	position = Vector2(grid_x, grid_y)
	queue_redraw()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("tile_selected", position)

func _draw():
	# Draw a rectangle outline
	draw_rect(Rect2(0, 0, TILE_SIZE, TILE_SIZE), SELECTOR_COLOR, false, 2.0)
