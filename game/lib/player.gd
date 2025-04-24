extends CharacterBody3D


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



func _ready():
	capture_mouse()



func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false



func _unhandled_input(event):
	if event is InputEventMouseMotion and mouse_captured:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		camera.rotation.x = clampf(camera.rotation.x, -MAX_CAMERA_ANGLE_UP, MAX_CAMERA_ANGLE_DOWN)

	elif event is InputEventKey and Input.is_action_just_pressed("cancel"):
		if mouse_captured:
			release_mouse()
		else:
			capture_mouse()

	if Input.is_action_just_pressed("player_attack"):
		print("Attaque !")
		anim_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	if Input.is_action_just_pressed("player_block"):
		print("Parade !")
		
		var current_state = anim_tree.get("parameters/is_blocking/current_state")
		if current_state == "true":
			anim_tree.set("parameters/is_blocking/transition_request", "false")
		else:
			anim_tree.set("parameters/is_blocking/transition_request", "true")

func _physics_process(delta: float) -> void:

	# Appliquer la gravité si pas au sol
	if not is_on_floor():
		velocity += get_gravity() * delta
		anim_tree.set("parameters/in_air/transition_request", "true")

	# Déclenche le saut uniquement si on est au sol
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Mouvement horizontal
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Vérifier si une animation one-shot est en cours
	var is_attacking = anim_tree.get("parameters/attack/active") == true
	var is_blocking = anim_tree.get("parameters/is_blocking/current_state") == "true"
	var can_move = not (is_attacking or is_blocking)

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
		print("on floor")
		anim_tree.set("parameters/in_air/transition_request", "false")
		if(input_dir.x != 0 or input_dir.y != 0) and can_move:
			if input_dir.y > 0:  # Si on va vers l'arrière
				print("walk_backward")
				anim_tree.set("parameters/movements/transition_request", "walk_backward")
			else:
				if(Input.is_action_pressed("player_run")):
					print("run")
					anim_tree.set("parameters/movements/transition_request", "run")
				else:
					print("walk")
					anim_tree.set("parameters/movements/transition_request", "walk")
		else:
			print("idle")
			anim_tree.set("parameters/movements/transition_request", "idle")

	move_and_slide()



func _on_area_3d_body_entered(body: Node3D) -> void:
	interaction_detected.emit(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	interaction_released.emit(body)
