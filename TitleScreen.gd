extends Control

func _ready():
	pass

#func _process(delta):
#	pass

func _on_NewGame_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://World.tscn")

func _on_Exit_pressed():
	get_tree().quit()
