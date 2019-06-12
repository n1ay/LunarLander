extends VBoxContainer

var level_buttons

func _ready():
	level_buttons = [
		$HBoxContainer/LevelButton,
		$HBoxContainer/LevelButton2,
		$HBoxContainer/LevelButton3,
		$HBoxContainer/LevelButton4,
		$HBoxContainer/LevelButton5,
		$HBoxContainer/LevelButton6,
		$HBoxContainer2/LevelButton,
		$HBoxContainer2/LevelButton2,
		$HBoxContainer2/LevelButton3,
		$HBoxContainer2/LevelButton4,
		$HBoxContainer2/LevelButton5,
		$HBoxContainer2/LevelButton6
	]
	
	for i in range(len(level_buttons)):
		var level_label = level_buttons[i].get_node("ColorRectTop/LevelLabel")
		var button = level_buttons[i].get_node("Button")
		if global.unlocked_level >= i:
			level_label.set_text(str(i + 1))
			button.disabled = false
			button.connect("pressed", self, "start_level", [i])
		else:
			level_label.set_text('X')
			button.disabled = true

func start_level(level_number):
	global.play_level = level_number
	get_tree().change_scene("res://World.tscn")

func _on_BackButton_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")
