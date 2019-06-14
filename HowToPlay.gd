extends Control

func _ready():
	pass # Replace with function body.

func _input(event):
    if ((event is InputEventKey) or (event is InputEventMouseButton)) and event.pressed:
        get_tree().change_scene("World.tscn")
