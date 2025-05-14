extends Node3D

@export var item_name: String = "Clé du chateau"
@export var item_variable: String = "has_castle_key"
@export var interaction_text: String = "Appuyez sur E pour ouvrir le coffre"
@export var obtained_text: String = "Nouvel Objet : "
@export var object: Node3D

@onready var animation_player = $AnimationPlayer
@onready var main_scene: Node3D = get_tree().root.get_node("Main")

var player:Player = GameState.player
var timer: Timer
var object_tween: Tween

var is_open = false
var player_in_range = false

func _ready():
	# Initialiser le coffre comme fermé
	if GameState.get(item_variable):
		animation_player.play("open")
		is_open = true
	else:
		animation_player.play("close")
	player.interaction_detected.connect(_on_player_interaction_detected)
	player.interaction_released.connect(_on_player_interaction_released)
	
	# Créer et configurer le timer
	timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# Initialiser l'objet
	if object:
		object.position = Vector3(0, 0, 0)  # Position initiale au niveau du coffre
		object.visible = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("player_interract"):

		if not is_open:
			player.interract_with_item()
			open_chest()

func _on_timer_timeout():
	main_scene.text_info.visible = false
	if object:
		object.visible = false

func open_chest():
	if not is_open:
		animation_player.play("open")
		is_open = true
		main_scene.label_infos.text = obtained_text + item_name
		main_scene.text_info.visible = true
		
		# Animer l'objet
		if object:
			object.visible = true
			object.position = Vector3(0, 0, 0)
			object_tween = create_tween()
			object_tween.tween_property(object, "position", Vector3(0, 0.24, 0), 1.0)
			# Ajouter une rotation continue
			object_tween.tween_property(object, "rotation:y", TAU, 2.0).as_relative()
			object_tween.set_loops()  # Faire tourner l'animation en boucle
		
		# Démarrer le timer
		timer.start()
		
		# Sauvegarder l'état de l'objet
		GameState.set(item_variable, true)
		

func _on_player_interaction_detected(node: Node3D) -> void:
	print("interaction detected")
	if node == self and not is_open:
		main_scene.label_infos.text = interaction_text
		main_scene.text_info.visible = true
		player_in_range = true

func _on_player_interaction_released(node: Node3D) -> void:
	if node == self:
		player_in_range = false
		main_scene.text_info.visible = false
