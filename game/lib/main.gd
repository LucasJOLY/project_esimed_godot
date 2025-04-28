extends Node3D


var save_game:GameSave = GameSave.new()


var current_level_change = null

@onready var label_infos:Label = $HUD/TextInfo/LabelInfosText
@onready var text_info:TextureRect = $HUD/TextInfo
@onready var disussion_box:TextureRect = $HUD/Discussion
@onready var disussion_text:Label = $HUD/Discussion/DiscussionContent
@onready var disussion_next_text:Label = $HUD/Discussion/NextInfo/NextText
@onready var disussion_quit_text:Label = $HUD/Discussion/Quit/Quit
@onready var disussion_name:Label = $HUD/Discussion/DiscussionName/Label


@onready var menu:Control = $Menu
@onready var player:Player = $Player

var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SimpleGrass.set_interactive(true)
	disussion_box.visible = false
	menu.visible = false
	text_info.visible = false
	GameState.player = $Player;
	save_game.load_game()
	_enter_level("default", GameState.current_level_key, GameState.player.position == Vector3.ZERO)



func _unhandled_input(event: InputEvent) -> void:
	if(not get_tree().paused):
		if(event.is_action_pressed("player_interract") and current_level_change != null):
			_enter_level(GameState.current_level_key, current_level_change.destination_level)
			current_level_change = null

	if event is InputEventKey and Input.is_action_just_pressed("cancel"):
		if menu.visible:
			_unpause_game()
		else:
			_pause_game()


func _enter_level(from_level: String, to_level: String, use_spawn_point: bool = true) -> void:	
	if(GameState.current_level != null): GameState.current_level.queue_free()
	GameState.current_level = load("res://levels/" + to_level + ".tscn").instantiate();
	GameState.current_level_key = to_level
	add_child(GameState.current_level)
	GameState.current_level.process_mode = PROCESS_MODE_PAUSABLE
	if(use_spawn_point):
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if(spawnpoint.key == from_level):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation
	


func _on_button_quit_pressed() -> void:
	save_game.save_game()
	get_tree().quit()
	pass # Replace with function body.




func _on_player_interaction_detected(node: Node3D) -> void:
	if(node.get_parent() is LevelChange):
		text_info.visible = true
		label_infos.text = "Appuyez sur E pour ouvrir la porte"
		current_level_change = node.get_parent()


func _on_player_interaction_released(node: Node3D) -> void:
	text_info.visible = false
	current_level_change = null



func _pause_game() -> void:
	player.release_mouse()
	get_tree().paused = true

	menu.visible = true
	

func _unpause_game() -> void:
	menu.visible = false
	player.capture_mouse()
	get_tree().paused = false
func _on_button_unpause_pressed() -> void:
	_unpause_game()
	pass # Replace with function body.
