extends TextureRect

var COLOR = Color(255, 0, 0, 50)
var LINE_WIDTH = 5
var polygon

func _ready():
	pass # Replace with function body.

func _draw():
	if polygon:
		for i in range(len(polygon) - 1):
			draw_line(polygon[i], polygon[i+1], COLOR, LINE_WIDTH)
		draw_line(polygon[0], polygon[len(polygon) - 1], COLOR, LINE_WIDTH)

func _on_Level_draw_polygon(polygon):
	self.polygon = polygon
	update()
