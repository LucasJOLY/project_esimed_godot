class_name Level
extends Node3D

@export var key: String
@onready var world_environment: WorldEnvironment = $WorldEnvironment

var env: Environment
var transition_speed := 0.75

# Valeurs cibles
var target_fog_density := 0.0005
var target_fog_sky_affect := 0.2
var target_fog_light_energy := 1.0

@onready var theme_castle: AudioStreamPlayer = $ThemeCastle
@onready var theme_graveyard: AudioStreamPlayer = $ThemeGraveyard
@onready var theme_village: AudioStreamPlayer = $ThemeVillage
@onready var theme_dungeon: AudioStreamPlayer = $ThemeDungeon
@onready var theme_boss: AudioStreamPlayer = $ThemeBoss

@onready var theme_menu: AudioStreamPlayer = $ThemeMenu

@onready var main_scene: Node3D = get_tree().root.get_node("Main")

var actual_sound: String = ""

func _process(delta: float) -> void:
	if world_environment:
		env.fog_density = lerp(env.fog_density, target_fog_density, delta * transition_speed)
		env.fog_sky_affect = lerp(env.fog_sky_affect, target_fog_sky_affect, delta * transition_speed)
		env.fog_light_energy = lerp(env.fog_light_energy, target_fog_light_energy, delta * transition_speed)
	if main_scene.start_screen.visible == true or main_scene.death_screen.visible == true:
		if theme_menu.playing == false:
			theme_castle.stop()
			theme_graveyard.stop()
			theme_village.stop()
			theme_dungeon.stop()
			theme_boss.stop()
			theme_menu.play()
	elif main_scene.start_screen.visible == false and main_scene.death_screen.visible == false:
		if theme_menu.playing == true:
			theme_menu.stop()
			if actual_sound == "theme_castle":
				theme_castle.play()
			elif actual_sound == "theme_graveyard":
				theme_graveyard.play()
			elif actual_sound == "theme_village":
				theme_village.play()
			elif actual_sound == "theme_dungeon":
				theme_dungeon.play()
			elif actual_sound == "theme_boss":
				theme_boss.play()
			elif GameState.current_level_key == "level_1":
				theme_village.play()
			elif GameState.current_level_key == "level_2":
				theme_dungeon.play()

func _ready() -> void:
	if(key == 'level_2'):
		actual_sound = "theme_dungeon"
		theme_castle.stop()
		theme_graveyard.stop()
		theme_village.stop()
		theme_dungeon.play()
		
	elif(key == 'level_1'):
		actual_sound = "theme_village"
		theme_dungeon.stop()
		theme_village.play()		
	SimpleGrass.set_interactive(true)
	if world_environment:
		env = world_environment.environment
		# Init aux valeurs claires
		env.fog_density = 0.001
		env.fog_sky_affect = 0.5
		env.fog_light_energy = 1.0



func _on_dark_zone_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		actual_sound = "theme_graveyard"
		theme_castle.stop()
		theme_village.stop()
		theme_dungeon.stop()
		theme_graveyard.play()
		target_fog_density = 0.2
		target_fog_sky_affect = 1.0
		target_fog_light_energy = 0.1

func _on_dark_zone_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		actual_sound = "theme_village"
		theme_castle.stop()
		theme_graveyard.stop()
		theme_dungeon.stop()
		theme_village.play()
		target_fog_density = 0.0005
		target_fog_sky_affect = 0.2
		target_fog_light_energy = 1.0


func _on_dark_zone_2_body_entered(body: Node3D) -> void:
	actual_sound = "theme_castle"
	theme_village.stop()
	theme_graveyard.stop()
	theme_dungeon.stop()
	theme_castle.play()
	if body.name == "Player" && GameState.is_castle_completed == false:
		target_fog_density = 0.2
		target_fog_sky_affect = 1.0
		target_fog_light_energy = 0.1


func _on_dark_zone_2_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		actual_sound = "theme_village"
		theme_castle.stop()
		theme_graveyard.stop()
		theme_dungeon.stop()
		theme_village.play()
		target_fog_density = 0.0005
		target_fog_sky_affect = 0.2
		target_fog_light_energy = 1.0


func _on_boss_zone_body_entered(body: Node3D) -> void:
	if body.name == "Player" and GameState.boss_killed == false:
		actual_sound = "theme_boss"
		theme_village.stop()
		theme_graveyard.stop()
		theme_dungeon.stop()
		theme_castle.stop()
		theme_boss.play()

func _on_boss_zone_body_exited(body: Node3D) -> void:
	if body.name == "Player" and GameState.boss_killed == false:
		actual_sound = "theme_dungeon"
		theme_castle.stop()
		theme_graveyard.stop()
		theme_village.stop()
		theme_dungeon.play()
		theme_boss.stop()
