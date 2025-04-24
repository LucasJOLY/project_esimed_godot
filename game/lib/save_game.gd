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
	}

func save_game():
	var save = FileAccess.open(DEFAULT_FILENAME, FileAccess.WRITE)
	if(save != null):
		save.store_line(JSON.stringify(_build()))

func load_game():
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
