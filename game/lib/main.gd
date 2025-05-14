extends Node3D


var save_game:GameSave = GameSave.new()

const DEFAULT_FILENAME:String = "game_save.json"


var current_level_change = null

@onready var label_infos:Label = $HUD/TextInfo/LabelInfosText
@onready var text_info:TextureRect = $HUD/TextInfo
@onready var disussion_box:TextureRect = $HUD/Discussion
@onready var disussion_text:Label = $HUD/Discussion/DiscussionContent
@onready var disussion_next_text:Label = $HUD/Discussion/NextInfo/NextText
@onready var disussion_quit_text:Label = $HUD/Discussion/Quit/Quit
@onready var disussion_name:Label = $HUD/Discussion/DiscussionName/Label

@onready var count_drink:Label = $HUD/DrinkControl/Info/Text
@onready var count_food:Label = $HUD/FoodControl/Info/Text


@onready var menu:Control = $Menu

@onready var hud:Control = $HUD

@onready var death_screen:Control = $DeathScreen
@onready var death_screen_new_game_button:Button = $DeathScreen/TextureRect4/ButtonNewGame/Button
@onready var death_screen_quit_button:Button = $DeathScreen/TextureRect4/ButtonQuitImage/ButtonQuit

@onready var start_screen:Control = $StartScreen
@onready var start_screen_new_game_button:Button = $StartScreen/TextureRect4/ButtonNewGame/Button
@onready var start_screen_load_game:TextureRect = $StartScreen/TextureRect4/ButtonReplayGame
@onready var start_screen_load_game_button:Button = $StartScreen/TextureRect4/ButtonReplayGame/Button
@onready var start_screen_quit_button:Button = $StartScreen/TextureRect4/ButtonQuitImage/ButtonQuit


@onready var player:Player = $Player


@onready var level_hud:Label = $HUD/LevelInfo/Text

@onready var exp_bar:ProgressBar = $HUD/ExpBar


@onready var health_container:Control = $HUD/HealthControl




var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# capture la souris
	player.release_mouse()
	SimpleGrass.set_interactive(true)
	disussion_box.visible = false
	menu.visible = false
	hud.visible = false
	handle_hud()
	text_info.visible = false
	death_screen.visible = false
	start_screen.visible = true
	GameState.player = $Player
	
	# Vérifie si une sauvegarde existe
	var save_file = FileAccess.open(DEFAULT_FILENAME, FileAccess.READ)
	if save_file:
		start_screen_load_game.visible = true
		save_file.close()
	else:
		start_screen_load_game.visible = false
	
	
	save_game.load_game()
	_enter_level("default", GameState.current_level_key, GameState.player.position == Vector3.ZERO)

	level_hud.text = str(GameState.level)
	exp_bar.value = GameState.experience
	_update_health_display()

func _update_health_display() -> void:
	# Afficher les cœurs en fonction du niveau maximum actuel
	for i in range(1, 11):  # On parcourt tous les cœurs possibles (1 à 10)
		var full_heart = health_container.get_node("Heath_Full" + str(i)) as TextureRect
		var empty_heart = health_container.get_node("Heath_Empty" + str(i)) as TextureRect
		
		if full_heart and empty_heart:
			if i <= GameState.max_hearth:  # Si le cœur est débloqué
				full_heart.visible = i <= GameState.current_hearth
				empty_heart.visible = i > GameState.current_hearth
			else:  # Si le cœur n'est pas encore débloqué
				full_heart.visible = false
				empty_heart.visible = false

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



func level_up() -> void:
	_update_health_display()

func show_text_info(text: String) -> void:
	text_info.visible = true
	label_infos.text = text
	# Créer un timer pour masquer le message après 3 secondes
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func(): text_info.visible = false)

func _on_start_screen_new_game_pressed() -> void:
	_reset_game_state()
	start_screen.visible = false
	hud.visible = true
	player.capture_mouse()

	get_tree().paused = false

func _on_start_screen_load_game_pressed() -> void:
	start_screen.visible = false
	hud.visible = true
	handle_hud()
	player.capture_mouse()
	get_tree().paused = false

func _on_death_screen_new_game_pressed() -> void:
	_reset_game_state()
	death_screen.visible = false
	hud.visible = true
	player.capture_mouse()
	handle_hud()
	get_tree().paused = false

func _reset_game_state() -> void:
	save_game.load_game(true)
	GameState.player._ready()
	
	_enter_level("default", GameState.current_level_key, true)
	level_hud.text = str(GameState.level)
	exp_bar.value = GameState.experience
	_update_health_display()

func _on_start_screen_quit_pressed() -> void:
	get_tree().quit()

func _on_death_screen_quit_pressed() -> void:
	get_tree().quit()

func handle_hud() -> void:
	count_drink.text = str(GameState.bottle_count)
	count_food.text = str(GameState.food_count)
