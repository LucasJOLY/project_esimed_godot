extends Node3D

@export var item_name: String = "Objet"
@export var item_id: String = "item_1"
@export var item_type: String = "bottle" # "bottle" ou "food"
@export var interaction_text: String = "Appuyez sur E pour ramasser"
@export var obtained_text: String = "Nouvel Objet : "

@onready var main_scene: Node3D = get_tree().root.get_node("Main")
@onready var message_timer: Timer = Timer.new()

var player:Player = GameState.player
var player_in_range = false

func _ready():
	if item_id in GameState.collected_items:
		queue_free()
		return
	player.interaction_detected.connect(_on_player_interaction_detected)
	player.interaction_released.connect(_on_player_interaction_released)
	
	# Configuration du timer
	message_timer.wait_time = 5.0
	message_timer.one_shot = true
	message_timer.timeout.connect(_on_timer_timeout)
	add_child(message_timer)

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("player_interract"):
		collect_item()

func _on_timer_timeout():
	main_scene.text_info.visible = false

func collect_item():
	if item_type == "bottle" and GameState.bottle_count < Consts.MAX_BOTTLE_COUNT:
		GameState.bottle_count += 1
		GameState.collected_items.append(item_id)   
		main_scene.label_infos.text = obtained_text + item_name
		main_scene.text_info.visible = true
		message_timer.start()
		queue_free()
	elif item_type == "bottle" and GameState.bottle_count >= Consts.MAX_BOTTLE_COUNT:
		main_scene.label_infos.text = "Vous ne pouvez plus ramasser de bouteilles"
		main_scene.text_info.visible = true
		message_timer.start()
	elif item_type == "food" and GameState.food_count < Consts.MAX_FOOD_COUNT:
		GameState.food_count += 1
		GameState.collected_items.append(item_id)
		main_scene.label_infos.text = obtained_text + item_name
		main_scene.text_info.visible = true
		message_timer.start()
		queue_free()
	elif item_type == "food" and GameState.food_count >= Consts.MAX_FOOD_COUNT:
		main_scene.label_infos.text = "Vous ne pouvez plus ramasser de nourriture"
		main_scene.text_info.visible = true
		message_timer.start()

func _on_player_interaction_detected(node: Node3D) -> void:
	if node == self:
		main_scene.label_infos.text = interaction_text
		main_scene.text_info.visible = true
		player_in_range = true

func _on_player_interaction_released(node: Node3D) -> void:
	if node == self:
		player_in_range = false
		main_scene.text_info.visible = false
