extends VBoxContainer

func _ready():
	$InvertControlsCheckBox.pressed = global.invert_left_right_controls


func _on_BackButton_pressed():
	get_tree().change_scene("res://TitleScreen.tscn")


func _on_InvertControlsCheckBox_pressed():
	global.invert_left_right_controls = $InvertControlsCheckBox.is_pressed()
