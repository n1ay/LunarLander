extends TextureProgress

func _ready():
	pass

func _on_Ship_fuel_update(value):
	self.value = value
	if (max_value < value):
		max_value = value
