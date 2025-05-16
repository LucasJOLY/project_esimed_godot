extends Node


var current_level: Level

var current_level_key: String = "level_1"

var player:CharacterBody3D

var has_castle_key: bool = false

var has_castle_key_2: bool = false

var has_graveyard_key: bool = false

var has_graveyard_key_2: bool = false


var has_graveyard_key_3: bool = false


var boss_killed: bool = false



var collected_items: Array = []

var bottle_count: int = 0

var food_count: int = 0


var has_big_sword: bool = false


var has_big_shield: bool = false


var killed_ids: Array = []




var level: int = 1
var limit_level: int = 10
var experience: int = 0
var experience_to_next_level: int = 100  # XP nécessaire pour passer au niveau suivant

var attack_power: int = 10
var max_health: int = 100



var current_health: int = 100



var is_castle_completed: bool = false


func reset_game():
	current_level_key = "level_1"
	has_castle_key = false
	has_castle_key_2 = false
	has_graveyard_key = false
	has_graveyard_key_2 = false
	has_graveyard_key_3 = false
	collected_items = []
	bottle_count = 0
	food_count = 0
	has_big_sword = false
	has_big_shield = false
	killed_ids = []
	level = 1
	experience = 0
	experience_to_next_level = 100
	attack_power = 10
	max_health = 100
	current_health = 100
	is_castle_completed = false
