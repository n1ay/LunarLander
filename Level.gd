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
var LABEL_VISIBLE_TIME = 2

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
	
	load_level1()
	level_colliders[0].set_disabled(false)

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

func load_level1():
	sprite.set_texture(preload("res://assets/level1.png"))
	begin_platform.set_position(Vector2(-1900, 650))
	end_platform.set_position(Vector2(700, 650))
	set_ship_starting_pos()
	
func load_level2():
	sprite.set_texture(preload("res://assets/level2.png"))
	begin_platform.set_position(Vector2(-1850, 770))
	end_platform.set_position(Vector2(1200, 800))
	set_ship_starting_pos()
	
func load_level3():
	sprite.set_texture(preload("res://assets/level3.png"))
	begin_platform.set_position(Vector2(-1850, 770))
	end_platform.set_position(Vector2(1400, 900))
	set_ship_starting_pos()
	
func load_level4():
	sprite.set_texture(preload("res://assets/level4.png"))
	begin_platform.set_position(Vector2(-1875, 770))
	end_platform.set_position(Vector2(-400, -180))
	set_ship_starting_pos()

func reset_variables():
	ship.fuel = ship.MAX_FUEL
	ship.set_rotation(0)
	ship.linear_velocity = Vector2(0, 0)
	ship.angular_velocity = 0
	set_ship_starting_pos()
	ship.end_collision_detected = false
	ship.previous_velocity = Vector2(0, 0)
	ship.collision_pos_lst = []
	
	ship.reset_process()
	
#func _process(delta):
#	pass


func _on_Ship_game_over():
	print('boom')
	reset_variables()
	present_label(game_over_label)


func _on_Ship_level_completed():
	print('gg easy')
	level_colliders[current_level].set_disabled(true)
	if (current_level + 1 < len(levels)):
		current_level += 1
		levels[current_level].call_func()
	reset_variables()
	level_colliders[current_level].set_disabled(false)
	present_label(level_completed_label)
