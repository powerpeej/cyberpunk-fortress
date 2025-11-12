extends Camera2D

# --- Camera Settings ---
const PAN_SPEED = 250.0
const MIN_ZOOM = 0.5
const MAX_ZOOM = 3.0
const ZOOM_SPEED = 0.1

func _process(delta):
	"""
	Handle camera movement and zoom based on player input.
	"""
	# --- Panning ---
	var move_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		move_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		move_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		move_direction.y -= 1

	position += move_direction.normalized() * PAN_SPEED * delta

	# --- Zooming ---
	if Input.is_action_just_pressed("ui_zoom_in"):
		zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)
	if Input.is_action_just_pressed("ui_zoom_out"):
		zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)

	zoom = zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
