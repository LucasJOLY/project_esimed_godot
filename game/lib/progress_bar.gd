extends ProgressBar

@onready var label = $Label

func _ready():
	show_percentage = false  # désactive l'affichage automatique
	update_label()
	value_changed.connect(update_label)
	changed.connect(update_label)
	

func update_label(value = -1):
	var v = value if value != -1 else self.value
	label.text = "%d / %d" % [v, max_value]
