class_name GameSave extends Object
const DEFAULT_FILENAME:String = "game_save.json"
func _build():
	return {
		"current_level": GameState.current_level_key,
		"position_x": GameState.player.position.x,
		"position_y": GameState.player.position.y,
		"position_z": GameState.player.position.z,
		"rotation_x": GameState.player.rotation.x,
		"rotation_y": GameState.player.rotation.y,
		"rotation_z": GameState.player.rotation.z,
		"has_castle_key": GameState.has_castle_key,
		"has_castle_key_2": GameState.has_castle_key_2,
		"has_graveyard_key": GameState.has_graveyard_key,
		"has_graveyard_key_2": GameState.has_graveyard_key_2,
		"collected_items": GameState.collected_items,
		"bottle_count": GameState.bottle_count,
		"food_count": GameState.food_count,
		"has_big_sword": GameState.has_big_sword,
		"has_big_shield": GameState.has_big_shield,
		"killed_ids": GameState.killed_ids
	}

func save_game():
	var save = FileAccess.open(DEFAULT_FILENAME, FileAccess.WRITE)
	if(save != null):
		save.store_line(JSON.stringify(_build()))

func load_game(reset_game:bool = false):
	if reset_game:
		if FileAccess.file_exists(DEFAULT_FILENAME):
			var dir = DirAccess.open("res://")
			dir.remove(DEFAULT_FILENAME)
		GameState.reset_game()
		return
	
	var save = FileAccess.open(DEFAULT_FILENAME, FileAccess.READ)
	if(save != null):
		var json:JSON = JSON.new()
		var parse_result = json.parse(save.get_line())
		if not (parse_result == OK):
			return
		var data:Dictionary = json.get_data()
		GameState.current_level_key = data.get("current_level", GameState.current_level_key)
		GameState.player.position = Vector3(data.get("position_x", GameState.player.position.x), data.get("position_y", GameState.player.position.y), data.get("position_z", GameState.player.position.z))
		GameState.player.rotation = Vector3(data.get("rotation_x", GameState.player.rotation.x), data.get("rotation_y", GameState.player.rotation.y), data.get("rotation_z", GameState.player.rotation.z))
		GameState.has_castle_key = data.get("has_castle_key", false)
		GameState.has_castle_key_2 = data.get("has_castle_key_2", false)
		GameState.has_graveyard_key = data.get("has_graveyard_key", false)
		GameState.has_graveyard_key_2 = data.get("has_graveyard_key_2", false)
		GameState.collected_items = data.get("collected_items", [])
		GameState.bottle_count = data.get("bottle_count", 0)
		GameState.food_count = data.get("food_count", 0)
		GameState.has_big_sword = data.get("has_big_sword", false)
		GameState.has_big_shield = data.get("has_big_shield", false)
		GameState.killed_ids = data.get("killed_ids", [])
		
