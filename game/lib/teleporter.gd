extends Node3D

@export var enter_text: String = "Appuyez sur E pour entrer"
@export var door_locked_text: String = "Vous n'avez pas la clé"

@export var key_type: String = "has_castle_key_2"

@export var teleport_to: Node3D




@onready var main_scene: Node3D = get_tree().root.get_node("Main")
@onready var message_timer: Timer = Timer.new()

var player:Player = GameState.player
var player_in_range = false


func _ready():
	player.interaction_detected.connect(_on_player_interaction_detected)
	player.interaction_released.connect(_on_player_interaction_released)

func _on_player_interaction_detected(node: Node3D):
	if node == self:
		player_in_range = true
		main_scene.text_info.visible = true
		main_scene.label_infos.text = enter_text;





func _on_player_interaction_released(node: Node3D):
	if node == self:
		main_scene.text_info.visible = false
		player_in_range = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("player_interract"):
		if key_type != null and GameState.get(key_type):
			teleport()
		elif key_type == null:
			teleport()
		else:
			main_scene.text_info.visible = true
			main_scene.label_infos.text = door_locked_text

func teleport():
	player.global_transform = teleport_to.global_transform
