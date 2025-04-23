extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5
@onready var camera:Camera3D = $Camera

const MOUSE_SENSITIVITY:float = 0.002
const MAX_CAMERA_ANGLE_UP:float = deg_to_rad(60)
const MAX_CAMERA_ANGLE_DOWN:float = deg_to_rad(75)
var mouse_captured:bool = false


@onready var animation_player:AnimationPlayer = $AnimationPlayer

const ANIMATION_WALK:String = "player/walking"
const ANIMATION_IDLE:String = "player/standing_idle"
const ANIMATION_RUN:String = "player/running"


func _ready():
	capture_mouse()
	animation_player.play(ANIMATION_IDLE)



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
	if event is InputEventKey and Input.is_action_just_pressed("cancel"):
		if(mouse_captured):
			release_mouse()
		else:
			capture_mouse()
	



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if (!mouse_captured): capture_mouse()
		animation_player.play(ANIMATION_WALK)
		for index in range (get_slide_collision_count()):
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if(collider != null and collider.is_in_group("stairs")):
				velocity.y = 1.5
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		animation_player.play(ANIMATION_IDLE)

	move_and_slide()

signal interaction_detected(node:Node3D)
signal interaction_released(node:Node3D)

func _on_area_3d_body_entered(body: Node3D) -> void:
	interaction_detected.emit(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	interaction_released.emit(body)
