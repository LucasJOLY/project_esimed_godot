extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	GameState.player = $Player;
	_enter_level("default", "level_1");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _enter_level(from_level: String, to_level: String, use_spawn_point: bool = true) -> void:
	if(GameState.current_level != null): GameState.current_level.queue_free()
	GameState.current_level = load("res://levels/" + to_level + ".tscn").instantiate();
	GameState.current_level_key = to_level
	add_child(GameState.current_level)
	if(use_spawn_point):
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if(spawnpoint.key == from_level):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation
	
