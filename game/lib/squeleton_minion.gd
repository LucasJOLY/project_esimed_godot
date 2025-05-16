class_name Squeleton_Minion
extends CharacterBody3D

@export var skeleton_id: String
enum SpawnType { GROUND, AWAKEN }
@export var spawn_type: SpawnType = SpawnType.GROUND
@export var health: int = 100
@export var attack_damage: int = 5
@export var level: int = 1
@export var detection_radius: float = 10.0
@export var gain_experience: int = 10
@export var awaken_detection_radius: float = 15.0
@export var attack_radius: float = 1.2
@export var move_speed: float = 2.5

@onready var anim_tree = $Skeleton/AnimationTree
@onready var anim_player = $Skeleton/AnimationPlayer
@onready var player = GameState.player


@onready var info_top: Sprite3D = $Sprite3D2
@onready var health_bar: ProgressBar = $Sprite3D2/HealthBarViewport/HealthBar/ProgressBar
@onready var level_label: Label = $Sprite3D2/HealthBarViewport/HealthBar/TextureRect/Label



@onready var attack_area: Area3D = $AttackArea

var is_active = false
var is_dead = false
var is_attacking = false
var has_spawned = false

func _ready():
	level_label.text = str(level)
	info_top.visible = false
	# set la max value de la bar en fonction de la health
	health_bar.max_value = health
	health_bar.value = health
	if GameState.killed_ids.has(skeleton_id):
		queue_free()
		return

	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_hit)

	if spawn_type == SpawnType.GROUND:
		$Skeleton.visible = false
	elif spawn_type == SpawnType.AWAKEN:
		anim_tree.set("parameters/inactive/transition_request", "true")

func _physics_process(delta):
	if is_dead or GameState.killed_ids.has(skeleton_id): return

	var to_player = player.global_position - global_position
	var dist = to_player.length()

	# Activation du squelette
	if not is_active and dist < awaken_detection_radius:
		is_active = true
		if spawn_type == SpawnType.AWAKEN:
			anim_tree.set("parameters/inactive/transition_request", "false")
			anim_tree.set("parameters/awaken_floor/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			# wait 2.3
			await get_tree().create_timer(2.3).timeout
			has_spawned = true
			info_top.visible = true
		elif spawn_type == SpawnType.GROUND:
			$Skeleton.visible = true
			anim_tree.set("parameters/spawn_ground/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			# wait 3.5667
			await get_tree().create_timer(3.5667).timeout
			has_spawned = true
			info_top.visible = true
	if is_active and dist < detection_radius:
		if player.dead == true:
			anim_tree.set("parameters/movements/transition_request", "idle")
			return
		
		var is_anim_busy = anim_tree.get("parameters/attack/active") == true \
			or anim_tree.get("parameters/awaken_floor/active") == true \
			or anim_tree.get("parameters/spawn_ground/active") == true

		if not is_anim_busy:
			# Tourner vers le joueur (sans pencher)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			rotate_y(PI)

			# Déplacement ou attaque

			if dist > attack_radius:
				var dir = to_player.normalized()
				anim_tree.set("parameters/movements/transition_request", "walk")
				velocity.x = dir.x * move_speed
				velocity.z = dir.z * move_speed
				move_and_slide()
			else:
				velocity = Vector3.ZERO
				move_and_slide()
				if player.dead == false :
					attack()
	elif is_active and dist > detection_radius and has_spawned:
		anim_tree.set("parameters/movements/transition_request", "idle")


func attack():
	if is_attacking:
		return

	is_attacking = true
	anim_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	await get_tree().create_timer(0.5).timeout # début du coup
	attack_area.monitoring = true

	await get_tree().create_timer(0.2).timeout # durée de l'impact
	attack_area.monitoring = false
	is_attacking = false

func _on_attack_area_hit(body: Node):
	var root = null
	if body and body.is_in_group("player"):

		root = body.get_parent()

	if root != null and root.has_method("take_damage"):
		root.take_damage(attack_damage)


func take_damage(amount: int):

	if is_dead: return
	health -= amount
	health_bar.value = health
	if health <= 0:
		if skeleton_id == "boss":
			GameState.boss_killed = true
		if skeleton_id == "boss_castle":
			GameState.is_castle_completed = true
		die()

func die():
	is_dead = true

	anim_tree.set("parameters/die/transition_request", "true")
	player.gain_experience(gain_experience)
	await get_tree().create_timer(2.5).timeout
	GameState.killed_ids.append(skeleton_id)
	queue_free()
