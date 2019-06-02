extends StaticBody2D

var collision_polygon
var canvas

var end_platform

signal draw_polygon(vertices)

func _ready():
	end_platform = $EndPlatform
	
	collision_polygon = $LevelCollisionPolygon
	canvas = $LevelCanvas
	var vertices = [
		Vector2(100, 100),
		Vector2(150, 100),
		Vector2(150, 150),
		Vector2(100, 150)
	]
	collision_polygon.set_polygon(PoolVector2Array(vertices))
	emit_signal("draw_polygon", vertices)
	

#func _process(delta):
#	pass
