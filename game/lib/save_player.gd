class_name SaveGame extends Object
const DEFAULT_FILENAME:String = "game_save.json"
func _build():


	return {
		"current_level": GameState.current_level,
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
