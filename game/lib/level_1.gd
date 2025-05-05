class_name Level_1
extends Node3D

@export var key: String
@onready var world_environment: WorldEnvironment = $WorldEnvironment

var env: Environment
var transition_speed := 0.75

# Valeurs cibles
var target_fog_density := 0.0005
var target_fog_sky_affect := 0.2
var target_fog_light_energy := 1.0

func _ready() -> void:
	SimpleGrass.set_interactive(true)
	env = world_environment.environment
	# Init aux valeurs claires
	env.fog_density = 0.001
	env.fog_sky_affect = 0.5
	env.fog_light_energy = 1.0

func _process(delta: float) -> void:
	env.fog_density = lerp(env.fog_density, target_fog_density, delta * transition_speed)
	env.fog_sky_affect = lerp(env.fog_sky_affect, target_fog_sky_affect, delta * transition_speed)
	env.fog_light_energy = lerp(env.fog_light_energy, target_fog_light_energy, delta * transition_speed)

func _on_dark_zone_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		target_fog_density = 0.2
		target_fog_sky_affect = 1.0
		target_fog_light_energy = 0.1

func _on_dark_zone_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		target_fog_density = 0.0005
		target_fog_sky_affect = 0.2
		target_fog_light_energy = 1.0


func _on_dark_zone_2_body_entered(body: Node3D) -> void:
	if body.name == "Player" && GameState.is_castle_completed == false:
		target_fog_density = 0.2
		target_fog_sky_affect = 1.0
		target_fog_light_energy = 0.1


func _on_dark_zone_2_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		target_fog_density = 0.0005
		target_fog_sky_affect = 0.2
		target_fog_light_energy = 1.0
