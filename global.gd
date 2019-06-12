extends Node

## save / load game variables

var HASHES = 10

var loaded = false
var unlocked_level = 0

# it is used in the other script
# warning-ignore:unused_class_variable
var play_level = 0

var save_file_path = "lunar_lander.dat"
var preamble = "5245a52778d684fa698f69861fb2e058b308f6a74fed5bf2fe77d97bad5e071c"

var level_hashes

## --- ##

## OPTIONS ##
var invert_left_right_controls = false
## --- ##

# save or load state game functions
func load_level_hashes():
	level_hashes = {}
	for i in range(HASHES):
		level_hashes[str(i).sha256_text()] = i

func load_state():
	var load_file = File.new()
	if not load_file.file_exists(save_file_path):
		return
	load_file.open(save_file_path, File.READ)
	var line_number = 0
	while not load_file.eof_reached():
		var current_line = parse_json(load_file.get_line())
		if current_line != null and line_number == 0:
			var level_key = current_line.split(preamble)[1]
			if level_hashes.has(level_key):
				unlocked_level = level_hashes[level_key]
		elif current_line != null and line_number == 1:
			var invert_controls_key = current_line.split(preamble)[1]
			if level_hashes.has(invert_controls_key):
				invert_left_right_controls = level_hashes[invert_controls_key] == 1
		line_number += 1
	
	loaded = true
			
func save_state():
	var save_file = File.new()
	save_file.open(save_file_path, File.WRITE)
	save_file.store_line(to_json(preamble + str(unlocked_level).sha256_text()))
	save_file.store_line(to_json(preamble + str(1 if invert_left_right_controls else 0).sha256_text()))
	save_file.close()