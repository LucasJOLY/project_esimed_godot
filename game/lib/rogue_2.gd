extends CharacterBody3D

@export var move_distance: float = 4.0
@export var speed: float = 2.0
@export var wait_time: float = 5.0
@export var rotation_speed: float = -180.0 # degré par seconde

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var main_scene: Node3D = get_tree().root.get_node("Main")



@export var name_character: String = "Rogue"

var player: Player = GameState.player
var can_talk := false
var current_dialogue = -2

var dialogue_sequence = [
	"Bienvenu dans ce royaume, cela fait bien longtemps que j'attend un chevalier comme toi qui pourra m'aider",
	"Ah bon ?",
	"Oui j'ai besoin de quelqu'un qui pourra vaincre ces foutus monstre",
	"Des monstres ?",
	"Oui le chateau que tu vois la bas est maudit par des monstres tu dois m'aider ! J'étais bucheron la bas auparavant mais le roi a du s'échapper et mtn les squelettes ont pris le controle du chateau et de son donjon",
	"Comment t'aider ?",
	"Prend la clé dans ce coffre et tu pourras entrer dans le chateau ! Fais attention a toi !",
	"Je vais t'aider !"
]

# States
enum State { WALKING, WAITING, ROTATING }
var state: State = State.WALKING

var move_start_position: Vector3
var wait_timer: float = 0.0

var player_in_zone := false
var target_rotation: float = 0.0
var rotating_to_player := false

func _ready() -> void:
	player.interaction_detected.connect(_on_player_interaction_detected)
	player.interaction_released.connect(_on_player_interaction_released)
	move_start_position = global_position # Initialiser au début

func _on_player_interaction_detected(node: Node3D) -> void:
	print("interaction detected")
	if node == self:
		if not main_scene.disussion_box.visible:
			main_scene.label_infos.text = "Appuyez sur E pour parler"
			main_scene.text_info.visible = true
			can_talk = true

func _on_player_interaction_released(node: Node3D) -> void:
	if node == self:
		main_scene.text_info.visible = false
		can_talk = false

func _process(delta: float) -> void:
	if can_talk:
		if Input.is_action_just_pressed("player_interract"):

			if current_dialogue < dialogue_sequence.size() - 2:
				current_dialogue += 2
				talk()
			else:
				main_scene.disussion_box.visible = false
				current_dialogue = -2
				can_talk = false

	if Input.is_action_just_pressed("player_quit_discussion"):
		main_scene.disussion_box.visible = false
		current_dialogue = -2
		can_talk = false


func talk() -> void:
	main_scene.text_info.visible = false
	main_scene.disussion_box.visible = true
	main_scene.disussion_name.text = name_character
	main_scene.disussion_text.text = dialogue_sequence[current_dialogue]
	main_scene.disussion_next_text.text = "E : " + dialogue_sequence[current_dialogue + 1]

func _physics_process(delta: float) -> void:
	if player_in_zone:
		animation_tree.set("parameters/is_moving/transition_request", "false")
		if not rotating_to_player:
			rotate_towards_player()
		return

	match state:
		State.WALKING:
			animation_tree.set("parameters/is_moving/transition_request", "true")
			var direction = transform.basis.z.normalized() # Avancer vers l'avant
			velocity = direction * speed
			move_and_slide()

			var distance_moved = global_position.distance_to(move_start_position)
			if distance_moved >= move_distance:
				state = State.WAITING
				velocity = Vector3.ZERO
				wait_timer = wait_time
				move_start_position = global_position

		State.WAITING:
			animation_tree.set("parameters/is_moving/transition_request", "false")
			wait_timer -= delta
			if wait_timer <= 0.0:
				state = State.ROTATING

		State.ROTATING:
			animation_tree.set("parameters/is_moving/transition_request", "false")
			rotate_y(deg_to_rad(rotation_speed * delta))
			# On tourne pendant un certain angle, par exemple 90°
			# Ici simple : après 1 seconde de rotation (~90°), on recommence à marcher
			wait_timer += delta
			if wait_timer >= 1.0:
				wait_timer = 0.0
				move_start_position = global_position
				state = State.WALKING

func rotate_towards_player() -> void:
	rotating_to_player = true
	var direction_to_player = (player.global_position - global_position).normalized()
	var target_angle = atan2(direction_to_player.x, direction_to_player.z)
	rotation.y = target_angle

func _on_zone_vision_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player_in_zone = true
		rotating_to_player = false

func _on_zone_vision_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		player_in_zone = false
		rotating_to_player = false
		move_start_position = global_position
		state = State.WALKING
