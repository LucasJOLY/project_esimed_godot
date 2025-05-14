class_name Player extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
signal interaction_detected(node:Node3D)
signal interaction_released(node:Node3D)


@onready var camera:Camera3D = $Camera

const MOUSE_SENSITIVITY:float = 0.002
const MAX_CAMERA_ANGLE_UP:float = deg_to_rad(60)
const MAX_CAMERA_ANGLE_DOWN:float = deg_to_rad(75)
var mouse_captured:bool = false

@onready var anim_tree = $Knight/AnimationTree
@onready var anim_player = $Knight/AnimationPlayer 



@onready var big_sword = $"Knight/Rig/Skeleton3D/2H_Sword"
@onready var big_shield = $"Knight/Rig/Skeleton3D/Rectangle_Shield"
@onready var small_sword = $"Knight/Rig/Skeleton3D/1H_Sword"
@onready var small_shield = $"Knight/Rig/Skeleton3D/Round_Shield"


@onready var small_sword_area = $"Knight/Rig/Skeleton3D/1H_Sword/SwordArea"
@onready var big_sword_area = $"Knight/Rig/Skeleton3D/2H_Sword/SwordArea"

@onready var main_scene: Node3D = get_tree().root.get_node("Main")



var dead:bool = false

func _ready():
	dead = false
	anim_tree.set("parameters/death/transition_request", "false")
	if(GameState.has_big_sword):
		big_sword_area.monitoring = false
		big_sword_area.body_entered.connect(_on_sword_hit)
	else:
		small_sword_area.monitoring = false
		small_sword_area.body_entered.connect(_on_sword_hit)
	capture_mouse()

func _on_sword_hit(body: Node):
	print("sword hit")
	if body.collision_layer == 5: # Layer 2 pour les ennemis
		print("enemie hit")
		if body.has_method("take_damage"):
			body.take_damage(GameState.attack_power)



func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false



func _unhandled_input(event):
	if event is InputEventMouseMotion and mouse_captured and dead == false:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera.rotation.x = clampf(camera.rotation.x, -MAX_CAMERA_ANGLE_UP, MAX_CAMERA_ANGLE_DOWN)

	if Input.is_action_just_pressed("player_attack") and dead == false:
		anim_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		if(GameState.has_big_sword):
			await get_tree().create_timer(0.3).timeout  # attendre avant d'activer (calé avec l'animation)
			big_sword_area.monitoring = true
			await get_tree().create_timer(0.2).timeout  # temps de frappe actif
			big_sword_area.monitoring = false
		else:
			await get_tree().create_timer(0.3).timeout  # attendre avant d'activer (calé avec l'animation)
			small_sword_area.monitoring = true
			await get_tree().create_timer(0.2).timeout  # temps de frappe actif
			small_sword_area.monitoring = false

	if Input.is_action_just_pressed("player_block") and dead == false:
		var current_state = anim_tree.get("parameters/is_blocking/current_state")
		if current_state == "true":
			anim_tree.set("parameters/is_blocking/transition_request", "false")
		else:
			anim_tree.set("parameters/is_blocking/transition_request", "true")

