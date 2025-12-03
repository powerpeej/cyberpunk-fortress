extends Camera2D

# Camera Control Settings
const MOVE_SPEED = 500.0
const ZOOM_SPEED = 0.1
const MIN_ZOOM = 0.5
const MAX_ZOOM = 3.0

func _process(delta):
	_handle_movement(delta)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)

			# Clamp zoom
			zoom.x = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
			zoom.y = clamp(zoom.y, MIN_ZOOM, MAX_ZOOM)

func _handle_movement(delta):
	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D):
		direction.x += 1

	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * MOVE_SPEED * delta
