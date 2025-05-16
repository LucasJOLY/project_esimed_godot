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
var distance_to_player: float = 0.0

func _ready():
	if item_id in GameState.collected_items:
		queue_free()
		return
	add_to_group("collectable_items")
	player.interaction_detected.connect(_on_player_interaction_detected)
	player.interaction_released.connect(_on_player_interaction_released)
	
	# Configuration du timer
	message_timer.wait_time = 5.0
	message_timer.one_shot = true
	message_timer.timeout.connect(_on_timer_timeout)
	add_child(message_timer)

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("player_interract"):
		# Vérifier si cet objet est le plus proche
		var is_closest = true
		for item in get_tree().get_nodes_in_group("collectable_items"):
			if item != self and item.player_in_range:
				if item.distance_to_player < distance_to_player:
					is_closest = false
					break
		
		if is_closest:
			var is_collecting = player.anim_tree.get("parameters/collect_item/active") == true
			if not is_collecting:
				collect_item()

func _on_timer_timeout():
	main_scene.text_info.visible = false

func collect_item():
	if item_type == "bottle" and GameState.bottle_count < Consts.MAX_BOTTLE_COUNT:
		GameState.bottle_count += 1
		GameState.collected_items.append(item_id)   
		player.collect_item()
		var text:String = obtained_text + item_name
		main_scene.label_infos.text = text
		main_scene.text_info.visible = true
		message_timer.start()
		# rend invisible  sans queue free car sinon le message ne sera plus affiché
		visible = false
		await get_tree().create_timer(5.0).timeout
		queue_free()
	elif item_type == "bottle" and GameState.bottle_count >= Consts.MAX_BOTTLE_COUNT:
		main_scene.label_infos.text = "Vous ne pouvez plus ramasser de bouteilles"
		main_scene.text_info.visible = true
		message_timer.start()
	elif item_type == "food" and GameState.food_count < Consts.MAX_FOOD_COUNT:
		GameState.food_count += 1
		GameState.collected_items.append(item_id)
		player.collect_item()
		var text:String = obtained_text + item_name
		main_scene.label_infos.text = text
		main_scene.text_info.visible = true
		message_timer.start()
		# rend invisible  sans queue free car sinon le message ne sera plus affiché
		visible = false
		await get_tree().create_timer(5.0).timeout
		queue_free()

		
	elif item_type == "food" and GameState.food_count >= Consts.MAX_FOOD_COUNT:
		main_scene.label_infos.text = "Vous ne pouvez plus ramasser de nourriture"
		main_scene.text_info.visible = true
		message_timer.start()



func _on_player_interaction_detected(node: Node3D) -> void:
	if node == self:
		distance_to_player = global_position.distance_to(player.global_position)
		main_scene.label_infos.text = interaction_text
		main_scene.text_info.visible = true
		player_in_range = true

func _on_player_interaction_released(node: Node3D) -> void:
	if node == self:
		player_in_range = false
		main_scene.text_info.visible = false
		
