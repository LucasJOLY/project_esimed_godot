class_name Squeleton_Minion
extends CharacterBody3D

@export var skeleton_id: String
@export var spawn_type: String = "ground" # "ground" ou "awaken"
@export var health: int = 100
@export var attack_damage: int = 1
@export var level: int = 1
@export var detection_radius: float = 10.0
@export var awaken_detection_radius: float = 20.0
@export var attack_radius: float = 1.0
@export var move_speed: float = 2.5

@onready var anim_tree = $Skeleton_Minion/AnimationTree
@onready var anim_player = $Skeleton_Minion/AnimationPlayer
@onready var player = GameState.player



@export_node_path("Area3D") var attack_area_path
@onready var attack_area: Area3D = get_node(attack_area_path)


var is_active = false
var is_dead = false
var is_attacking = false

func _ready():
	if GameState.killed_ids.has(skeleton_id):
		queue_free()
		return
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_hit)
	
	if spawn_type == "ground":
		$Skeleton_Minion.visible = false
	elif spawn_type == "awaken":
		anim_tree.set("parameters/inactive/transition_request", "true")

func _physics_process(delta):
	if is_dead or GameState.killed_ids.has(skeleton_id): return

	var to_player = player.global_position - global_position
	var dist = to_player.length()

	# Activation
	if not is_active and dist < awaken_detection_radius:
		is_active = true
		if spawn_type == "awaken":
			anim_tree.set("parameters/inactive/transition_request", "false")
			anim_tree.set("parameters/awaken_floor/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		elif spawn_type == "ground":
			$Skeleton_Minion.visible = true
			anim_tree.set("parameters/spawn_ground/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	# Si activé
	if is_active and dist < detection_radius:
		
		var is_attacking = anim_tree.get("parameters/attack/active") == true
		var is_awakening = anim_tree.get("parameters/awaken_floor/active") == true
		var is_spawning = anim_tree.get("parameters/spawn_ground/active") == true
		
		if not (is_awakening or is_spawning or is_attacking):
			anim_tree.set("parameters/sleep/transition_request", "false")
			# Tourner vers le joueur (en ignorant la hauteur)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			rotate_y(PI) # Rotation de 180 degrés pour faire face au joueur

			# Attaque ou déplacement
			if dist > attack_radius:
				var dir = to_player.normalized()
				anim_tree.set("parameters/movements/transition_request", "walk")
				velocity.x = dir.x * move_speed
				velocity.z = dir.z * move_speed
				move_and_slide()
			else:
				velocity = Vector3.ZERO
				move_and_slide()
				attack()
	else:
		anim_tree.set("parameters/sleep/transition_request", "true")
		
func attack():
	var is_attacking = anim_tree.get("parameters/attack/active") == true
	if is_attacking: return
	anim_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(0.5).timeout # Timing du début du coup
	attack_area.monitoring = true
	await get_tree().create_timer(0.2).timeout # Durée du coup
	attack_area.monitoring = false


func _on_attack_area_hit(body: Node):
	# print les groupe du body
	print(body.get_groups())
	if (body.is_in_group("player")):
		body.get_parent().take_damage(attack_damage)

func take_damage(amount: int):
	if is_dead: return
	health -= amount
	if health <= 0:
		die()

func die():
	is_dead = true
	anim_tree.set("parameters/die/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await anim_player.animation_finished
	GameState.killed_ids.append(skeleton_id)
	queue_free()
