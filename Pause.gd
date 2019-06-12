extends Control

var canvas_layer

func _ready():
	canvas_layer = $"../"
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")
	canvas_layer.set_offset(Vector2((width - width * get_scale().x) / 2,
		(height - height * get_scale().y) / 2))
	pass

func continue_paused():
	get_tree().paused = false
	self.hide()

func _on_Exit_pressed():
	global.save_state()
	get_tree().paused = false
	get_tree().quit()

func _on_MainMenu_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")

func _on_Continue_pressed():
	continue_paused()
