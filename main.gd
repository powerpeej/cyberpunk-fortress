extends Node2D

# --- Game Configuration ---
const TILE_SIZE = 16
const MAP_WIDTH = 70
const MAP_HEIGHT = 40
var RND = RandomNumberGenerator.new()

# --- Tile Data ---
const TILE_DATA = {
	"BUILDING_WALL":    { "id": 0, "color": Color("2c0f38") }, # Dark Purple
	"BUILDING_FLOOR":   { "id": 1, "color": Color("4f2a69") }, # Muted Purple
	"STREET":           { "id": 2, "color": Color("1a1a3a") }, # Midnight Blue
	"ENTITY":           { "id": 3, "color": Color("ff00ff") }, # Magenta/Hot Pink
	"DESIGNATION_DIG":  { "id": 4, "color": Color("ffff00") }, # Bright Yellow
}

# --- Map Data ---
enum TileType { BUILDING_WALL, BUILDING_FLOOR, STREET }
var map_data = []
var entities = []
var dig_designations = []

# --- Scene Node References ---
@onready var ground_tile_map: TileMap = $GroundTileMap
@onready var entities_tile_map: TileMap = $EntitiesTileMap
@onready var designations_tile_map: TileMap = $DesignationsTileMap


func _ready():
	"""
	Called when the node enters the scene tree. Main entry point.
	"""
	RND.randomize()
	generate_world()


func generate_world():
	"""
	Generates and displays the entire world using the TileMap nodes.
	"""
	var tileset = _create_tileset_from_code()
	ground_tile_map.tile_set = tileset
	entities_tile_map.tile_set = tileset
	designations_tile_map.tile_set = tileset
	
	_generate_city_layout()
	_spawn_initial_entities()
	
	_draw_map_on_tilemap()
	_draw_entities_on_tilemap()
	_draw_designations_on_tilemap()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = ground_tile_map.get_local_mouse_position()
		var map_pos = ground_tile_map.local_to_map(mouse_pos)

		if map_data[map_pos.x][map_pos.y] == TileType.BUILDING_WALL:
			if not map_pos in dig_designations:
				dig_designations.append(map_pos)
				_draw_designations_on_tilemap()


func _create_tileset_from_code() -> TileSet:
	"""
	Creates a TileSet resource programmatically based on the TILE_DATA dictionary.
	"""
	var new_tileset = TileSet.new()
	var tile_count = TILE_DATA.size()
	
	var img = Image.create(TILE_SIZE * tile_count, TILE_SIZE, false, Image.FORMAT_RGBA8)
	
	var tile_keys = TILE_DATA.keys()
	# Sort keys by ID to ensure consistent order
	tile_keys.sort_custom(func(a, b): return TILE_DATA[a].id < TILE_DATA[b].id)

	for key in tile_keys:
		var data = TILE_DATA[key]
		var x_pos = data.id * TILE_SIZE
		img.fill_rect(Rect2i(x_pos, 0, TILE_SIZE, TILE_SIZE), data.color)

	var texture = ImageTexture.create_from_image(img)
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)

	for key in tile_keys:
		var data = TILE_DATA[key]
		var atlas_coords = Vector2i(data.id, 0)
		atlas_source.create_tile(atlas_coords)

	var _source_id = new_tileset.add_source(atlas_source)
	return new_tileset


func _generate_city_layout():
	"""
	Generates a procedural city grid with buildings and streets.
	"""
	# 1. Initialize map data structure
	map_data.resize(MAP_WIDTH)
	for x in range(MAP_WIDTH):
		map_data[x] = []
		map_data[x].resize(MAP_HEIGHT)

	# 2. Start with a base of solid ground/buildings
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			map_data[x][y] = TileType.BUILDING_FLOOR

	# 3. Carve out main streets
	var h_street_count = RND.randi_range(2, 4)
	for i in range(h_street_count):
		var y = RND.randi_range(5, MAP_HEIGHT - 5)
		for x in range(MAP_WIDTH):
			map_data[x][y] = TileType.STREET
			
	var v_street_count = RND.randi_range(3, 5)
	for i in range(v_street_count):
		var x = RND.randi_range(5, MAP_WIDTH - 5)
		for y in range(MAP_HEIGHT):
			map_data[x][y] = TileType.STREET

	# 4. Place buildings
	var building_attempts = 100
	for i in range(building_attempts):
		var b_w = RND.randi_range(4, 10)
		var b_h = RND.randi_range(4, 10)
		var b_x = RND.randi_range(1, MAP_WIDTH - b_w - 1)
		var b_y = RND.randi_range(1, MAP_HEIGHT - b_h - 1)

		# Check if the area is clear of main streets before placing
		var can_place = true
		for x in range(b_x, b_x + b_w):
			for y in range(b_y, b_y + b_h):
				if map_data[x][y] == TileType.STREET:
					can_place = false
					break
			if not can_place:
				break
		
		if can_place:
			for x in range(b_x, b_x + b_w):
				for y in range(b_y, b_y + b_h):
					if x == b_x or x == b_x + b_w - 1 or y == b_y or y == b_y + b_h - 1:
						map_data[x][y] = TileType.BUILDING_WALL
					else:
						map_data[x][y] = TileType.BUILDING_FLOOR


func _spawn_initial_entities():
	"""
	Spawns a few entities on valid street tiles.
	"""
	var spawn_attempts = 0
	while entities.size() < 5 and spawn_attempts < 100:
		var x = RND.randi_range(0, MAP_WIDTH - 1)
		var y = RND.randi_range(0, MAP_HEIGHT - 1)
		
		if map_data[x][y] == TileType.STREET:
			var pos = Vector2(x, y)
			if not pos in entities: # Avoid stacking entities
				entities.append(pos)
		spawn_attempts += 1


func _draw_map_on_tilemap():
	"""
	Renders the city map onto the GroundTileMap.
	"""
	ground_tile_map.clear()
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			var cell_pos = Vector2i(x, y)
			var atlas_coords: Vector2i
			
			match map_data[x][y]:
				TileType.BUILDING_WALL:
					atlas_coords = Vector2i(TILE_DATA.BUILDING_WALL.id, 0)
				TileType.BUILDING_FLOOR:
					atlas_coords = Vector2i(TILE_DATA.BUILDING_FLOOR.id, 0)
				TileType.STREET:
					atlas_coords = Vector2i(TILE_DATA.STREET.id, 0)
			
			ground_tile_map.set_cell(0, cell_pos, 0, atlas_coords)


func _draw_entities_on_tilemap():
	"""
	Renders the entities onto the EntitiesTileMap.
	"""
	entities_tile_map.clear()
	var entity_atlas_coords = Vector2i(TILE_DATA.ENTITY.id, 0)
	
	for entity_pos in entities:
		entities_tile_map.set_cell(0, Vector2i(entity_pos), 0, entity_atlas_coords)


func _draw_designations_on_tilemap():
	"""
	Renders the designations onto the DesignationsTileMap.
	"""
	designations_tile_map.clear()
	var designation_atlas_coords = Vector2i(TILE_DATA.DESIGNATION_DIG.id, 0)

	for des_pos in dig_designations:
		designations_tile_map.set_cell(0, des_pos, 0, designation_atlas_coords)