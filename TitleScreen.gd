extends Control

func _ready():
	if not(global.loaded):
		global.load_level_hashes()
		global.load_state()
	pass

#func _process(delta):
#	pass

func _on_NewGame_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://ChooseLevelScreen.tscn")

func _on_Exit_pressed():
	global.save_state()
	get_tree().quit()


func _on_Options_pressed():
	get_tree().change_scene("res://OptionsScreen.tscn")
