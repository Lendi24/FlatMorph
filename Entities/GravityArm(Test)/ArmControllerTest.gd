extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Head = $Base/ArmPart1/ArmPart2/Head
onready var ArmPart2 = $Base/ArmPart1/ArmPart2/
onready var ArmPart1 = $Base/ArmPart1/
onready var Base = $Base/
onready var Target = get_tree().get_root().get_node("Node2D/Target")

onready var grabArea = Head.get_node("Area2D")
var newBody
onready var last_pos = Vector2(0, 0)

func _ready():
	grabArea.connect("body_entered", self, "_on_physicsbody_entered")

func _physics_process(_delta):
	animate_arm(ArmPart1, ArmPart2)
	custom_collision_check()
	if(newBody != null && newBody.get_parent().name == "Head"):
		var size = newBody.get_node("Sprite").texture.get_size() * newBody.get_node("Sprite").scale		
		newBody.global_position = Vector2(0, 0)
		newBody.position = Vector2(size.y + 0.4, 0)
	var last_pos = Head.global_position
	
	
func animate_arm(arm_upper: RigidBody2D, arm_lower: RigidBody2D):

	var offset = get_global_mouse_position() - Vector2(global_position.x, global_position.y-5)
	var distance = offset.length()
	var joint_angle_0
	var joint_angle_1
	
	var atan_val = atan2(offset.y, offset.x)
	
	var length_0 = abs((arm_upper.position - Head.position).length())
	var length_1 = abs((arm_lower.position - arm_upper.position).length())
	
	# it's too far away
	if length_0 + length_1 < distance:
		joint_angle_0 = atan_val
		joint_angle_1 = 0
	else:
		var angle_0 = law_of_cos(distance, length_0, length_1)
		var angle_1 = law_of_cos(length_1, length_0, distance)
	 
		joint_angle_0 = atan_val - angle_0
		joint_angle_1 = PI - angle_1
			 

	
	#if arm_upper.rotation - joint_angle_0 > 0.05:
	#else:
	
	
	if (!is_nan(joint_angle_0)):# and !get_node("/root/Globals").GravArmStop):
		arm_upper.set_rotation(joint_angle_0)
		
	if (!is_nan(joint_angle_1)):# and !get_node("/root/Globals").GravArmStop):
		arm_lower.set_rotation(joint_angle_1)

func custom_collision_check():
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var hit = space_state.intersect_ray(last_pos, get_global_mouse_position(), [self, Base, ArmPart1.get_node("CollisionShape2D"), ArmPart2.get_node("CollisionShape2D"), Head.get_node("CollisionShape2D"), Head.get_node("Area2D/CollisionShape2D")] )
	if(hit):
		print("Hit at point : ", hit.collider.get_parent().name)

func law_of_cos(a, b, c):
	if 2 * a * b == 0:
		return 0
	return acos( (a * a + b * b - c * c) / (2 * a * b) )


func _on_physicsbody_entered(body):
	if(body.get_parent().name != "Head"):
		if(body.name == "Cube1"):
			newBody = body
			print("is a cube!")
			#pBody.set_owner(self.get_parent())

			newBody.get_parent().remove_child(body)
			newBody.mode = RigidBody2D.MODE_STATIC

			Head.add_child(newBody)
			

