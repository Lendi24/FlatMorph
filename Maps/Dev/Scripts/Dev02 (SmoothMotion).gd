extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dist = sqrt(pow((get_global_mouse_position().x-global_position.x),2)+pow((get_global_mouse_position().y-global_position.y),2))
	if (dist<2.5):	
		global_position = get_global_mouse_position()
	else:
		rotation = get_global_mouse_position().angle_to_point(position)
		move_local_x(2.5)
		
