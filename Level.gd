extends StaticBody2D

var sprite
var begin_platform
var end_platform

var ship
var ship_sprite
var levels
var level_colliders
var current_level

var game_over_label = "You lose"
var level_completed_label = "GG easy"
var event_label
var label_visible_timer
var LABEL_VISIBLE_TIME = 1.5

var reset_level_timer
var game_over

func _ready():
	begin_platform = $BeginPlatform
	end_platform = $EndPlatform

	sprite = $Sprite
	ship = get_node("/root/World/Ship")
	ship_sprite = get_node("/root/World/Ship/Sprite")
	event_label = get_node("/root/World/EventLabel")

	current_level = 0
	levels = [
		funcref(self, "load_level1"),
		funcref(self, "load_level2"),
		funcref(self, "load_level3"),
		funcref(self, "load_level4")
	]
	
	level_colliders = [
		$Level1,
		$Level2,
		$Level3,
		$Level4
	]
	
	label_visible_timer = Timer.new()
	add_child(label_visible_timer)
	label_visible_timer.connect("timeout", self, "hide_event_label")
	
	reset_level_timer = Timer.new()
	add_child(reset_level_timer)
	reset_level_timer.connect("timeout", self, "reset_variables")
	reset_level_timer.one_shot = true
	
	game_over = false
	
	load_level1()

func present_label(text):
	set_event_label_pos()
	event_label.set_text(text)
	event_label.show()
	label_visible_timer.start(LABEL_VISIBLE_TIME)

func hide_event_label():
	event_label.hide()

func set_ship_starting_pos():
	var begin_platform_pos = begin_platform.get_position()
	ship.set_position(Vector2(begin_platform_pos.x, begin_platform_pos.y - ship_sprite.texture.get_size().y / 3))

func set_event_label_pos():
	var ship_pos = ship.get_position()
	event_label.set_position((Vector2(ship_pos.x - event_label.get_combined_minimum_size().x / 2, ship_pos.y - ship_sprite.texture.get_size().y / 3)))

func disable_level_colliders():
	for i in level_colliders:
		i.set_disabled(true)

func load_level1():
	sprite.set_texture(preload("res://assets/level1.png"))
	begin_platform.set_position(Vector2(-1900, 650))
	end_platform.set_position(Vector2(700, 650))
	disable_level_colliders()
	level_colliders[0].set_disabled(false)
	set_ship_starting_pos()
	
func load_level2():
	sprite.set_texture(preload("res://assets/level2.png"))
	begin_platform.set_position(Vector2(-1850, 770))
	end_platform.set_position(Vector2(1200, 800))
	disable_level_colliders()
	level_colliders[1].set_disabled(false)
	set_ship_starting_pos()
	
func load_level3():
	sprite.set_texture(preload("res://assets/level3.png"))
	begin_platform.set_position(Vector2(-1850, 770))
	end_platform.set_position(Vector2(1400, 900))
	disable_level_colliders()
	level_colliders[2].set_disabled(false)
	set_ship_starting_pos()
	
func load_level4():
	sprite.set_texture(preload("res://assets/level4.png"))
	begin_platform.set_position(Vector2(-1875, 770))
	end_platform.set_position(Vector2(-400, -180))
	disable_level_colliders()
	level_colliders[3].set_disabled(false)
	set_ship_starting_pos()

func freeze_ship(set_gravity=true):
	ship.linear_velocity = Vector2(0, 0)
	ship.angular_velocity = 0
	if set_gravity:
		ship.gravity_scale = 0
	ship.process = false
	reset_level_timer.start(ship.RESET_PROCESS_DURATION)

func reset_variables():
	ship.fuel = ship.MAX_FUEL
	ship.set_rotation(0)
	ship.linear_velocity = Vector2(0, 0)
	ship.angular_velocity = 0
	ship.end_collision_detected = false
	ship.previous_velocity = Vector2(0, 0)
	ship.collision_pos_lst = []
	ship.gravity_scale = 1
	if game_over:
		set_ship_starting_pos()
	else:
		if (current_level + 1 < len(levels)):
			current_level += 1
			levels[current_level].call_func()
	ship_sprite.show()
	ship.crash_animation_playing = false
	ship.crash_sound_playing = false
	ship.reset_process()
	game_over = false
	
#func _process(delta):
#	pass


func _on_Ship_game_over():
	print('boom')
	present_label(game_over_label)
	game_over = true
	freeze_ship()

func _on_Ship_level_completed():
	print('gg easy')
	freeze_ship(false)
	present_label(level_completed_label)
