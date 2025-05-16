extends StaticBody3D


@onready var torch_lit_sound: AudioStreamPlayer3D = $TorchLitSound


func _ready():
	torch_lit_sound.play()
