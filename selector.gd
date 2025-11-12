extends Polygon2D

@onready var tile_map = get_parent().get_node("GroundTileMap")

func _process(delta):
	var mouse_pos = tile_map.get_local_mouse_position()
	var map_pos = tile_map.local_to_map(mouse_pos)

	if tile_map.get_cell_source_id(0, map_pos) != -1:
		visible = true
		position = tile_map.map_to_local(map_pos)
	else:
		visible = false
