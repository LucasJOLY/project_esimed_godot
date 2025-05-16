extends Node3D

@export var open_text: String = "Appuyez sur E pour ouvrir"
@export var closed_text: String = "Appuyez sur E pour fermer"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


@onready var open_door_sound: AudioStreamPlayer3D = $OpenDoorSound
@onready var close_door_sound: AudioStreamPlayer3D = $CloseDoorSound


@onready var main_scene: Node3D = get_tree().root.get_node("Main")
@onready var message_timer: Timer = Timer.new()

var player:Player = GameState.player
var player_in_range = false

var is_open = false

func _ready():
	player.interaction_detected.connect(_on_player_interaction_detected)
	player.interaction_released.connect(_on_player_interaction_released)

func _on_player_interaction_detected(node: Node3D):
	if node == self:
		player_in_range = true
		main_scene.text_info.visible = true
		main_scene.label_infos.text = open_text if !is_open else closed_text





func _on_player_interaction_released(node: Node3D):
	if node == self:
		main_scene.text_info.visible = false
		player_in_range = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("player_interract"):
		player.interract_with_item()
		if animation_player.is_playing() == false:
			if is_open == false:
				open_door()
			else:
				close_door()

func open_door():
	animation_player.play("open_door")
	open_door_sound.play()
	close_door_sound.stop()
	is_open = true


func close_door():
	animation_player.play("close_door")
	open_door_sound.stop()
	close_door_sound.play()
	is_open = false
