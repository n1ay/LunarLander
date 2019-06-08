extends RigidBody2D

## constants
var THROTTLE_IMPULSE = 400
var FRICTION = 0.75
var POSITION_OFFSET = 30
var FLAME_TIMER_TICK = 0.1
var MAX_FUEL = 100
var USE_FUEL = 0.1
var CRITICAL_VELOCITY = 500
var CRITICAL_Y_POS = 5
var LEVEL_COMPLETED_MAX_VELOCITY_ALLOWED = 0.1
var LEVEL_COMPLETED_MAX_ROTATION = 1
var MAX_END_PLATFORM_DISTANCE = 4000
var NO_FUEL_TIMER = 5
var RESET_PROCESS_DURATION = 1.5
var CRASH_SPRITE_ANIMATION_TICK = 0.07

var ZERO_VECTOR = Vector2(0, 0)

signal fuel_update(value)
signal level_completed()
signal game_over()

## variables
var reset_process_timer
var process

# flames
var flames
var flameTimers
var flameAnimations

# fuel
var fuel = MAX_FUEL
var fuel_previous = fuel
var no_fuel_timer

# collisions
var collision_pos_lst
var previous_velocity

# level completed
var end_collision_detected
var end_platform

# sfx
var engine_audio_player
var engine_sound_playing

var crash_audio_player
var crash_sound_playing

# sprites
var ship_sprite
var crash_sprite
var crash_sprite_animation_timer
var crash_animation_playing

## functions
func _ready():
	var physics_material = PhysicsMaterial.new()
	physics_material.set_friction(FRICTION)
	set_physics_material_override(physics_material)
	end_collision_detected = false
	end_platform = get_node("/root/World/LevelGenerator/Level/EndPlatform")
	previous_velocity = ZERO_VECTOR
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
		
	no_fuel_timer = Timer.new()
	add_child(no_fuel_timer)
	no_fuel_timer.connect("timeout", self, "emit_signal", ["game_over"])
	no_fuel_timer.one_shot = true

	process = true
	reset_process_timer = Timer.new()
	add_child(reset_process_timer)
	reset_process_timer.connect("timeout", self, "enable_process")
	reset_process_timer.one_shot = true
	
	get_viewport().audio_listener_enable_2d = true
	engine_audio_player = $EngineAudioPlayer
	engine_sound_playing = false
	
	crash_audio_player = $CrashAudioPlayer
	crash_sound_playing = false
	
	ship_sprite = $Sprite
	crash_sprite = $CrashSprite
	crash_sprite.hide()
	crash_sprite_animation_timer = Timer.new()
	add_child(crash_sprite_animation_timer)
	crash_sprite_animation_timer.connect("timeout", self, "animate_crash")
	crash_animation_playing = false
	
func animate_crash():
	if crash_sprite.frame + 1 < crash_sprite.hframes:
		crash_sprite.frame += 1
		crash_sprite_animation_timer.start(CRASH_SPRITE_ANIMATION_TICK)
	else:
		crash_sprite.hide()

func play_crash_animation():
	if not(crash_animation_playing):
		crash_animation_playing = true
		ship_sprite.hide()
		crash_sprite.frame = 0
		crash_sprite.show()
		crash_sprite_animation_timer.start(CRASH_SPRITE_ANIMATION_TICK)

func on_crash():
	if not(crash_sound_playing):
		crash_audio_player.play()
		crash_sound_playing = true
	play_crash_animation()

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
	if (len(showFlames) > 0):
		if not(engine_sound_playing):
			engine_sound_playing = true
			engine_audio_player.play()
	else:
		if engine_sound_playing:
			engine_sound_playing = false
			engine_audio_player.stop()

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

func enable_process():
	process = true

func reset_process():
	process = false
	reset_process_timer.start(RESET_PROCESS_DURATION)

func _integrate_forces(state):
	end_collision_detected = false
	collision_pos_lst = []
	var rotation = get_rotation_degrees()
	var position = get_position()
	for i in range(state.get_contact_count()):
		if state.get_contact_collider_object(i) == end_platform:
			end_collision_detected = true
		var ship_col_pos = (state.get_contact_local_position(i) - position).rotated(deg2rad(-rotation))
		collision_pos_lst.append(ship_col_pos)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var rotation = deg2rad(get_rotation_degrees())
	var direction = Vector2(0, 1).rotated(rotation)
	var direction_rot_by_right_angle = direction.rotated(deg2rad(90))
	
	var showFlames = []
	
	if (fuel > 0 and process):
		if Input.is_action_pressed("ui_up"):
			var offset_up = Vector2(0, POSITION_OFFSET)
			apply_impulse(offset_up.rotated(rotation), -THROTTLE_IMPULSE * direction * delta)
			showFlames.append($FlameBottom)
			fuel -= USE_FUEL
			
		if Input.is_action_pressed("ui_right") and not(Input.is_action_pressed("ui_left")):
			var offset_right = Vector2(-POSITION_OFFSET, POSITION_OFFSET)
			apply_impulse(offset_right.rotated(rotation), -THROTTLE_IMPULSE * direction_rot_by_right_angle * delta)
			showFlames.append($FlameLeft)
			fuel -= USE_FUEL
			
		if Input.is_action_pressed("ui_left") and not(Input.is_action_pressed("ui_right")):
			var offset_left = Vector2(POSITION_OFFSET, POSITION_OFFSET)
			apply_impulse(offset_left.rotated(rotation), THROTTLE_IMPULSE * direction_rot_by_right_angle * delta)
			showFlames.append($FlameRight)
			fuel -= USE_FUEL
	
	updateFlames(showFlames)
	if (fuel_previous != fuel):
		fuel_previous = fuel
		emit_signal("fuel_update", fuel)
	
	if process:
		## GAME OVER ##	
		#print(previous_velocity.distance_to(ZERO_VECTOR))
		if len(collision_pos_lst) > 0:
			var collision_min_y = collision_pos_lst[0].y
			for i in collision_pos_lst:
				if i.y < collision_min_y:
					collision_min_y = i.y
			if collision_min_y < CRITICAL_Y_POS:
				emit_signal("game_over")
				no_fuel_timer.stop()
				on_crash()
				return
			elif previous_velocity.distance_to(ZERO_VECTOR) > CRITICAL_VELOCITY:
				emit_signal("game_over")
				no_fuel_timer.stop()
				on_crash()
				return
		
		if (get_position() - end_platform.get_position()).distance_to(ZERO_VECTOR) >= MAX_END_PLATFORM_DISTANCE:
			emit_signal("game_over")
			no_fuel_timer.stop()
			return
			
		if fuel <= 0 and no_fuel_timer.is_stopped():
			no_fuel_timer.start(NO_FUEL_TIMER)
		## ---------------------------------------------- ##
		
		## LEVEL COMPLETED ##
		if previous_velocity.distance_to(ZERO_VECTOR) <= LEVEL_COMPLETED_MAX_VELOCITY_ALLOWED\
		and linear_velocity.distance_to(ZERO_VECTOR) <= LEVEL_COMPLETED_MAX_VELOCITY_ALLOWED\
		and get_rotation_degrees() <= LEVEL_COMPLETED_MAX_ROTATION and end_collision_detected:
			no_fuel_timer.stop()
			emit_signal("level_completed")
			return
		## ---------------------------------------------- ##
		
		if previous_velocity != linear_velocity:
			previous_velocity = linear_velocity