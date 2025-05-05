extends Node


var current_level: Level_1

var current_level_key: String = "level_1"

var player:CharacterBody3D

var has_castle_key: bool = false

var has_castle_key_2: bool = false

var has_graveyard_key: bool = false

var has_graveyard_key_2: bool = false




var collected_items: Array = []

var bottle_count: int = 0

var food_count: int = 0


var has_big_sword: bool = false


var has_big_shield: bool = false




var level: int = 1
var limit_level: int = 10
var experience: int = 0
var experience_to_next_level: int = 100  # XP nécessaire pour passer au niveau suivant

var attack_power: int = 10
var defense_power: int = 5
var max_hearth: int = 5



var current_hearth: int = 5



var is_castle_completed: bool = false
