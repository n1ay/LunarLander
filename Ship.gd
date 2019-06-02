extends RigidBody2D

## constants
var THROTTLE_IMPULSE = 10
var POSITION_OFFSET = 30
var FLAME_TIMER_TICK = 0.1
var MAX_FUEL = 100
var USE_FUEL = 0.1
var CRITICAL_VELOCITY = 500
var CRITICAL_Y_POS = 5

signal fuel_update(value)

## variables
# flames
var flames
var flameTimers
var flameAnimations

# fuel
var fuel = MAX_FUEL
var fuel_previous = fuel

# collisions
var collision_pos_lst
var previous_velocity

## functions
func _ready():
	previous_velocity = Vector2(0, 0)
	emit_signal("fuel_update", MAX_FUEL)
	flames = [$FlameBottom, $FlameLeft, $FlameRight]
	flameTimers = [Timer.new(), Timer.new(), Timer.new()]
	flameAnimations = [1, 1, 1]
	for i in flames:
		i.hide()
	pass
	
	for i in range(len(flameTimers)):
		var timer = flameTimers[i]
		add_child(timer)
		timer.connect("timeout", self, "animateFlames", [i])

func animateFlames(index):
	var flame = flames[index]
	var timer = flameTimers[index]
	if (flameAnimations[index] > 0 and flame.frame < flame.hframes - 1)\
		or (flameAnimations[index] < 0 and flame.frame > 0):
		flame.frame += flameAnimations[index]
	else:
		flameAnimations[index] *= -1
		flame.frame += flameAnimations[index]
	timer.start(FLAME_TIMER_TICK)

func updateFlames(showFlames):
	for i in range(len(flames)):
		var flame = flames[i]
		if showFlames.has(flame) and not(flame.visible):
			var timer = flameTimers[i]
			timer.start(FLAME_TIMER_TICK)
			flame.show()
	
	for i in range(len(flames)):
		var flame = flames[i]
		if not(showFlames.has(flame) and flame.visible):
			var timer = flameTimers[i]
			flame.hide()
			timer.stop()

func _integrate_forces(state):
	collision_pos_lst = []
	var rotation = get_rotation_degrees()
	var position = get_position()
	for i in range(state.get_contact_count()):
		var ship_col_pos = (state.get_contact_local_position(i) - position).rotated(deg2rad(-rotation))
		collision_pos_lst.append(ship_col_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rotation = deg2rad(get_rotation_degrees())
	var direction = Vector2(0, 1).rotated(rotation)
	var direction_rot_by_right_angle = direction.rotated(deg2rad(90))
	
	var showFlames = []
	
	if (fuel > 0):
		if Input.is_action_pressed("ui_up"):
			var offset_up = Vector2(0, POSITION_OFFSET)
			apply_impulse(offset_up.rotated(rotation), -THROTTLE_IMPULSE * direction)
			showFlames.append($FlameBottom)
			fuel -= USE_FUEL
			
		if Input.is_action_pressed("ui_right") and not(Input.is_action_pressed("ui_left")):
			var offset_right = Vector2(-POSITION_OFFSET, POSITION_OFFSET)
			apply_impulse(offset_right.rotated(rotation), -THROTTLE_IMPULSE * direction_rot_by_right_angle)
			showFlames.append($FlameLeft)
			fuel -= USE_FUEL
			
		if Input.is_action_pressed("ui_left") and not(Input.is_action_pressed("ui_right")):
			var offset_left = Vector2(POSITION_OFFSET, POSITION_OFFSET)
			apply_impulse(offset_left.rotated(rotation), THROTTLE_IMPULSE * direction_rot_by_right_angle)
			showFlames.append($FlameRight)
			fuel -= USE_FUEL
	
	updateFlames(showFlames)
	if (fuel_previous != fuel):
		fuel_previous = fuel
		emit_signal("fuel_update", fuel)
		
	print(previous_velocity.distance_to(Vector2()))
	if len(collision_pos_lst) > 0:
		var collision_min_y = collision_pos_lst[0].y
		for i in collision_pos_lst:
			if i.y < collision_min_y:
				collision_min_y = i.y
		if collision_min_y < CRITICAL_Y_POS:
			print('BOOMY!')
		elif previous_velocity.distance_to(Vector2(0, 0)) > CRITICAL_VELOCITY:
			print('KBOOM!')
		
	if previous_velocity != linear_velocity:
		previous_velocity = linear_velocity