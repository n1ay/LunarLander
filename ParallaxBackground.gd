extends ParallaxBackground

var SPEED = 2 * Vector2(16, 9)

var BG1_STARTING_POS = Vector2(0, 0)
var BG2_STARTING_POS

var bg1
var bg2
var img_size

func _ready():
	bg1 = $ParallaxLayer
	bg2 = $ParallaxLayer2
	bg1.set_position(BG1_STARTING_POS)
	
	img_size = $ParallaxLayer/Background.texture.get_size()
	BG2_STARTING_POS = Vector2(img_size.x - ProjectSettings.get_setting("display/window/size/width"),\
		img_size.y - ProjectSettings.get_setting("display/window/size/height"))
	bg2.set_position(BG2_STARTING_POS)
	set_process(true)

func _process(delta):
	var pos1 = bg1.get_position()
	var pos2 = bg2.get_position()
	
	var speed = SPEED * delta
	pos1 -= speed
	pos2 -= speed
	
	if (pos1.x <= -img_size.x):
		pos1 = pos2 + BG2_STARTING_POS
		print(pos1, ' ', pos2)
	bg1.set_position(pos1)
	
	if (pos2.x <= -img_size.x):
		pos2 = pos1 + BG2_STARTING_POS
		print(pos1, ' ', pos2)
	bg2.set_position(pos2)
	