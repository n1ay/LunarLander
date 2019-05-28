extends RigidBody2D

var THROTTLE_IMPULSE = 10
var POSITION_OFFSET = 30

func _ready():
	$Flame.hide()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rotation = deg2rad(get_rotation_degrees())
	var direction = Vector2(0, 1).rotated(rotation)
	var direction_rot_by_right_angle = direction.rotated(deg2rad(90))
	
	if Input.is_action_pressed("ui_up"):
		var offset_up = Vector2(0, POSITION_OFFSET)
		apply_impulse(offset_up.rotated(rotation), -THROTTLE_IMPULSE * direction)
		
	if Input.is_action_pressed("ui_right") and not(Input.is_action_pressed("ui_left")):
		var offset_right = Vector2(-POSITION_OFFSET, POSITION_OFFSET)
		apply_impulse(offset_right.rotated(rotation), -THROTTLE_IMPULSE * direction_rot_by_right_angle)
		
	if Input.is_action_pressed("ui_left") and not(Input.is_action_pressed("ui_right")):
		var offset_left = Vector2(POSITION_OFFSET, POSITION_OFFSET)
		apply_impulse(offset_left.rotated(rotation), THROTTLE_IMPULSE * direction_rot_by_right_angle)