func _physics_process(delta: float) -> void:
	if GameState.has_big_sword:
		big_sword.visible = true
		small_sword.visible = false
	else:
		big_sword.visible = false
		small_sword.visible = true

	if GameState.has_big_shield:
		big_shield.visible = true
		small_shield.visible = false
	else:
		big_shield.visible = false
		small_shield.visible = true



	SimpleGrass.set_player_position(global_position)

	# Appliquer la gravité si pas au sol
	if not is_on_floor():
		velocity += get_gravity() * delta
		anim_tree.set("parameters/in_air/transition_request", "true")

	# Déclenche le saut uniquement si on est au sol
	if Input.is_action_just_pressed("player_jump") and is_on_floor() and dead == false:
		velocity.y = JUMP_VELOCITY

	# Mouvement horizontal
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Vérifier si une animation one-shot est en cours
	var is_attacking = anim_tree.get("parameters/attack/active") == true
	var is_blocking = anim_tree.get("parameters/is_blocking/current_state") == "true"
	var is_using_item = anim_tree.get("parameters/use_item/active") == true
	var can_move = not (is_attacking or is_blocking or dead)

	if !is_attacking && !is_blocking && !dead && !is_using_item:
		if Input.is_action_just_pressed("player_use_item1"):
			use_item("bottle")
		elif Input.is_action_just_pressed("player_use_item2"):
			use_item("food")

	if direction and can_move:
		var speed_multiplier = 1.0
		if(Input.is_action_pressed("player_run") and input_dir.y < 0):
			speed_multiplier = 2.0
		velocity.x = direction.x * SPEED * speed_multiplier
		velocity.z = direction.z * SPEED * speed_multiplier

		if not mouse_captured:
			capture_mouse()

		# Monte les escaliers si collision avec un objet en groupe "stairs"
		for index in range(get_slide_collision_count()):
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if collider != null and collider.is_in_group("stairs"):
				velocity.y = 1.5
	else:
		# Freinage progressif
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if is_on_floor():
		anim_tree.set("parameters/in_air/transition_request", "false")
		if(input_dir.x != 0 or input_dir.y != 0) and can_move:
			if input_dir.y > 0:  # Si on va vers l'arrière
				anim_tree.set("parameters/movements/transition_request", "walk_backward")
			else:
				if(Input.is_action_pressed("player_run")):
					anim_tree.set("parameters/movements/transition_request", "run")
				else:
					anim_tree.set("parameters/movements/transition_request", "walk")
		else:
			anim_tree.set("parameters/movements/transition_request", "idle")

	move_and_slide()



func _on_area_3d_body_entered(body: Node3D) -> void:
	interaction_detected.emit(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	interaction_released.emit(body)


func use_item(item: String) -> void:
	if item == "bottle":
		if GameState.bottle_count > 0:
			GameState.current_hearth = GameState.max_hearth
			GameState.bottle_count -= 1	
			main_scene._update_health_display()
			main_scene.handle_hud()
	elif item == "food":
		if GameState.food_count > 0:
			GameState.food_count -= 1
			GameState.current_hearth += 1
			main_scene._update_health_display()
			main_scene.handle_hud()
	anim_tree.set("parameters/use_item/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func interract_with_item() -> void:
		anim_tree.set("parameters/interract/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)



func take_damage(amount: int) -> void:
	var is_blocking = anim_tree.get("parameters/is_blocking/current_state") == "true"
	if is_blocking:
		return;
	GameState.current_hearth -= amount
	main_scene._update_health_display()
	if GameState.current_hearth <= 0:
		GameState.current_hearth = 0
		die()



func die() -> void:
	dead = true
	anim_tree.set("parameters/death/transition_request", "true")
	release_mouse()
	main_scene.death_screen.visible = true
	main_scene.hud.visible = false
	

func collect_item() -> void:
	# déclenche l'anim avec un oneshot
	anim_tree.set("parameters/collect_item/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	main_scene.handle_hud()
# système de niveau

func gain_experience(amount: int) -> void:
	GameState.experience += amount
	while GameState.experience >= GameState.experience_to_next_level:
		main_scene.exp_bar.value = GameState.experience
		GameState.experience -= GameState.experience_to_next_level
		level_up()


func level_up() -> void:
	if GameState.level < GameState.limit_level:
		main_scene.level_hud.text = str(GameState.level + 1)
		main_scene.level_up()
		GameState.level += 1
		GameState.experience_to_next_level = int(GameState.experience_to_next_level * 1.5)  # XP nécessaire augmente à chaque niveau

		# Bonus de stats équilibrés
		GameState.attack_power += 2
		GameState.defense_power += 1
		GameState.max_hearth += 1
		GameState.current_hearth = GameState.max_hearth  # Soigne au max à chaque level-up
